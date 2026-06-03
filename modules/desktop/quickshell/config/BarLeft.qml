import QtQuick.Layouts

RowLayout {
    id: root
    required property var screen
    WorkspacesWidget {screen: root.screen}
}
