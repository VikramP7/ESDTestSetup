import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal
import QtQml

Dialog {
    id: dialog

    title: qsTr("Configure Test Setup")
    standardButtons: Dialog.Save | Dialog.Cancel

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    width: Screen.width * 0.5
    height: Screen.height * 0.5

    signal finished(bool save)

    signal settingChanged(string label, real val)

    ColumnLayout {
        anchors.fill: parent
        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton {
                text: qsTr("OSCILLOSCOPE")
                //onClicked: stackView.currentIndex = 0
            }

            TabButton {
                text: qsTr("SMU")
                //onClicked: stackView.currentIndex = 1
            }

            TabButton {
                text: qsTr("VNA")
                //onClicked: stackView.currentIndex = 2
            }

            TabButton {
                text: qsTr("TLP")
                //onClicked: stackView.currentIndex =3
            }
        }

        StackLayout {
            id: stackView
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: tabBar.currentIndex

            Item {
                id: oscilloscopeView
                Layout.fillWidth: true
                Layout.fillHeight: true

                OscilloscopeForm{
                    id: oscForm
                    anchors.fill: parent
                    onValueChanged: (label, val) => dialog.settingChanged(label, val)
                }
            }

            Item {
                id: smuView
                Layout.fillWidth: true
                Layout.fillHeight: true

                SMUForm{
                    id: smuForm
                    anchors.fill: parent
                    onValueChanged: (label, val) => dialog.settingChanged(label, val)
                }
            }

            Item {
                id: vnaView
                Layout.fillWidth: true
                Layout.fillHeight: true

                VNAForm{
                    id: vnaForm
                    anchors.fill: parent
                    onValueChanged: (label, val) => dialog.settingChanged(label, val)
                }
            }

            Item {
                id: tlpView
                Layout.fillWidth: true
                Layout.fillHeight: true

                TLPForm{
                    id: tlpForm
                    anchors.fill: parent
                    onValueChanged: (label, val) => dialog.settingChanged(label, val)
                }
            }
        }
    }

    function openConfiguration(parameterDictionary) {
        dialog.title = qsTr("Configure Test Setup")
        oscForm.displayCurrentParameters(parameterDictionary)
        smuForm.displayCurrentParameters(parameterDictionary)
        vnaForm.displayCurrentParameters(parameterDictionary)
        tlpForm.displayCurrentParameters(parameterDictionary)
        dialog.open()
    }

    function setStackViewIndex(index){
        tabBar.currentIndex = index
    }

    onAccepted: {
        console.log("Dialog Save")
        dialog.finished(true)
    }

    onRejected:{
        console.log("Dialog Cancel")
        dialog.finished(false)
    }
}