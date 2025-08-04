import xtralien

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
            self.device.close()
            self.device = None
            self.device_name = "No Device Connected!"
            print("Device Disconnected")


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

        if not silent:
            print("Connected to: " + self.device_name)
        return True
