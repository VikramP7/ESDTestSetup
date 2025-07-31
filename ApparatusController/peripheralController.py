from PySide6.QtCore import (QAbstractListModel, QEnum, Qt, QModelIndex, Slot, QByteArray)
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "PeripheralController"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class PeripheralController(QAbstractListModel):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)

        # formating properties
        self.disconnected_red = "#DB324D"
        self.active_green = "#00916E"

        # create dictionary of all device parameters
        self.parameter_dictionary = {
            "osc_trigger_channel": 1,
            "osc_trigger_voltage": 1,
            "osc_waveform_resolution": 0.001,
            "osc_aquisition_time": 1.0,

            "smu_voltage_max": 5.0,
            "smu_voltage_min": 0.0,
            "smu_voltage_increment": 0.1,
            "smu_settle_time": 0.01,
            "smu_current_max": 0.02,

            "tlp_voltage_max": 2000,
            "tlp_voltage_min": 500,
            "tlp_voltage_increment": 500,

            "vna_freq_max": 1000000,
            "vna_freq_min": 100000,
            "vna_freq_resolution": 1000
        }

        self.parameter_dictionary_temp = self.parameter_dictionary.copy()

        self.current_value_dictionary = {
            "smu_voltage": 5.0,
            "smu_current": 0.0,

            "powersupply_charge_voltage": 2000,
            "tlp_rise_time": "1ns"
        }

        self.device_activity_dict = {
            "osc": 0,
            "smu": 0,
            "tlp": 0,
            "vna": 0,
            "teensy": 0,
            "powersupply":0
        }
    
    @Slot(str, float)
    def storeParameter(self, parameter_name: str, parameter_value: float):
        print("Updated Parameter: " + parameter_name + " = " + str(parameter_value) )
        self.parameter_dictionary_temp[parameter_name] = parameter_value

    
    @Slot(bool)
    def saveParameters(self, save):
        if not save:
            print("Parameter changes discarded")
            return
        
        for key in self.parameter_dictionary_temp.keys():
            self.parameter_dictionary[key] = self.parameter_dictionary_temp[key]
        print("parameters saved")
        # take all changed temporary variables and make perminant sending messages to periferals to do so

    @Slot(result=dict)
    def getCurrentParameters(self):
        return self.parameter_dictionary
    
    # ----------------- Main Grid Menu Display ----------------
    @Slot(result=str)
    def mainGridMenu_getControllerParameters(self):
        report_str = "Controller: " + ("Active" if self.device_activity_dict["teensy"] == 1 else "Disconnected")
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getControllerActiveColor(self):
        return (self.active_green if self.device_activity_dict["teensy"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getPowersupplyParameters(self):
        report_str = "Power Supply: " + ("Active" if self.device_activity_dict["powersupply"] == 1 else "Disconnected")
        report_str +="\nVoltage: " + str(self.current_value_dictionary["powersupply_charge_voltage"])
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getPowersupplyActiveColor(self):
        return (self.active_green if self.device_activity_dict["powersupply"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getTlpParameters(self):
        report_str = "TLP: " + ("Active" if self.device_activity_dict["tlp"] == 1 else "Disconnected")
        report_str +="\nRise Time: " + str(self.current_value_dictionary["tlp_rise_time"])
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getTlpActiveColor(self):
        return (self.active_green if self.device_activity_dict["tlp"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getSmuParameters(self):
        report_str = "TLP: " + ("Active" if self.device_activity_dict["smu"] == 1 else "Disconnected")
        report_str +="\nVoltage: " + str(self.current_value_dictionary["smu_voltage"])
        report_str +="\nCurrent: " + str(self.current_value_dictionary["smu_current"])
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getSmuActiveColor(self):
        return (self.active_green if self.device_activity_dict["smu"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getVnaParameters(self):
        report_str = "VNA: " + ("Active" if self.device_activity_dict["vna"] == 1 else "Disconnected")
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getVnaActiveColor(self):
        return (self.active_green if self.device_activity_dict["vna"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getOscParameters(self):
        report_str = "VNA: " + ("Active" if self.device_activity_dict["osc"] == 1 else "Disconnected")
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getOscActiveColor(self):
        return (self.active_green if self.device_activity_dict["osc"] == 1 else self.disconnected_red)
    
    

    # ---------------- Main Grid Menu Buttons -----------------
    @Slot()
    def mainGridMenu_controllerRefresh(self):
        print("Controller Refresh clicked")

    @Slot()
    def mainGridMenu_smuRefresh(self):
        print("SMU Refresh clicked")

    @Slot()
    def mainGridMenu_vnaRefresh(self):
        print("VNA Refresh clicked")

    @Slot()
    def mainGridMenu_oscRefresh(self):
        print("Oscilloscope Refresh clicked")
    
    
    # ------------------- Menu Bar Buttons --------------------
    @Slot()
    def menubartop_filereset(self):
        print("File reset clicked")

        
    @Slot()
    def menubartop_fileexport(self):
        print("File export clicked")

    @Slot()
    def menubartop_filequit(self):
        print("File Signal Handler Quit")


    @Slot()
    def menubartop_configurecurrent(self):
        print("Configure current")
    
    @Slot()
    def menubartop_configureexpport(self):
        print("Configure Export")

    @Slot()
    def menubartop_configureimport(self):
        print("Configure Import")

    @Slot()
    def menubartop_runstart(self):
        print("Run Start")
        
    @Slot()
    def menubartop_runstop(self):
        print("Run Stop")

    @Slot()
    def menubartop_helphelp(self):
        print("help help")