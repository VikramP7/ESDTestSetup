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

    property var osc_trigger_voltage_bottom: -1000
    property var osc_trigger_voltage_top: 1000
    
    property var osc_waveform_resolution_bottom: 0
    property var osc_waveform_resolution_top: 1

    property var osc_aquisition_time_bottom: 0
    property var osc_aquisition_time_top: 10


    Label {
        text: qsTr("Trigger Voltage Channel: ")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set which channel the trigger is observed"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maOSCTriggerVoltageChannel.containsMouse
        MouseArea {
            id: maOSCTriggerVoltageChannel
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    RowLayout{
        RadioButton{
            id: oscCH1
            Layout.alignment: Qt.AlignLeft
            text: "CH1"
            onToggled: {
                console.log("OSC trigger channel changed")
                root.valueChanged("osc_trigger_channel", 1)
            }
        }
        RadioButton{
            id: oscCH2
            Layout.alignment: Qt.AlignLeft
            text: "CH2"
            onToggled: {
                console.log("OSC trigger channel changed")
                root.valueChanged("osc_trigger_channel", 2)
            }
        }
        RadioButton{
            id: oscCH3
            Layout.alignment: Qt.AlignLeft
            text: "CH3"
            onToggled: {
                console.log("OSC trigger channel changed")
                root.valueChanged("osc_trigger_channel", 3)
            }
        }
        RadioButton{
            id: oscCH4
            Layout.alignment: Qt.AlignLeft
            text: "CH4"
            onToggled: {
                console.log("OSC trigger channel changed")
                root.valueChanged("osc_trigger_channel", 4)
            }
        }
    }

    Label {
        text: qsTr("Trigger Voltage (V)")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the trigger voltage for single waveform measurment"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maOSCTriggerVoltage.containsMouse
        MouseArea {
            id: maOSCTriggerVoltage
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: oscTriggerVoltage
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(V)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: osc_trigger_voltage_bottom; top: osc_trigger_voltage_top;}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + osc_trigger_voltage_bottom + "V to " + osc_trigger_voltage_top + "V")

        onEditingFinished:{
            console.log("OSC trigger voltage changed")
            root.valueChanged("osc_trigger_voltage", parseFloat(oscTriggerVoltage.text))
        }

        onTextChanged: {
            if (!oscTriggerVoltage.acceptableInput){
                oscTriggerVoltage.color = "red"
            }
            else{
                oscTriggerVoltage.color = "black"
            }
        }
    }

    
    Label {
        text: qsTr("Waveform Resolution (s):")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the resolution of the waveform recording"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maOSCWaveformResolution.containsMouse
        MouseArea {
            id: maOSCWaveformResolution
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: oscWaveformResolution
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(s)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: osc_waveform_resolution_bottom; top: osc_waveform_resolution_top;}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + osc_waveform_resolution_bottom + "s to " + osc_waveform_resolution_top + "s")

        onEditingFinished:{
            console.log("OSC waveform resoultion changed by finished editing")
            root.valueChanged("osc_waveform_resolution", parseFloat(oscWaveformResolution.text))
        }

        onTextChanged: {
            if (!oscWaveformResolution.acceptableInput){
                oscWaveformResolution.color = "red"
            }
            else{
                oscWaveformResolution.color = "black"
            }
        }
    }


    Label {
        text: qsTr("Aquisition Time (s)")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the durration of the waveform measurment"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maOSCAcquisitionTime.containsMouse
        MouseArea {
            id: maOSCAcquisitionTime
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: oscAcquisitionTime
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(s)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: osc_aquisition_time_bottom; top: osc_aquisition_time_top;}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + osc_aquisition_time_bottom + "s to " + osc_aquisition_time_top + "s")

        onEditingFinished:{
            console.log("OSC aquisition time chnaged")
            root.valueChanged("osc_aquisition_time", parseFloat(oscAcquisitionTime.text))
        }

        onTextChanged: {
            if (!oscAcquisitionTime.acceptableInput){
                oscAcquisitionTime.color = "red"
            }
            else{
                oscAcquisitionTime.color = "black"
            }
        }
    }

    function displayCurrentParameters(parameterDictionary){
        var channelIndex = parseInt(parameterDictionary["osc_trigger_channel"])
        if (channelIndex == 1){
            oscCH1.checked = true
        }
        else if (channelIndex == 2){
            oscCH2.checked = true
        }
        else if (channelIndex == 3){
            oscCH3.checked = true
        }
        else if (channelIndex == 4){
            oscCH4.checked = true
        }
        oscTriggerVoltage.text = parameterDictionary["osc_trigger_voltage"]
        oscWaveformResolution.text = parameterDictionary["osc_waveform_resolution"]
        oscAcquisitionTime.text = parameterDictionary["osc_aquisition_time"]
    }
}