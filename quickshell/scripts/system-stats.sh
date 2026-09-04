#!/usr/bin/env bash

set -uo pipefail

read_cpu() {
  local _ user nice system idle iowait irq softirq steal _guest _guest_nice
  read -r _ user nice system idle iowait irq softirq steal _guest _guest_nice </proc/stat
  CPU_IDLE=$((idle + iowait))
  CPU_TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal))
}

read_cpu
first_idle=$CPU_IDLE
first_total=$CPU_TOTAL
sleep 0.15
read_cpu

idle_delta=$((CPU_IDLE - first_idle))
total_delta=$((CPU_TOTAL - first_total))

memory_total_kib=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
memory_available_kib=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)
memory_used_kib=$((memory_total_kib - memory_available_kib))

cpu_temp_millidegrees=0

# Match the AGS reference's preferred AMD k10temp/Tctl sensor when available.
for sensor_name_file in /sys/class/hwmon/hwmon*/name; do
  [[ -r $sensor_name_file ]] || continue
  sensor_name=$(<"$sensor_name_file") 2>/dev/null || continue
  [[ $sensor_name == "k10temp" ]] || continue

  sensor_dir=${sensor_name_file%/name}
  for label_file in "$sensor_dir"/temp*_label; do
    [[ -r $label_file ]] || continue
    label=$(<"$label_file") 2>/dev/null || continue
    [[ $label == "Tctl" ]] || continue

    input_file=${label_file%_label}_input
    [[ -r $input_file ]] || continue
    temperature=$(<"$input_file") 2>/dev/null || continue
    if [[ $temperature =~ ^[0-9]+$ ]] && ((temperature < 200000)); then
      cpu_temp_millidegrees=$temperature
      break 2
    fi
  done
done

# Fall back to the highest plausible thermal-zone reading on other hardware.
if ((cpu_temp_millidegrees == 0)); then
  for temperature_file in /sys/class/thermal/thermal_zone*/temp; do
    if [[ -r $temperature_file ]]; then
      temperature=$(<"$temperature_file") 2>/dev/null || continue
      if [[ $temperature =~ ^[0-9]+$ ]] && ((temperature > cpu_temp_millidegrees)) && ((temperature < 200000)); then
        cpu_temp_millidegrees=$temperature
      fi
    fi
  done
fi

cpu_frequency_khz=0
frequency_count=0
for frequency_file in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
  if [[ -r $frequency_file ]]; then
    frequency=$(<"$frequency_file") 2>/dev/null || continue
    if [[ $frequency =~ ^[0-9]+$ ]]; then
      cpu_frequency_khz=$((cpu_frequency_khz + frequency))
      frequency_count=$((frequency_count + 1))
    fi
  fi
done

if ((frequency_count > 0)); then
  cpu_frequency_khz=$((cpu_frequency_khz / frequency_count))
fi

awk \
  -v idle_delta="$idle_delta" \
  -v total_delta="$total_delta" \
  -v memory_total_kib="$memory_total_kib" \
  -v memory_used_kib="$memory_used_kib" \
  -v cpu_temp_millidegrees="$cpu_temp_millidegrees" \
  -v cpu_frequency_khz="$cpu_frequency_khz" \
  'BEGIN {
    cpu_percent = total_delta > 0 ? (total_delta - idle_delta) * 100 / total_delta : 0
    memory_percent = memory_total_kib > 0 ? memory_used_kib * 100 / memory_total_kib : 0
    printf "{\"cpu_percent\":%.1f,\"cpu_temp\":%.1f,\"cpu_frequency\":%.2f,\"memory_percent\":%.1f,\"memory_used\":%.2f,\"memory_total\":%.2f}\n", cpu_percent, cpu_temp_millidegrees / 1000, cpu_frequency_khz / 1000000, memory_percent, memory_used_kib / 1048576, memory_total_kib / 1048576
  }'
