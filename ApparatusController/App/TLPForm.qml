import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal
import QtQml

GridLayout {
    id: root
    
    columns: 2
    columnSpacing: 20
    rowSpacing: 10
    Layout.fillWidth: true

    signal valueChanged(string label, real val)

    property var tlp_voltage_max_top: 2000
    property var tlp_voltage_max_bottom: -2000

    property var tlp_voltage_min_top: 2000
    property var tlp_voltage_min_bottom: -2000

    property var tlp_voltage_increment_top: 2000
    property var tlp_voltage_increment_bottom: 1

    Label {
        text: qsTr("Charge Voltage Range (V): ")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the voltage range for the TLP to sweep through"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maTLPVoltageRange.containsMouse
        MouseArea {
            id: maTLPVoltageRange
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    RowLayout{
        TextField {
            id: tlpVoltageMax
            focus: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

            inputMethodHints: Qt.ImhFormattedNumbersOnly
            placeholderText: qsTr("max (V)")
            validator: DoubleValidator {bottom: tlp_voltage_max_bottom; top: tlp_voltage_max_top}

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("From " + tlp_voltage_max_bottom + "V to " + tlp_voltage_max_top + "V")

            onEditingFinished:{
                console.log("TLP voltage max changed")
                root.valueChanged("tlp_voltage_max", parseFloat(tlpVoltageRange.text))
            }

            onTextChanged: {
                if (!tlpVoltageMax.acceptableInput){
                    tlpVoltageMax.color = "red"
                }
                else{
                    tlpVoltageMax.color = "black"
                }
            }
        }

        TextField {
            id: tlpVoltageMin
            focus: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

            inputMethodHints: Qt.ImhFormattedNumbersOnly
            placeholderText: qsTr("min (V)")
            validator: DoubleValidator {bottom: tlp_voltage_min_bottom; top: tlp_voltage_min_top}

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("From " + tlp_voltage_min_bottom + "V to " + tlp_voltage_min_top + "V")

            onEditingFinished:{
                console.log("TLP voltage min changed")
                root.valueChanged("tlp_voltage_min", parseFloat(tlpVoltageMin.text))
            }

            onTextChanged: {
                if (!tlpVoltageMin.acceptableInput){
                    tlpVoltageMin.color = "red"
                }
                else{
                    tlpVoltageMin.color = "black"
                }
            }
        }
    }

    
    Label {
        text: qsTr("Voltage Increment (V):")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set voltage increments"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maTLPVinc.containsMouse
        MouseArea {
            id: maTLPVinc
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: tlpVoltageIncrement
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        inputMethodHints: Qt.ImhFormattedNumbersOnly
        placeholderText: qsTr("(V)")
        validator: DoubleValidator {bottom: tlp_voltage_increment_bottom; top: tlp_voltage_increment_top}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + tlp_voltage_increment_bottom + "V to " + tlp_voltage_increment_top + "V")

        onEditingFinished:{
            console.log("TLP voltage Increment Changed")
            root.valueChanged("tlp_voltage_increment", parseFloat(tlpVoltageIncrement.text))
        }

        onTextChanged: {
            if (!tlpVoltageIncrement.acceptableInput){
                tlpVoltageIncrement.color = "red"
            }
            else{
                tlpVoltageIncrement.color = "black"
            }
        }
    }

    // when the form is opened current values are populated in the form fields
    function displayCurrentParameters(parameterDictionary){
        tlpVoltageMax.text = parameterDictionary["tlp_voltage_max"]
        tlpVoltageMin.text = parameterDictionary["tlp_voltage_min"]
        tlpVoltageIncrement.text = parameterDictionary["tlp_voltage_increment"]
    }
}