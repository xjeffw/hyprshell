import QtQuick
import QtQuick.Shapes

// A sun like avizo's brightness icons: a ring with 4 rays above 33% and 8
// above 66%. Drawn on avizo's 96px grid and scaled to fit.
Item {
    id: root

    // 0 to 1.
    property real level: 0
    property color color: Theme.subtext0
    readonly property int rays: level <= 0.33 ? 0 : level <= 0.66 ? 4 : 8

    implicitWidth: 96
    implicitHeight: 96

    Item {
        anchors.centerIn: parent
        width: 96
        height: 96
        scale: Math.min(root.width, root.height) / 96

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 9
                strokeColor: root.color
                fillColor: "transparent"

                PathAngleArc {
                    centerX: 48
                    centerY: 48
                    radiusX: 18
                    radiusY: 18
                    startAngle: 0
                    sweepAngle: 360
                    moveToStart: true
                }
            }
        }

        // The straight rays, then the diagonal ones.
        Repeater {
            model: 8

            delegate: Shape {
                required property int index

                anchors.fill: parent
                visible: index < root.rays
                rotation: index * 90 + (index < 4 ? 0 : 45)
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeWidth: -1
                    fillColor: root.color

                    startX: 48
                    startY: 9
                    PathCubic {
                        x: 41.8
                        y: 20
                        control1X: 47.3
                        control1Y: 9
                        control2X: 44
                        control2Y: 14.5
                    }
                    PathLine {
                        x: 54.2
                        y: 20
                    }
                    PathCubic {
                        x: 48
                        y: 9
                        control1X: 52
                        control1Y: 14.5
                        control2X: 48.7
                        control2Y: 9
                    }
                }
            }
        }
    }
}
