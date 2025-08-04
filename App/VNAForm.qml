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

    property var vna_freq_max_bottom: 1
    property var vna_freq_max_top: 10000000

    property var vna_freq_min_bottom: 1
    property var vna_freq_min_top: 1000000

    property var vna_freq_resolution_bottom: 1
    property var vna_freq_resolution_top: 10000
    
    Label {
        text: qsTr("VNA Sweep Frequency Range (Hz): ")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set the frequency range for the VNA to sweep through"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maVNAFreqRange.containsMouse
        MouseArea {
            id: maVNAFreqRange
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    RowLayout{
        TextField {
            id: vnaFreqMax
            focus: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

            inputMethodHints: Qt.ImhFormattedNumbersOnly
            placeholderText: qsTr("max (Hz)")
            validator: DoubleValidator {bottom: vna_freq_max_bottom; top: vna_freq_max_top}

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("From " + vna_freq_max_bottom + "Hz to " + vna_freq_max_top + "Hz")

            onEditingFinished:{
                console.log("VNA Frequency max changed")
                root.valueChanged("vna_freq_max", parseFloat(vnaFreqMax.text))
            }

            onTextChanged: {
            if (!vnaFreqMax.acceptableInput){
                vnaFreqMax.color = "red"
            }
            else{
                vnaFreqMax.color = "black"
            }
        }
        }

        TextField {
            id: vnaFreqMin
            focus: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

            inputMethodHints: Qt.ImhFormattedNumbersOnly
            placeholderText: qsTr("min (Hz)")
            validator: DoubleValidator {bottom: vna_freq_min_bottom; top: vna_freq_min_top}

            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("From " + vna_freq_min_bottom + "Hz to " + vna_freq_min_top + "Hz")

            onEditingFinished:{
                console.log("VNA Frequency min changed")
                root.valueChanged("vna_freq_min", parseFloat(vnaFreqMin.text))
            }

            onTextChanged: {
            if (!vnaFreqMin.acceptableInput){
                vnaFreqMin.color = "red"
            }
            else{
                vnaFreqMin.color = "black"
            }
        }
        }
    }

    
    Label {
        text: qsTr("Frequency Resolution (Hz):")
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        ToolTip.text: "Set frequency resolution"
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: maVNAResolution.containsMouse
        MouseArea {
            id: maVNAResolution
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    TextField {
        id: vnaFreqResolution
        focus: true
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignBaseline

        placeholderText: qsTr("(V)")
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {bottom: vna_freq_resolution_bottom; top: vna_freq_resolution_top}

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("From " + vna_freq_resolution_bottom + "Hz to " + vna_freq_resolution_top + "Hz")

        onEditingFinished:{
            console.log("TLP voltage Increment Changed")
            root.valueChanged("vna_freq_resolution", parseFloat(vnaFreqResolution.text))
        }

        onTextChanged: {
            if (!vnaFreqResolution.acceptableInput){
                vnaFreqResolution.color = "red"
            }
            else{
                vnaFreqResolution.color = "black"
            }
        }
    }

    // when the form is opened current values are populated in the form fields
    function displayCurrentParameters(parameterDictionary){
        vnaFreqMax.text = parameterDictionary["vna_freq_max"]
        vnaFreqMin.text = parameterDictionary["vna_freq_min"]
        vnaFreqResolution.text = parameterDictionary["vna_freq_resolution"]
    }
}