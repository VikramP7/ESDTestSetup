import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Universal
import QtQml

import PeripheralController

ApplicationWindow{
    id: window
    width: Screen.width * 0.8
    height: Screen.height * 0.8
    Universal.theme: Universal.System
    Universal.accent: Universal.Violet
    title: qsTr("Modular ESD Test Setup Controller")
    visible: true

    property color relayColor: "#00FFF5"
    property color tlpPowerColor: "#ACAED7"
    property color smuColor: "#7D53DE"
    property color vnaColor: "#9776E5"
    property color oscColor: "#BEA9EF"

    // Peripheral Handling. Created from Python.
    PeripheralController {
        id: peripheral_controller
    }
    
    // Configuration Dialog see ConfigurationDialog.qml
    ConfigureDialog{
        id: configuredialog
        
        // emitted any time a value is changed in the dialog to a valid entry
        onSettingChanged: (label, val) => peripheral_controller.storeParameter(label, val)
        // emitted once the dialog is closed
        onFinished: (save_params) => {
            peripheral_controller.saveParameters(save_params)
            window.refreshMainMenu()
        }
    }

    // Add a menubar for the application
    menuBar: MenuBar {
        id: menubartop

        Menu {
            title: qsTr("&File")
            Action { 
                text: qsTr("&Reset")
                onTriggered: peripheral_controller.menubartop_filereset()
            }
            Action { 
                text: qsTr("&Export Data...")
                onTriggered: peripheral_controller.menubartop_fileexport()
            }
    
            MenuSeparator { }
            Action { 
                text: qsTr("&Quit")
                onTriggered:{ 
                    peripheral_controller.menubartop_filequit()
                    Qt.quit()
                }
            }
        }

        Menu {
            title: qsTr("&Configure")
            Action { 
                text: qsTr("&Configure Current...")
                onTriggered: {
                    peripheral_controller.menubartop_configurecurrent()
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                }
            }
            MenuSeparator { }
            Action { 
                text: qsTr("&Export Configuration...")
                onTriggered: peripheral_controller.menubartop_configureexpport()
            }
            Action { 
                text: qsTr("&Import Configuration...")
                onTriggered: peripheral_controller.menubartop_configureimport()
            }
        }

        Menu {
            title: qsTr("&Run")
            Action { 
                text: qsTr("&Start Test")
                onTriggered: peripheral_controller.menubartop_runstart()
            }
            Action { 
                text: qsTr("Sto&p Test")
                onTriggered: peripheral_controller.menubartop_runstop()
            }
        }

        Menu {
            title: qsTr("&Help")
            Action { 
                text: qsTr("&Help...")
                onTriggered: peripheral_controller.menubartop_helphelp()
            }
        }
    }

    function refreshMainMenu(){
        controllerOnlineIndicator.color = peripheral_controller.mainGridMenu_getControllerActiveColor()
        controllerParametersText.text = peripheral_controller.mainGridMenu_getControllerParameters()

        powersupplyOnlineIndicator.color = peripheral_controller.mainGridMenu_getPowersupplyActiveColor()
        powersupplyParametersText.text = peripheral_controller.mainGridMenu_getPowersupplyParameters()

        tlpOnlineIndicator.color = peripheral_controller.mainGridMenu_getTlpActiveColor()
        tlpParametersText.text = peripheral_controller.mainGridMenu_getTlpParameters()

        smuOnlineIndicator.color = peripheral_controller.mainGridMenu_getSmuActiveColor()
        smuParametersText.text = peripheral_controller.mainGridMenu_getSmuParameters()

        vnaOnlineIndicator.color = peripheral_controller.mainGridMenu_getVnaActiveColor()
        vnaParametersText.text = peripheral_controller.mainGridMenu_getVnaParameters()
        
        oscOnlineIndicator.color = peripheral_controller.mainGridMenu_getOscActiveColor()
        oscParametersText.text = peripheral_controller.mainGridMenu_getOscParameters()
        
        re2layText.text = peripheral_controller.mainGridMenu_getRe2layText()
        re1layText.text = peripheral_controller.mainGridMenu_getRe1layText()
        re3layText.text = peripheral_controller.mainGridMenu_getRe3layText()
        re4layText.text = peripheral_controller.mainGridMenu_getRe4layText()
    }

    GridLayout{
        id: mainGridMenu

        columns: 7
        rows: 6

        columnSpacing: 0
        rowSpacing: 0

        anchors.fill: parent

        anchors.margins: 5

        Canvas {
            id: controllerLines00
            
            Layout.columnSpan: 4
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(controllerLines00.width*(3/4)*(1/2), controllerLines00.height);
                context.strokeStyle = "black"
                context.lineTo(controllerLines00.width*(3/4)*(1/2), controllerLines00.height/2);
                context.lineTo(controllerLines00.width, controllerLines00.height/2);
                context.stroke();
            }
        }

        Canvas {
            id: powerLines02
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, powerLines02.height/2);
                context.strokeStyle = "black"
                context.lineTo(powerLines02.width, powerLines02.height/2);
                context.moveTo(powerLines02.width/2, powerLines02.height/2);
                context.lineTo(powerLines02.width/2, powerLines02.height);
                context.stroke();
            }
        }

        Canvas {
            id: tlpLines02
            
            Layout.columnSpan: 2
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, tlpLines02.height/2);
                context.strokeStyle = "black"
                context.lineTo(tlpLines02.width*(3/4), tlpLines02.height/2);
                context.lineTo(tlpLines02.width*(3/4), tlpLines02.height);
                context.stroke();
            }
        }

        Rectangle {
            id: controllerRect10
            
            Layout.columnSpan: 3
            Layout.rowSpan: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            border.color: "Black"
            border.width: 2

            color: "#E3B505"
            
            Text {
                id: controllerTitle
                text: qsTr("Controller")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter

                width: parent.width/2
                height: parent.height/4

                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 72
                font.bold: true
            }

            Rectangle{
                id: controllerOnlineIndicator

                anchors.topMargin: parent.height/20
                anchors.leftMargin: parent.height/20
                anchors.left: parent.left
                anchors.top: parent.top

                width: parent.width/16
                height: this.width
                radius: this.width/4

                border.color: "Black"
                border.width: 1

                color: peripheral_controller.mainGridMenu_getControllerActiveColor()
            }

            Button {
                id: controllerOnlineRefreshButton

                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.left: controllerOnlineIndicator.right
                anchors.top: parent.top

                text: "Refresh"

                onClicked:{
                    peripheral_controller.mainGridMenu_controllerRefresh()
                    window.refreshMainMenu()
                }
            }

            Text {
                id: controllerParametersText

                text: peripheral_controller.mainGridMenu_getControllerParameters()

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/1.5
                height: parent.height/1.5
            }

            Button {
                id: controllerConfigureButton

                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width*(16/18)
                height: parent.height*(4/18)

                text: "Configure"

                onClicked:{
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                    configuredialog.setStackViewIndex(0)
                }
            }
        }

        Rectangle {
            id: blankRect12
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#ffffff"
        }

        Rectangle {
            id: powerSupplyRect13
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2
            
            color: window.tlpPowerColor
            
            Text {
                id: powersupplyTitle
                text: qsTr("Power Supply")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter

                width: parent.width/2
                height: parent.height/4

                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 72
                font.bold: true
            }

            Rectangle{
                id: powersupplyOnlineIndicator

                anchors.topMargin: parent.height/20
                anchors.leftMargin: parent.width/20
                anchors.left: parent.left
                anchors.top: parent.top

                width: parent.width/8
                height: this.width
                radius: this.width/4

                border.color: "Black"
                border.width: 1

                color: peripheral_controller.mainGridMenu_getPowersupplyActiveColor()
            }

            Text {
                id: powersupplyParametersText

                text: peripheral_controller.mainGridMenu_getPowersupplyParameters()

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/1.5
                height: parent.height/1.5
            }

            Button {
                id: powersupplyConfigureButton

                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width*(16/18)
                height: parent.height*(4/18)

                text: "Configure"

                onClicked:{
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                    configuredialog.setStackViewIndex(3)
                }
            }
        }

        Canvas {
            id: powerToTlpLines02
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, powerToTlpLines02.height/2);
                context.strokeStyle = "black"
                context.lineTo(powerToTlpLines02.width, powerToTlpLines02.height/2);
                context.stroke();
            }
        }

        Rectangle {
            id: tlpRect13
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2
            
            color: window.tlpPowerColor
            
            Text {
                id: tlpTitle
                text: qsTr("TLP")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter

                width: parent.width/2
                height: parent.height/4

                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 72
                font.bold: true
            }

            Rectangle{
                id: tlpOnlineIndicator

                anchors.topMargin: parent.height/20
                anchors.leftMargin: parent.width/20
                anchors.left: parent.left
                anchors.top: parent.top

                width: parent.width/8
                height: this.width
                radius: this.width/4

                border.color: "Black"
                border.width: 1

                color: peripheral_controller.mainGridMenu_getTlpActiveColor()
            }

            Text {
                id: tlpParametersText

                text: peripheral_controller.mainGridMenu_getTlpParameters()

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/1.5
                height: parent.height/1.5
            }

            Button {
                id: tlpConfigureButton

                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width*(16/18)
                height: parent.height*(4/18)

                text: "Configure"

                onClicked:{
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                    configuredialog.setStackViewIndex(3)
                }
            }
        }

        Rectangle {
            id: blankRect22
            
            Layout.columnSpan: 3
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#ffffff"
        }

        Canvas {
            id: tlpToRe1layLines25
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(tlpToRe1layLines25.width/2, 0);
                context.strokeStyle = "black"
                context.lineTo(tlpToRe1layLines25.width/2, powerToTlpLines02.height);
                context.stroke();
            }
        }

        Canvas {
            id: controllerToDevicesLines30
            
            Layout.columnSpan: 1
            Layout.rowSpan: 3
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(controllerToDevicesLines30.width/2, 0);
                context.strokeStyle = "black"
                context.lineTo(controllerToDevicesLines30.width/2, controllerToDevicesLines30.height*(5/6));
                context.lineTo(controllerToDevicesLines30.width, controllerToDevicesLines30.height*(5/6));
                context.moveTo(controllerToDevicesLines30.width/2, controllerToDevicesLines30.height*(1/6))
                context.lineTo(controllerToDevicesLines30.width, controllerToDevicesLines30.height*(1/6));
                context.moveTo(controllerToDevicesLines30.width/2, controllerToDevicesLines30.height*(3/6))
                context.lineTo(controllerToDevicesLines30.width, controllerToDevicesLines30.height*(3/6));
                context.stroke();
            }
        }

        Rectangle {
            id: smuRect31
            
            Layout.columnSpan: 2
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            // fake boarder rectangles
            Rectangle{
                width: 2
                height: parent.height
                color: "#000000"
                anchors.right: parent.right
            }

            Rectangle{
                width: 2
                height: parent.height
                color: "#000000"
                anchors.left: parent.left
            }

            color: window.smuColor
            
            Text {
                id: smuTitle
                text: qsTr("SMU")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 0

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/2
                height: parent.height/4

                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 72
                font.bold: true
            }

            Rectangle{
                id: smuOnlineIndicator

                anchors.topMargin: parent.height/20
                anchors.leftMargin: parent.height/20
                anchors.left: parent.left
                anchors.top: parent.top

                width: parent.width/16
                height: this.width
                radius: this.width/4

                border.color: "Black"
                border.width: 1

                color: peripheral_controller.mainGridMenu_getSmuActiveColor()
            }

            Button {
                id: smuOnlineRefreshButton

                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.left: smuOnlineIndicator.right
                anchors.top: parent.top

                text: "Refresh"

                onClicked:{
                    peripheral_controller.mainGridMenu_smuRefresh()
                    window.refreshMainMenu()
                }
            }

            Text {
                id: smuParametersText

                text: peripheral_controller.mainGridMenu_getSmuParameters()

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/1.5
                height: parent.height/1.5
            }

            Button {
                id: smuConfigureButton

                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width*(16/18)
                height: parent.height*(4/18)

                text: "Configure"

                onClicked:{
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                    configuredialog.setStackViewIndex(1)
                }
            }
        }

        Canvas {
            id: smuToRe2layLine33
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, smuToRe2layLine33.height/2);
                context.strokeStyle = "black"
                context.lineTo(smuToRe2layLine33.width, smuToRe2layLine33.height/2);
                context.stroke();
            }
        }

        Rectangle {
            id: re2layRect34
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2

            color: window.relayColor
            
            Text {
                id: re2layText
                text: qsTr("Relay 2 (re2lay)")
                anchors.centerIn: parent
            }
        }

        Canvas {
            id: re2layToDutLine35
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, smuToRe2layLine33.height/2);
                context.strokeStyle = "black"
                context.lineTo(smuToRe2layLine33.width/2, smuToRe2layLine33.height/2);
                context.lineTo(smuToRe2layLine33.width/2, smuToRe2layLine33.height);
                context.stroke();
            }
        }

        Rectangle {
            id: re1layRect36
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2

            color: window.relayColor
            
            Text {
                id: re1layText
                text: qsTr("Relay 1 (re1lay)")
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: vnaRect41
            
            Layout.columnSpan: 2
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2

            // boarder fixing rect
            Rectangle{
                width: parent.width-7
                height: 3
                color: window.vnaColor
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
            }

            color: window.vnaColor

            Text {
                id: vnaTitle
                text: qsTr("VNA")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 0

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/2
                height: parent.height/4

                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 72
                font.bold: true
            }

            Rectangle{
                id: vnaOnlineIndicator

                anchors.topMargin: parent.height/20
                anchors.leftMargin: parent.height/20
                anchors.left: parent.left
                anchors.top: parent.top

                width: parent.width/16
                height: this.width
                radius: this.width/4

                border.color: "Black"
                border.width: 1

                color: peripheral_controller.mainGridMenu_getVnaActiveColor()
            }

            Button {
                id: vnaOnlineRefreshButton

                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.left: vnaOnlineIndicator.right
                anchors.top: parent.top

                text: "Refresh"

                onClicked:{
                    peripheral_controller.mainGridMenu_vnaRefresh()
                    window.refreshMainMenu()
                }
            }

            Text {
                id: vnaParametersText

                text: peripheral_controller.mainGridMenu_getVnaParameters()

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/1.5
                height: parent.height/1.5
            }

            Button {
                id: vnaConfigureButton

                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width*(16/18)
                height: parent.height*(4/18)

                text: "Configure"

                onClicked:{
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                    configuredialog.setStackViewIndex(2)
                }
            }
        }

        Canvas {
            id: vnaToRe3layLine43
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, vnaToRe3layLine43.height/2);
                context.strokeStyle = "black"
                context.lineTo(vnaToRe3layLine43.width, vnaToRe3layLine43.height/2);
                context.stroke();
            }
        }

        Rectangle {
            id: re3layRect44
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            // fake boarder rectangles
            Rectangle{
                width: 2
                height: parent.height
                color: "#000000"
                anchors.right: parent.right
            }

            Rectangle{
                width: 2
                height: parent.height
                color: "#000000"
                anchors.left: parent.left
            }

            color: window.relayColor
            
            Text {
                id: re3layText
                text: qsTr("Relay 3 (re3lay)")
                anchors.centerIn: parent
            }
        }

        Canvas {
            id: re3layToDutLine45
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(re3layToDutLine45.width/2, 0);
                context.strokeStyle = "black"
                context.lineTo(re3layToDutLine45.width/2, re3layToDutLine45.height);
                context.moveTo(0, re3layToDutLine45.height/2);
                context.lineTo(re3layToDutLine45.width/2, re3layToDutLine45.height/2);
                context.stroke();
            }
        }

        Canvas {
            id: re1layToDutLines46
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(re1layToDutLines46.width/2, 0);
                context.strokeStyle = "black"
                context.lineTo(re1layToDutLines46.width/2, re1layToDutLines46.height);
                context.stroke();
            }
        }

        Rectangle {
            id: oscRect51
            
            Layout.columnSpan: 2
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2

            color: window.oscColor
            
            Text {
                id: oscTitle
                text: qsTr("Oscilloscope")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 0

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/2
                height: parent.height/4

                wrapMode: Text.WordWrap
                fontSizeMode: Text.Fit
                minimumPixelSize: 10
                font.pixelSize: 72
                font.bold: true
            }

            Rectangle{
                id: oscOnlineIndicator

                anchors.topMargin: parent.height/20
                anchors.leftMargin: parent.height/20
                anchors.left: parent.left
                anchors.top: parent.top

                width: parent.width/16
                height: this.width
                radius: this.width/4

                border.color: "Black"
                border.width: 1

                color: peripheral_controller.mainGridMenu_getOscActiveColor()
            }

            Button {
                id: oscOnlineRefreshButton

                anchors.topMargin: 10
                anchors.leftMargin: 10
                anchors.left: oscOnlineIndicator.right
                anchors.top: parent.top

                text: "Refresh"

                onClicked:{
                    peripheral_controller.mainGridMenu_oscRefresh()
                    window.refreshMainMenu()
                }
            }

            Text {
                id: oscParametersText

                text: peripheral_controller.mainGridMenu_getOscParameters()

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                width: parent.width/1.5
                height: parent.height/1.5
            }

            Button {
                id: oscConfigureButton

                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                width: parent.width*(16/18)
                height: parent.height*(4/18)

                text: "Configure"

                onClicked:{
                    configuredialog.openConfiguration(peripheral_controller.getCurrentParameters())
                    configuredialog.setStackViewIndex(0)
                }
            }
        }

        Canvas {
            id: oscToRe4layLine53
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, oscToRe4layLine53.height/2);
                context.strokeStyle = "black"
                context.lineTo(oscToRe4layLine53.width, oscToRe4layLine53.height/2);
                context.stroke();
            }
        }

        Rectangle {
            id: re4layRect54
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2

            color: window.relayColor
            
            Text {
                id: re4layText
                text: qsTr("Relay 4 (re4lay)")
                anchors.centerIn: parent
            }
        }

        Canvas {
            id: re4layToDutLine55
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                context.beginPath();
                context.lineWidth = 2;
                context.moveTo(0, re4layToDutLine55.height/2);
                context.strokeStyle = "black"
                context.lineTo(re4layToDutLine55.width, re4layToDutLine55.height/2);
                context.moveTo(re4layToDutLine55.width/2, 0);
                context.lineTo(re4layToDutLine55.width/2, re4layToDutLine55.height/2);
                context.stroke();
            }
        }

        Rectangle {
            id: dutRect56
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "Black"
            border.width: 2

            color: "#bbffb6"
            
            Text {
                id: dutText
                text: qsTr("DUT")
                anchors.centerIn: parent
            }
        }

        // next two rectangles are cheap fix for spacing issue
        Rectangle {
            id: rect01
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.preferredHeight: 0.01
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#ffffff"
        }
        Rectangle {
            id: rect02
            
            Layout.columnSpan: 1
            Layout.rowSpan: 1
            Layout.preferredHeight: 0.01
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#ffffff"
        }
    }
}