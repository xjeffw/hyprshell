import QtQuick
import QtQuick.Shapes

// A speaker like avizo's volume icons: 1-3 sound waves for the level, or a
// cross when muted. Drawn on avizo's 96px grid and scaled to fit.
Item {
    id: root

    // 0 to 1.
    property real level: 0
    property bool muted: false
    property color color: Theme.subtext0
    // Like avizo: one wave up to 33%, two up to 66%, then three.
    readonly property int waves: muted ? 0 : level <= 0.33 ? 1 : level <= 0.66 ? 2 : 3

    component Wave: ShapePath {
        id: wave

        required property int index

        strokeWidth: root.waves > wave.index ? 9 : -1
        strokeColor: root.color
        fillColor: "transparent"
        capStyle: ShapePath.FlatCap

        PathAngleArc {
            centerX: 35
            centerY: 48
            radiusX: 18.5 + 15 * wave.index
            radiusY: radiusX
            startAngle: -45
            sweepAngle: 90
            moveToStart: true
        }
    }

    implicitWidth: 96
    implicitHeight: 96

    Shape {
        anchors.centerIn: parent
        width: 96
        height: 96
        scale: Math.min(root.width, root.height) / 96
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeWidth: -1
            fillColor: root.color

            startX: 12
            startY: 34
            PathLine {
                x: 21
                y: 34
            }
            PathLine {
                x: 29
                y: 26.5
            }
            PathQuad {
                x: 34
                y: 29
                controlX: 34
                controlY: 23.5
            }
            PathLine {
                x: 34
                y: 67
            }
            PathQuad {
                x: 29
                y: 69.5
                controlX: 34
                controlY: 72.5
            }
            PathLine {
                x: 21
                y: 62
            }
            PathLine {
                x: 12
                y: 62
            }
            PathQuad {
                x: 8
                y: 58
                controlX: 8
                controlY: 62
            }
            PathLine {
                x: 8
                y: 38
            }
            PathQuad {
                x: 12
                y: 34
                controlX: 8
                controlY: 34
            }
        }

        Wave {
            index: 0
        }

        Wave {
            index: 1
        }

        Wave {
            index: 2
        }

        ShapePath {
            strokeWidth: root.muted ? 8.5 : -1
            strokeColor: root.color
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathMove {
                x: 50
                y: 38
            }
            PathLine {
                x: 70
                y: 58
            }
            PathMove {
                x: 70
                y: 38
            }
            PathLine {
                x: 50
                y: 58
            }
        }
    }
}
