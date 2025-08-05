import xtralien
import serial
import time

class OscillaSMU():
    """
    Class for connection to oscilloscope using VISA and SCPI commands
    Commands are for the R&S®RTO6 Oszilloskop | Rohde & Schwarz
    Reference for this class is available here https://www.rohde-schwarz.com/uk/manual/r-s-rto6-user-manual-manuals_78701-1091264.html

    Child class of VisaResource

    Attributes:
        (private) scope : pyvisa resource 
            The scope object for interfacing
        scope_name : str
            ID string of scope connected
    """
    def __init__(self, com_port=1):
        self.com_port = com_port
        self.device = None
        self.device_name = "No Device Connected!"

    
    def close(self):
        """
        Closes connection with any connected device

        Args:
            none

        Returns:
            none
        """
        if self.device != None:
            self.device['smu1'].set.voltage(0, response=0)
            self.device['smu2'].set.voltage(0, response=0)
            time.sleep(0.1)
            self.device['smu1'].set.enabled(False, response=0)
            self.device['smu2'].set.enabled(False, response=0)
            self.device.close()
            self.device = None
            self.device_name = "No Device Connected!"
            print("Device Disconnected")

    def set_com_port(self, com_port):
        self.com_port = com_port

    def get_com_port(self, com_port):
        return self.com_port

    def check_connection(self, silent=False):
        """
        Checks the connection status of a currently connected device, prints connection status to terminal

        Args:
            silent (boolean): [optional]
                default silent=False
                suppresses console messages if true

        Returns:
            boolean: true if scope is connected, false if not connected
        """
        if self.device == None:
            if not silent:
                print("No Devices Connected")
            return False
        
        try:
            self.device_name = "SMU"+str(self.device.cloi.version()) # pg. 6 smu programming guide
        except serial.serialutil.SerialException:
            print("Failed to get response from SMU")
            self.close(self)
            return False

        if not silent:
            print("Connected to: " + self.device_name)
        return True
    

    def connect(self, com_port = -1):
        """
        Connects to a resource (oscilloscope/spectrum analyzer) by index in available resource list or by ID
        If not index or device ID is specified connection is made to first resource; device_index = 0 

        Args:
            device_index (default=0 int) : [optional] 
                The resource index from list of available resources that should be connected to
            device_id (str): [optional]
                The resource ID that should be connected to

        Returns:
            Bool : If connection fails returns false. If connection is successful returns true 
        """

        if com_port == -1:
            com_port = self.com_port

        # check to see if provided ID is valid if so set index
        try:
            com_port = str(com_port)
            if com_port.count("COM") < 1:
                print("Invalid Com port Specified, no connection attempted to " + com_port)
                return
        except ValueError:
            print("Invalid Com port Specified")
            return

        self.device = None
        # try to connect to device
        try:
            self.device = xtralien.Device(com_port)
        except serial.serialutil.SerialException:
            print("Failed to connect to COM" + str(com_port))
            return False
        
        self.com_port = com_port

        try:
            self.device_name = "SMU"+str(self.device.cloi.version()) # pg. 6 smu programming guide
        except serial.serialutil.SerialException:
            print("Failed to get response from SMU")
            self.close(self)
            return False
        print("Successfully connected to SMU on port: " + self.com_port)
        return True
    

    def disconnect(self):
        """disconnects from any connected SMUs"""
        self.close()

    def make_measurement(self, voltage, channel="smu1"):
        """
        Given a provided voltage and optionally the channel (default is 'smu1') the smu takes a current and voltage reading

        Args:
            voltage (float) :
                The voltage the channel should be set to 
            channel (str) : [optional]
                default channel='smu1'
                The channel in which the reading will occur, either 'smu1' or 'smu2'

        Returns:
            float, float : the value of the voltage and current from recording

        """
        # TODO make check to ensure that provided voltage is within valid range
        try:
            voltage, current = self.device[channel].oneshot(voltage)[0]
        except serial.serialutil.SerialException:
            print("SMU: failed to make reading as device has been disconnected")
        return voltage, current

    def set_voltage(self, voltage=0, channel='smu1'):
        """
        Given a provided voltage and optionally the channel (default is 'smu1') the smu sets the output voltage to the specifed voltage

        Args:
            voltage (float) : [optional]
                The voltage the channel should be set to. By default the smu voltage is 0
            channel (str) : [optional]
                default channel='smu1'
                The channel in which the reading will occur, either 'smu1' or 'smu2'

        Returns:
            none

        """
        try:
            self.device[channel].set.voltage(voltage, response=0)
        except serial.serialutil.SerialException:
            print("SMU: failed to set voltage as device has been disconnected")
