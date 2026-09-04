import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    default property alias content: contentRow.data
    property alias spacing: contentRow.spacing
    property string tooltipText: ""
    property int horizontalPadding: 8
    property bool interactive: false
    property int acceptedButtons: Qt.LeftButton
    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: Theme.controlHeight
    radius: Theme.radius
    color: Theme.surface0
    border.width: 1
    border.color: Theme.surface1

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: 5
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        acceptedButtons: root.acceptedButtons
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.wheel(wheel)
    }

    HoverHandler {
        id: hoverHandler
    }

    ToolTip.visible: hoverHandler.hovered && root.tooltipText.length > 0
    ToolTip.text: root.tooltipText
    ToolTip.delay: 500
}
