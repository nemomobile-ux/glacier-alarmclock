import QtQuick 2.6

import QtQuick.Controls 1.0
import QtQuick.Controls.Nemo 1.0


Page {
    id: mainPage

    property variant alarmModel
    property variant selectedAlarm: null;

    onSelectedAlarmChanged: {
        var i;
        if (selectedAlarm !== null) {
            for (i = 0; i < daysOfWeekModel.count; i++) {
                var day = daysOfWeekModel.get(i);
                var enabled = (selectedAlarm.daysOfWeek.indexOf(day.letter) !== -1);
                daysOfWeekModel.setProperty(i, "enabled", enabled);
            }
        } else {
            for (i = 0; i < daysOfWeekModel.count; i++) {
                daysOfWeekModel.setProperty(i, "enabled", true);
            }
        }
    }

    headerTools: HeaderToolsLayout {
        id: tools
        title: qsTr("Add alarm")
        showBackButton: true;

    }

    Flickable {
        id: mainFlickable
        anchors.fill: parent;
        contentHeight: mainColumn.childrenRect.height
        contentWidth: parent.width


        Column {
            id: mainColumn;
            width: parent.width
            spacing: Theme.itemSpacingSmall


            TimePicker {
                id: timePicker
                width: 300;
                height: 300;
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: Theme.itemSpacingLarge
                readOnly: false;
                currentTime: (selectedAlarm !== null) ? new Date(2000, 1, 1, selectedAlarm.hour, selectedAlarm.minute) : new Date();
            }

            TextField{
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(timePicker.currentTime, "HH:mm");
                width: Theme.itemWidthSmall
                horizontalAlignment: TextInput.AlignHCenter
                inputMethodHints: Qt.ImhDigitsOnly
                inputMask: "00:00;_"

                onEditingFinished: {
                    var values = text.split(":")
                    timePicker.currentTime = new Date(2000, 1, 1, values[0], values[1])
                }
            }

            Grid {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.itemSpacingMedium
                spacing: Theme.itemSpacingMedium
                columns: 2
                flow: Grid.TopToBottom

                Repeater {
                    model: daysOfWeekModel
                    CheckBox {
                        anchors.margins: Theme.itemSpacingMedium
                        text: model.short_name
                        checked: model.enabled;
                        onCheckedChanged: {
                            model.enabled = checked
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: childrenRect.height
                Button {
                    text: (selectedAlarm !== null) ? qsTr("Update") : qsTr("Add")
                    primary: true;
                    width: parent.width/2;
                    onClicked: {
                        var daysOfWeekStr = ''
                        for (var i = 0; i < daysOfWeekModel.count; i++) {
                            var it = daysOfWeekModel.get(i);
                            if (it.enabled) {
                                daysOfWeekStr += it.letter
                            }
                        }
                        var alarm;
                        if (selectedAlarm !== null) {
                            alarm = selectedAlarm;
                        } else {
                            alarm = alarmModel.createAlarm()
                        }
                        alarm.title = qsTr("Alarm")
                        alarm.hour = timePicker.currentTime.getHours();
                        alarm.minute = timePicker.currentTime.getMinutes();
                        alarm.daysOfWeek = daysOfWeekStr
                        alarm.enabled = true;
                        alarm.save();
                        pageStack.pop();

                    }
                }
                Button {
                    text: qsTr("Delete");
                    visible: (selectedAlarm !== null)
                    width: parent.width/2
                    onClicked: {
                        selectedAlarm.deleteAlarm()
                        pageStack.pop();
                    }
                }

                Button {
                    visible: (selectedAlarm === null)
                    text: qsTr("Cancel")
                    width: parent.width/2;
                    onClicked: {
                        pageStack.pop();
                    }
                }

            }

        }
    }

    ScrollDecorator {
        flickable: mainFlickable
    }

}
