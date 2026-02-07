import QtQuick
import Nemo
import Nemo.Controls

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

    property bool layoutPortrait: mainPage.width < mainPage.height

    Item {
        id: timerColumn

        width: (mainPage.layoutPortrait ? mainPage.width : mainPage.width / 2)
        height: (mainPage.layoutPortrait ? mainPage.height/2 : mainPage.height) - buttonsRow.height

        TimePicker {
            id: timePicker
            width: Math.min(parent.width, parent.height) - Theme.itemSpacingMedium
            height: width
            anchors.centerIn: parent
            anchors.margins: Theme.itemSpacingLarge
            hoursLineWidth: Math.min(Theme.itemHeightSmall, timerColumn.height/10)
            minutesLineWidth: Math.min( Theme.itemHeightExtraSmall/2 , timerColumn.height/14)
            readOnly: false;
            currentTime: (selectedAlarm !== null) ? new Date(2000, 1, 1, selectedAlarm.hour, selectedAlarm.minute) : new Date();
        }

    }



    Flickable {
        id: mainFlickable
        anchors.top: mainPage.layoutPortrait ? timerColumn.bottom: parent.top;
        anchors.left: mainPage.layoutPortrait ? parent.left : timerColumn.right
        anchors.right: parent.right
        anchors.bottom: buttonsRow.top
        anchors.margins: Theme.itemSpacingMedium
        contentHeight: settingsColumn.childrenRect.height
        clip: true

        Column {
            id: settingsColumn
            spacing: Theme.itemSpacingMedium
            width: parent.width
            height: childrenRect.height


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
        }

    }




    Row {
        id: buttonsRow
        anchors.bottom: parent.bottom;
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
                window.pageStack.pop();

            }
        }
        Button {
            text: qsTr("Delete");
            visible: (selectedAlarm !== null)
            width: parent.width/2
            onClicked: {
                selectedAlarm.deleteAlarm()
                window.pageStack.pop();
            }
        }

        Button {
            visible: (selectedAlarm === null)
            text: qsTr("Cancel")
            width: parent.width/2;
            onClicked: {
                window.pageStack.pop();
            }
        }

    }


}
