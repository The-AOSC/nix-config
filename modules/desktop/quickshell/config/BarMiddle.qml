import QtQuick.Layouts

RowLayout {
    id: root
    required property var screen
    WindowWidget {
        screen: root.screen;
        Layout.fillWidth: true
    }
}
