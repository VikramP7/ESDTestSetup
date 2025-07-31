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

    property var smu_voltage_max_bottom: 0
    property var smu_voltage_max_top: 50

    property var smu_voltage_min_bottom: 0.0
    property var smu_voltage_min_top: 50

    property var smu_voltage_increment_bottom: 0.001
    property var smu_voltage_increment_top: 50

    property var smu_settle_time_bottom: 0.0001
    property var smu_settle_time_top: 10

    property var smu_current_max_bottom: 0.0
    property var smu_current_max_top: 100

    Label {
        text: qsTr("Voltage Range (V): ")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the voltage range for the SMU to sweep through"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maSMUVoltageRange.containsMouse
        MouseArea {
            id: maSMUVoltageRange
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    RowLayout{
        TextField {
            id: smuVoltageMax
            focus: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

            inputMethodHints: Qt.ImhFormattedNumbersOnly
            placeholderText: qsTr("max (V)")
            validator: DoubleValidator {bottom: smu_voltage_max_bottom; top: smu_voltage_max_top}

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("From " + smu_voltage_max_bottom + "V to " + smu_voltage_max_top + "V")

            onEditingFinished:{
                console.log("SMU voltage max changed")
                root.valueChanged("smu_voltage_max", parseFloat(smuVoltageMax.text))
            }

            onTextChanged: {
                if (!smuVoltageMax.acceptableInput){
                    smuVoltageMax.color = "red"
                }
                else{
                    smuVoltageMax.color = "black"
                }
            }
        }

        TextField {
            id: smuVoltageMin
            focus: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

            inputMethodHints: Qt.ImhFormattedNumbersOnly
            placeholderText: qsTr("min (V)")
            validator: DoubleValidator {bottom: smu_voltage_min_bottom; top: smu_voltage_min_top}

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("From " + smu_voltage_min_bottom + "V to " + smu_voltage_min_top + "V")

            
            onEditingFinished:{
                console.log("SMU voltage min changed")
                root.valueChanged("smu_voltage_min", parseFloat(smuVoltageMin.text))
            }

            onTextChanged: {
                if (!smuVoltageMin.acceptableInput){
                    smuVoltageMin.color = "red"
                }
                else{
                    smuVoltageMin.color = "black"
                }
            }
        }
    }

    
    Label {
        text: qsTr("Voltage Increment (V):")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the durration of each voltage increment"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maSMUVinc.containsMouse
        MouseArea {
            id: maSMUVinc
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: smuVoltageIncrement
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(V)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: smu_voltage_increment_bottom; top: smu_voltage_increment_top}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + smu_voltage_max_bottom + "V to " + smu_voltage_max_top + "V")

        onEditingFinished:{
            console.log("SMU settle time changed")
            root.valueChanged("smu_voltage_increment", parseFloat(smuVoltageIncrement.text))
        }

        onTextChanged: {
            if (!smuVoltageIncrement.acceptableInput){
                smuVoltageIncrement.color = "red"
            }
            else{
                smuVoltageIncrement.color = "black"
            }
        }
    }


    Label {
        text: qsTr("Settle Time (s):")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the durration of each voltage increment"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maSMUSettleTime.containsMouse
        MouseArea {
            id: maSMUSettleTime
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: smuSettleTime
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(s)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: smu_settle_time_bottom; top: smu_settle_time_top}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + smu_settle_time_bottom + "s to " + smu_settle_time_top + "s")
        
        onEditingFinished:{
            console.log("SMU settle time changed")
            root.valueChanged("smu_settle_time", parseFloat(smuSettleTime.text))
        }

        onTextChanged: {
            if (!smuSettleTime.acceptableInput){
                smuSettleTime.color = "red"
            }
            else{
                smuSettleTime.color = "black"
            }
        }
    }


    Label {
        text: qsTr("Current Maximum (A):")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the max current that can be drawn from the SMU"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maSMUMaxCurrent.containsMouse
        MouseArea {
            id: maSMUMaxCurrent
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: smuCurrentMax
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(A)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: smu_current_max_bottom; top: smu_current_max_top}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + smu_current_max_bottom + "A to " + smu_current_max_top + "A")

        onEditingFinished:{
            console.log("Currnet Changed changed")
            root.valueChanged("smu_current_max", parseFloat(smuCurrentMax.text))
        }

        onTextChanged: {
            if (!smuCurrentMax.acceptableInput){
                smuCurrentMax.color = "red"
            }
            else{
                smuCurrentMax.color = "black"
            }
        }
    }

    function displayCurrentParameters(parameterDictionary){
        smuVoltageMax.text = (parameterDictionary["smu_voltage_max"])
        smuVoltageMin.text = (parameterDictionary["smu_voltage_min"])
        smuVoltageIncrement.text = parameterDictionary["smu_voltage_increment"]
        smuSettleTime.text = parameterDictionary["smu_settle_time"]
        smuCurrentMax.text = parameterDictionary["smu_current_max"]
    }
}