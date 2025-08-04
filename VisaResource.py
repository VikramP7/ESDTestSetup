import pyvisa
from enum import Enum
import time
import numpy as np


def bytes_to_float32(four_bytes):
        """
        Converts a 4 byte argument in IEEE 754 standard: binary32 into a float decimal result

        Args:
            four_bytes (bytes): the binary value that will be converted

        Returns:
            float: the IEEE 754 standard result of the binary value provided

        """
        """
        byte_4 = int(four_bytes[3])
        byte_3 = int(four_bytes[2])
        byte_2 = int(four_bytes[1])
        byte_1 = int(four_bytes[0])

        b_sign = byte_4 & 0b10000000
        sign = -1 if b_sign != 0 else 1
        b_exp = ((byte_4 & 0b01111111) << 1) | (byte_3 >> 7)
        exponent = b_exp - 127
        b_frac = ((byte_3 & 0b01111111)<<16) | (byte_2<<8) | byte_1
        fraction = 1 if b_exp !=0 else 0
        for i in range(23): # 23 fractional bits
            mask = (1<<(22-i))
            multiplier = 2**(-(i+1))
            fraction += (2**(-(i+1))) if (b_frac & (1<<(22-i))) != 0 else 0

        float_val = sign*(2**exponent)*fraction

        return float_val
        """

        # faster way without spelling everything out (as much):
        byte_4 = int(four_bytes[3])
        byte_3 = int(four_bytes[2])

        sign = -1 if byte_4 & 0b10000000 != 0 else 1
        exponent = (((byte_4 & 0b01111111) << 1) | (byte_3 >> 7)) - 127
        b_frac = ((byte_3 & 0b01111111)<<16) | (int(four_bytes[1])<<8) | int(four_bytes[0])
        fraction = 0 if exponent == -127 else 1
        for i in range(23): # 23 fractional bits
            fraction += (2**(-(i+1))) if (b_frac & (1<<(22-i))) != 0 else 0

        return sign*(2**exponent)*fraction


def parse_raw_bytes_data(raw_data=None, path="./output.lmao", silent=False):
    """
    Parses raw waveform data retrieved from the oscilloscope in the REAL,32 described on pg. 1399 of the R&S RTO6 UserManual 
    Adhering to 32-Bit IEEE 754 Floating Point Format 
    or from the RIGOL DSA800 series Spectrum Analyzer in Real

    Args:
        raw_data (bytes) : [optional]
            The raw_read of the data the scope provides
        path (str) : [optional]
            The save file containing the scope waveform data
        silent (boolean) : [optional] default=False
            Specifies if status remarks are made to the console, true no remarks are made

    Returns:
        numpy array : the decoded float values of the waveform points

    """
    data = None
    if raw_data == None:
        try:
            raw_file = open(path, "rb")
        except FileNotFoundError:
            print("Raw Data file not found")
            return -1
        data = bytes(raw_file.read())
        raw_file.close()
    else:
        data = bytes(raw_data)

    byte_index = 0
    length_length = -1
    data_length = -1
    paren_end = -1
    if data[byte_index] == ord('#'): # and len(data)>10:
        # very start of byte string
        # move past '#'
        byte_index += 1
        # check to see if there are parentsis
        if data[byte_index] == ord('('):
            paren_end = byte_index
            parenthesis = True
            while data[paren_end] != ord(')'):
                paren_end += 1
            length_length = int(str(data[byte_index+1:paren_end]))
            byte_index = paren_end + 1
        else:
            # no parenthesis
            length_length = int(chr(data[byte_index]))
            byte_index += 1
        

        #data_length = int(str(data[byte_index:byte_index+length_length])[2:-1])

        byte_index += length_length
    else:
        print("Data Receive failed")
        return -1
    
    if not silent:
            print("Data read successful")
    
    # Trim of head leaving only 4-byte float chunks
    data = data[byte_index:-1]
        
    samples = len(data)/4
    samples = int(samples)

    data_floats = []

    if not silent:
            print("Parsing data...")

    for byte in range(samples):
        #four_bytes = data[byte*4:(byte*4)+4]
        data_floats.append(bytes_to_float32(data[byte*4:(byte*4)+4]))

    # create numpy arrays for easy data manipulation
    values = np.asarray(data_floats)

    return values


def save_raw_data_to_file(data, path=None):
    """
    Saves raw data (bytes data from waveform or signal capture) to a file given the provided path

    Args:
        data (bytes) : 
            The raw data that will be saved to path
        path (str) : [optional]
            The save path location and file name *without extension*
    """
    if path != None:
        save_path = path + ".lmao"
    else:
        save_path = "./output.lmao"
    output_file = open(save_path, "wb")
    output_file.write(data)
    output_file.close()


class VisaResource():
    """
    Parent Class for connection to VISA and SCPI command driven devices
    Child classes are written for the R&S®RTO6 Oszilloskop Rohde & Schwarz, and the RIGOL DSA800 series Spectrum Analyzer 

    Attributes:
        (private) device : pyvisa resource 
            The device object for interfacing
        device_name : str
            ID string of device connected
    """
    
    def __init__(self, pyvisa_resource_manager=None):
        """
        Initializes oscilloscope object with no connection. Creates pyvisa resource manger for connection preparation if no device manager was provided.
        When connecting to multiple devices please provide common resource manager for all devices

        Args: 
            pyvisa_resource_manager (ResourceManager) : [optional]
                Provided pyvisa resource manager, one is created if not provided
        """
        self.device = None
        self.device_name = "No Device Connected!"
        if pyvisa_resource_manager == None:
            pyvisa_resource_manager = pyvisa.ResourceManager()
        self.rm = pyvisa_resource_manager


    def __enter__(self):
        return self
    

    def __exit__(self, exc_type, exc_value, traceback):
        if traceback is not None:
            print(traceback)
        self.close()
    

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
    

    def list_connections(self):
        """
        Provides a list of available resource connections

        Args: none

        Returns:
            str[] : the list of available resource IDs
        """
        if self.rm == None:
            print("Failed to get pyvisa Resource Manager")
            return
        if(len(self.rm.list_resources()) == 0):
            print("No Devices Connected")
            return
        for index in range(len(self.rm.list_resources())):
                print(f"{index}: {self.rm.list_resources()[index]}")
        return self.rm.list_resources()
        

    def connect(self, device_index = -1, device_id=None):
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

        # check if no parameters are provided and default to first in list
        if device_index == -1 and device_id == None:
            device_index = 0

        # check to see if provided ID is valid if so set index
        elif device_id != None:
            try:
                device_index = self.rm.list_resources().index(device_id)
            except ValueError:
                print("Could not find specified ID from available resources")
                device_index = 0

        # no provided ID, check to see if index is valid before trying to connect
        if(len(self.rm.list_resources()) <= device_index):
            print("Invalid device index " + str(device_index))
            print("Please specify from this list")
            for index in range(len(self.rm.list_resources())):
                print(f"{index}: {self.rm.list_resources()[index]}")
            return False
        
        # get device ID
        device_id = self.rm.list_resources()[device_index]

        # connect to device
        self.device = self.rm.open_resource(device_id)

        if (self.device == None):
            print("Failed to connect to " + device_id)
            return False

        time.sleep(0.1)
        try:
            self.device_name = self.device.query("*IDN?") # pg. reference required here
            print("Connected to oscilloscope: " + self.device_name)

        except:
            print("Failed to get response from " + device_id)
            return False

        # reset device to default settings for clean start
        self.device.write("SYSTem:PRESet")
        return True
    

    def disconnect(self):
        """disconnects from any connected resources (oscilloscopes)"""
        self.close()


    def custom_write_command(self, command):
        """
        Directly sends a string command to the device, please use commands as specified in device documentation.

        if expecting a response from command use custom_query_command()

        Args:
            command (str):
                The exact string command that will be sent to the scope

        Returns:
            Nothing
        """
        try:
            self.device.write(str(command))
        except:
            print("Custom command: " + str(command) + " failed!")

    def custom_query_command(self, command):
        """
        Sends a query command to the scope, please use commands as specified in device documentation:

        if not expecting a response from command use custom_write_command()

        Args:
            command (str):
                The exact string command that will be sent to the scope

        Returns:
            Nothing
        """
        response = ""
        try:
            response = self.device.write(str(command))
        except:
            print("Custom command: " + str(command) + " failed!")

        return response
