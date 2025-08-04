from VisaResource import *

class Oscilloscope(VisaResource):
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

    State = Enum('State', [('RUNNING', 0), ('SINGLE', 1), ('STOPPED', 2)])

    def __init__(self, pyvisa_resource_manager=None):
        super().__init__(pyvisa_resource_manager)

    def set_state(self, newState):
        """
        If connected to a oscilloscope sets the current operating state

        Args:
            newState (State enum) : 
                Desired state

        Returns:
            nothing
        """
        if self.device == None:
            print("Scope Not Connected")
            return
        
        command_str = ""
        match newState:
            case Oscilloscope.State.RUNNING:
                command_str = "RUN"
            case Oscilloscope.State.SINGLE:
                command_str = "SING"
            case Oscilloscope.State.STOPPED:
                command_str = "STOP"
        # put page reference here
        self.device.write(command_str)

    
    def set_trigger_voltage(self,voltage, channel=1, pos_slope=True):
        """
        Sets the trigger voltage of the oscilloscope with a specific channel (default 1), also uses normal mode for triggering
        Provided a oscilloscope is connected

        Args:
            voltage (float) : 
                The voltage level of the desired trigger
            channel (default=1 int) : [optional]
                The channel number the trigger voltage is applied to
            pos_slope (default=True) : [optional]
                Trigger slope is positive when true, trigger slope is negative when false
        """
        if self.device == None:
            print("Scope Not Connected")
            return
        
        try:
            voltage = float(voltage)
        except ValueError:
            print("Specified Voltage should be a float value, setting trigger voltage failed")
            return
        
        try: 
            channel = int(channel)
        except ValueError:
            print("Specified channel should be an integer, setting trigger voltage failed")
            return
        
        if channel > 4:
            channel = 4
        elif channel < 1:
            channel = 1
        
        slope = "POS" if pos_slope else "NEG"

        self.device.write(f"TRIG:MODE NORM") # could be NORM or AUTO pg. 1548 of RTO6 UserManual
        self.device.write(f"TRIG:TYPE EDGE") # pg. 1506 from RTO6 UserManual
        self.device.write(f"TRIG:LEVel{channel} {voltage}") # pg. 1507 from RTO6 UserManual
        self.device.write(f"TRIG:EDGE:SLOPe {slope}") # could be POS or NEG from pg. 1508 of RTO6 UserManual

    
    def set_acquisition_time(self, acquisition_time):
        """
        Sets the Acquisition Time for a measurement. Ranges from 250E-12 to 100E+3 (RTO, RTP) | 50E+3 (RTE), incremmented each Increment: 1E-12s.
        Time unit is in seconds. 

        Args:
            aquisition_time (float) : [units seconds]
                The length of time one data aquisition waveform is
        """

        if self.device == None:
            print("Scope Not Connected")
            return

        try:
            acquisition_time = float(acquisition_time)
        except ValueError:
            print("Invalid record length " + str(acquisition_time))
            print("Record length must be an float between 250E-12 to 100E+3")
            return
        
        # checks to see if acquisition time is in range
        if acquisition_time > 50E3:
            acquisition_time = 50E3
        elif acquisition_time < 250E-12:
            acquisition_time = 250E-12
        
        try:
            self.device.write(f"TIMebase:RANGe {acquisition_time}") # see pg. 1435
        except:
            print("Commnad Failed: " + f"TIMebase:RANGe {acquisition_time}")


    def set_acquisition_record_length(self,record_length):
        """
        Sets the Acquisition record length (number of data points) of the scope ranges from 1000 to 1000000000 value provided is in points.
        Also sets the Acquire count to 1, and interpolation to Sin(x)/x.

        Resolution = acquisition time / record_length
        Sample rate = 1/Resolution = record_length / acquisition time
        
        Args:
            record_length (int) : [units points]
                The total number of recorded waveform points that span the acquisition time. Ranges from 1000 to 1000000000
        """
        try:
            record_length = int(record_length)
        except ValueError:
            print("Invalid record length " + str(record_length))
            print("Record length must be an integer between 1000 to 1000000000")
            return

        # checks to see if record length is in range
        if record_length > 1000000000:
            record_length = 1000000000
        elif record_length < 1000:
            record_length = 1000

        self.device.write("ACQuire:POINts:AUTO RECLength") # pg. 1437 sets record lengths to be constant
        # set the constant length of each record 
        self.device.write(f"ACQuire:POINts {record_length}") # pg. 1439 ranges from 1000 to 1000000000
        self.device.write("ACQuire:COUNt 1") # pg. 1443 could range from 1 to 16777215
        self.device.write("ACQuire:INTerpolate SINX") # pg.1440 options LINear, SINX, SMHD 
        


    def record_waveform(self, channel=1, record_to_file = False, path=None, silent=False):
        """
        Preforms waveform measurement procedure, collects data and returns it as numpy arrays
        Procedure:
        1. Places scope in single mode
        2. Waits for scope to trigger (see set_trigger_voltage())
        3. Queries for data and parses it
        4. Returns parsed data

        Args:
            channel (default=1 int): [optional]
                The channel that the waveform data is being recorded
            record_to_file (default=False boolean) : [optional]
                Records data to a file specified by path parameter
            path (default=None str) : [optional]
                If recorded_to_file is specified, file will be saved to this path, provide path and file name but no extension
                Can be left as default, and file will be saved to execution path
            silent (boolean) : [optional] default=False
                Specifies if status remarks are made to the console, true no remarks are made

        Returns:
            numpy.array, numpy.array : times, voltages of waveform as numpy arrays

        """
        # Scope Connection Early Return Test
        if self.device == None:
            print("Scope Not Connected")
            return -1, -1
        
        # put scope into single mode 
        self.device.write("SING") # puts scope into single mode (pg. 1434)
        if not silent:
            print("Device set to single mode")
        #self.scope.write("*OPC")
        
        # waits until the scope has been triggered and put into stopped mode
        if not silent:
            print("Waiting for triggering signal...")
        while self.check_stopped() == False:
            time.sleep(0.1)

        if not silent:
            print("Signal triggered reading data from scope...")

        # after scope has triggered make data queries
        head = self.device.query(f"CHAN{channel}:WAV1:DATA:HEAD?") # request the data size (pg. 1451)
        self.device.write("FORM REAL,32") # request data in float32 format (pg. 1399)
        self.device.write("EXP:WAV:INCX OFF") # dont include X values (pg. 1452)
        self.device.write(f"CHAN{channel}:WAV1:DATA?") # query data (pg. 1452) 

        data = self.device.read_raw()

        if not silent:
            print("Data read complete")

        #self.scope.write("FORM ASC")
        #data_str = self.scope.query(f"CHAN{channel}:WAV1:DATA?")

        # save raw data to file
        if record_to_file:
            if not silent:
                print("Recording Raw Bytes Data to file")
            save_raw_data_to_file(data=data, path=path)           

        voltages = parse_raw_bytes_data(data)

        if len(voltages) < 10:
            print("Data parsing failed, data invalid")
            return -1, -1

        np_head = np.fromstring(head, sep=',')

        start_time = np_head[0]
        end_time = np_head[1]
        data_length = int(np_head[2])

        # create numpy arrays for easy data manipulation
        times = np.linspace(start_time, end_time, data_length)

        return times, voltages
    

    def check_stopped(self):
        """
        Checks the status of the oscilloscope to see if its triggered following a command to place it in running mode

        Returns:
            boolean : true if in triggered state, false if not yet triggered
        """
        if self.device == None:
            print("Scope Not Connected")
            return
        current = 0b0
        #bitmask_ALIGnment = 0b00001
        #bitmask_AUToset = 0b00100
        #bitmask_WTRIgger = 0b01000
        bitmask_MEASuring = 0b10000
        
        try:
            current = int(self.device.query("STATus:OPERation:CONDition?")) # see pg. 1352 and 2884-2885
            #happened = int(self.scope.query("STATus:OPERation:EVENt?"))
        except pyvisa.errors.VisaIOError:
            print("No response from scope!")
        except TypeError:
            print("Error with parsing data received")

        """ debug for other values in status register
        ALIGnment = bitmask_ALIGnment & current
        AUToset = bitmask_AUToset & current
        WTRIgger = bitmask_WTRIgger & current
        MEASuring = bitmask_MEASuring & current

        h_ALIGnment = bitmask_ALIGnment & happened
        h_AUToset = bitmask_AUToset & happened
        h_WTRIgger = bitmask_WTRIgger & happened
        h_MEASuring = bitmask_MEASuring & happened
        """

        return (current & bitmask_MEASuring) == 0