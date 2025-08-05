from PySide6.QtCore import (QAbstractListModel, QEnum, Qt, QModelIndex, Slot, QByteArray)
from PySide6.QtQml import QmlElement

import pyvisa
from VisaResource import VisaResource
from OscilloscopeInterface import Oscilloscope
from OssillaSmu import OscillaSMU
import xtralien
import serial
from serial.tools import list_ports

QML_IMPORT_NAME = "PeripheralController"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
class PeripheralController(QAbstractListModel):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)

        # --DEVICES and helper variables--
        # create global resource manager to use for all potential visa devices (many the VNA)
        self.visa_resource_manager = pyvisa.ResourceManager()
        self.oscilloscope = Oscilloscope(self.visa_resource_manager)

        self.smu = OscillaSMU()
        self.com_ports = [] # a list of strings for active com ports eg. 'COM2'

        self.vna = None

        self.microcontroller = None

        # this list should hold if devices are connected or not
        self.device_activity_dict = {
            "osc": 0,
            "smu": 0,
            "tlp": 0,
            "vna": 0,
            "teensy": 0,
            "powersupply":0
        }

        # formatting properties
        self.disconnected_red = "#DB324D"
        self.active_green = "#00916E"

        # create dictionary of all device parameters
        self.parameter_dictionary = {
            "osc_trigger_channel": 1,
            "osc_trigger_voltage": 1,
            "osc_waveform_resolution": 0.001,
            "osc_acquisition_time": 1.0,

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
        # END CONSTRUCTOR

    """----------------- General Application Functions ----------------"""
    def peripheral_controller_quit(self):
        """
        Cleans up when closing the peripheral controller and/or ending the program.

        Args:
            None

        Returns:
            None

    """
        if self.oscilloscope != None:
            self.oscilloscope.close()
        if self.smu != None:
            self.smu.close()
        if self.vna != None:
            self.vna.close()
        if self.microcontroller != None:
            self.microcontroller.close()


    """----------------- Parameter Updating Signal Receivers -------------"""
    @Slot(str, float)
    def storeParameter(self, parameter_name: str, parameter_value: float):
        """
        Stores a given parameter value into into spot in the temporary dictionary using the described parameter_name.
        This is to store all temporary values for before the user either choses to save or discard changes

        Args:
            parameter_name (str) :
                The dictionary key for where the data will be stored
            parameter_value (float) :
                The data that should be stored into the key in the temp. dict (parameter_dictionary_temp)

        Returns:
            None

        """
        print("Updated Parameter: " + parameter_name + " = " + str(parameter_value) )
        self.parameter_dictionary_temp[parameter_name] = parameter_value

    
    @Slot(bool)
    def saveParameters(self, save):
        """
        If save is true, saves all parameters from temporary parameter dictionary (self.parameter_dictionary_temp) into the actual parameter dictionary so
        they can be used for setting peripheral device properties.
        Other wise (save is false), disregards any changes made and maintains original parameters in dict.

        Args:
            save (bool) :
                If true temporary values are saved to actual parameter dictionary (parameter_dictionary)

        Returns:
            None

        """
        if not save:
            print("Parameter changes discarded")
            return
        
        for key in self.parameter_dictionary_temp.keys():
            self.parameter_dictionary[key] = self.parameter_dictionary_temp[key]
        print("parameters saved")
        # take all changed temporary variables and make permanent sending messages to peripherals to do so

    @Slot(result=dict)
    def getCurrentParameters(self):
        """
        Returns the current parameters dictionary
        """
        return self.parameter_dictionary
    
    # ----------------- Main Grid Menu Display ----------------
    @Slot(result=str)
    def mainGridMenu_getControllerParameters(self):
        """
        ONLY called by Main.qml to respond to refresh events to update controllerParametersText
        """
        report_str = "Controller: " + ("Active" if self.device_activity_dict["teensy"] == 1 else "Disconnected")
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getControllerActiveColor(self):
        """
        ONLY called by Main.qml to respond to refresh events to update controllerOnlineIndicator
        """
        return (self.active_green if self.device_activity_dict["teensy"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getPowersupplyParameters(self):
        """
        ONLY called by Main.qml to respond to refresh events to update powersupplyParametersText
        """
        report_str = "Power Supply: " + ("Active" if self.device_activity_dict["powersupply"] == 1 else "Disconnected")
        report_str +="\nVoltage: " + str(self.current_value_dictionary["powersupply_charge_voltage"])
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getPowersupplyActiveColor(self):
        """
        ONLY called by Main.qml to respond to refresh events to update powersupplyOnlineIndicator
        """
        return (self.active_green if self.device_activity_dict["powersupply"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getTlpParameters(self):
        """
        ONLY called by Main.qml to respond to refresh events to update tlpParametersText
        """
        report_str = "TLP: " + ("Active" if self.device_activity_dict["tlp"] == 1 else "Disconnected")
        report_str +="\nRise Time: " + str(self.current_value_dictionary["tlp_rise_time"])
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getTlpActiveColor(self):
        """
        ONLY called by Main.qml to respond to refresh events to update tlpOnlineIndicator
        """
        return (self.active_green if self.device_activity_dict["tlp"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getSmuParameters(self):
        """
        ONLY called by Main.qml to respond to refresh events to update smuParametersText
        """
        report_str = "TLP: " + ("Active" if self.device_activity_dict["smu"] == 1 else "Disconnected")
        report_str +="\nVoltage: " + str(self.current_value_dictionary["smu_voltage"])
        report_str +="\nCurrent: " + str(self.current_value_dictionary["smu_current"])
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getSmuActiveColor(self):
        """
        ONLY called by Main.qml to respond to refresh events to update smuOnlineIndicator
        """
        return (self.active_green if self.device_activity_dict["smu"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getVnaParameters(self):
        """
        ONLY called by Main.qml to respond to refresh events to update vnaParametersText
        """
        report_str = "VNA: " + ("Active" if self.device_activity_dict["vna"] == 1 else "Disconnected")
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getVnaActiveColor(self):
        """
        ONLY called by Main.qml to respond to refresh events to update vnaOnlineIndicator
        """
        return (self.active_green if self.device_activity_dict["vna"] == 1 else self.disconnected_red)
    
    @Slot(result=str)
    def mainGridMenu_getOscParameters(self):
        """
        ONLY called by Main.qml to respond to refresh events to update oscParametersText
        """
        report_str = "Oscilloscope: " + ("Active" if self.device_activity_dict["osc"] == 1 else "Disconnected")
        return report_str
    
    @Slot(result=str)
    def mainGridMenu_getOscActiveColor(self):
        """
        ONLY called by Main.qml to respond to refresh events to update oscOnlineIndicator
        """
        return (self.active_green if self.device_activity_dict["osc"] == 1 else self.disconnected_red)
    
    """
    Following functions ONLY called by Main.qml to respond to refresh events to update reNlayText
    """
    @Slot(result=str)
    def mainGridMenu_getRe1layText(self):
        return "Relay 1 (re1lay)"
    
    @Slot(result=str)
    def mainGridMenu_getRe2layText(self):
        return "Relay 2 (re2lay)"
    
    @Slot(result=str)
    def mainGridMenu_getRe3layText(self):
        return "Relay 3 (re3lay)"
    
    @Slot(result=str)
    def mainGridMenu_getRe4layText(self):
        return "Relay 4 (re4lay)"
    
    @Slot(int)
    def mainGridMenu_getSmuPortNum(self, port_num_index):
        """
        Called by Main.qml when smu is refreshed or the combo box value is changed

        This updates the comport that the smu will connect to and attempt a connection
        """
        # early return if no com port devices are connected
        if len(self.com_ports)<=0:
            return
        self.smu.set_com_port(self.com_ports[port_num_index])
        print("Attempting connection to smu on COM port: " + str(port_num_index))
        self.smu.connect()

    @Slot(int)
    def mainGridMenu_getControllerPortNum(self, port_num_index):
        """
        Called by Main.qml when controller is refreshed or the combo box value is changed

        This updates the comport that the controller will connect to and attempt a connection
        """
        # early return if no com port devices are connected
        if len(self.com_ports)<=0:
            return
        # TODO set_com_port hasn't been written yet
        # self.controller.set_com_port(self.com_ports[port_num_index])
        print("Attempting connection to controller on COM port: " + str(port_num_index))
        # TODO set_com_port hasn't been written yet
        #self.controller.connect(com_port=1)


    # ---------------- Main Grid Menu Buttons -----------------
    @Slot()
    def mainGridMenu_controllerRefresh(self):
        """
        Called by Main.qml ONLY when controller refresh button is clicked
        """
        print("Controller Refresh clicked")

        # TODO VERY POORLY WRITTEN CODE necessary functions for microcontroller haven't been written yet
        connect = False
        if self.microcontroller == None:
            # the microcontroller (teensy?) is not connected do connection procedure
            connect = True
        else:
            # the microcontroller is theoretically connected so check this 
            connect = not self.microcontroller.check_connection(self, silent=True)

        if connect:
            #do connection procedure
            #self.microcontroller.connect() hasn't been written yet
            pass

    @Slot()
    def mainGridMenu_smuRefresh(self):
        """
        Called by Main.qml ONLY when smu refresh button is clicked

        Checks com ports to update self.com_ports list with the available com ports
        Attempts connection to SMU
        """
        print("SMU Refresh clicked")
        if len(self.com_ports) < 1:
            print("No Com Ports connected")
        elif not self.smu.check_connection():
            #do connection procedure
            if self.smu.connect():
                self.device_activity_dict["smu"] = 1
                print("Attempted and succeeded to connect to SMU")
            else:
                self.device_activity_dict["smu"] = 0
                print("Attempted and failed to connect to SMU")
        else:
            self.device_activity_dict["smu"] = 1

    @Slot()
    def mainGridMenu_vnaRefresh(self):
        """
        Called by Main.qml ONLY when vna refresh button is clicked

        Attempts connection to VNA
        """
        print("VNA Refresh clicked")
        print("MORE CODE MUST BE WRITTEN HERE TO IMPLEMENT THIS FEATURE")

    @Slot()
    def mainGridMenu_oscRefresh(self):
        """
        Called by Main.qml ONLY when oscilloscope refresh button is clicked

        Checks com ports to update self.com_ports list with the available com ports
        Attempts connection to oscilloscope
        """
        print("Oscilloscope Refresh clicked")

        if not self.oscilloscope.check_connection():
            #do connection procedure
            if self.oscilloscope.connect():
                self.device_activity_dict["osc"] = 1
                print("Attempted and succeeded to connect to Oscilloscope")
            else:
                self.device_activity_dict["osc"] = 0
                print("Attempted and failed to connect to Oscilloscope")
        else:
            self.device_activity_dict["osc"] = 1

    
    # ------------------- Data Functions ----------------------
    @Slot()
    def refreshComPorts(self):
        """
        Called by Main.qml and others

        Sets self.com_ports list to the currently connected com ports
        Please see: https://pyserial.readthedocs.io/en/latest/tools.html
        """
        com_port_objects = list_ports.comports()
        self.com_ports = []
        for com_port in com_port_objects:
            self.com_ports.append(com_port.name)

    @Slot(result=list)
    def availableComPorts(self):
        """
        Called by Main.qml

        Returns the available com ports after refreshing the com_ports list
        Please see: https://pyserial.readthedocs.io/en/latest/tools.html
        """
        self.refreshComPorts()
        return self.com_ports
    
    
    # ------------------- Menu Bar Buttons --------------------

    # TODO Much of the functionality of each of these buttons needs to be implemented
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
    def window_quit(self):
        print("Window Closing")

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