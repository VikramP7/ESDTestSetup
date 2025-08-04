*<div align="right"> Vikram Procter | June 2025 </div>*

# Visa Resource Library
*For use with **RIGOL DSA800** series Spectrum Analyzer and **R&S®RTO6** Oszilloskop | Rohde & Schwarz.* 
Uses [NumPy](https://numpy.org/) as a dependancy. `pip install numpy`
Uses [PyVisa-py](https://pypi.org/project/PyVISA-py/) as dependancy. `pip install pyvisa-py`



### Table of Contents 
- [Common Commands](#common-commands)
- [Oscilloscope Commands](#oscilloscope-commands)
- [Spectrum Analyzer Commands](#spectrum-analyzer-commands)
- [Tools](#tools) 

*See Examples.py for inspiration*


## Common Commands:

### `check_connection(self, silent=False)`
Returns the boolean connection status. Prints connection status to terminal if `silent==False`

**Args:**
- `silent` (boolean) | default silent=False: 
    Suppresses console messages if true

**Returns:**
- boolean: true if scope is connected, false if not connected
    

### `list_connections(self)`
Provides a list of available resource connections

**Args:**
- none

**Returns:** 
- str[] : the list of available resource IDs
        

### `connect(self, device_index=-1, device_id=None)`
Connects to a resource (oscilloscope/spectrum analyzer) by index in available resource list or by ID. If index or device ID is not specified, connection is made to first resource; `device_index = 0` 

**Args:**
- `device_index` (int) [optional *device_index=0*]:
    The resource index from list of available resources that should be connected to.

- `device_id` (str) [optional] | The resource ID that will be connected to.

**Returns:** 
- Bool:  
If connection fails returns false. If connection is successful returns true 


### `disconnect(self)`
Disconnects from any connected devices  
**Args:**
- none

**Returns:**
- none


### `custom_write_command(self, command)`
Directly sends a string command to the device, please use commands as specified in device documentation.
If expecting a response from command use `custom_query_command()` [*see bellow*](#custom_query_commandself-command)  
**Args:**
- `command` (str):
    The exact string command that will be sent to the scope

**Returns:** 
- none


### `custom_query_command(self, command)`
Sends a query command to the scope, please use commands as specified in device documentation.
If not expecting a response from command use `custom_write_command()` [*see above*](#custom_write_commandself-command)  
**Args:**
- `command` (str):
    The exact string command that will be sent to the scope

**Returns:** 
- none


## Oscilloscope Commands:
### `set_state(self, newState)`
If connected to an oscilloscope, sets the current operating state. See pg. 1433/1434 of R&S RTO6 UserManual  
**Args:**
- `newState` (State enum): 
    The desired state, could be *`State.RUNNING, State.SINGLE, State.STOPPED`*
    
**Returns:** 
- none

### `set_trigger_voltage(self,voltage, channel=1, pos_slope=True)`
Sets the trigger voltage of the oscilloscope with a specific channel (default 1), also uses normal mode for triggering. Provided a oscilloscope is connected. See pg. 1507, 1508, 1506, 1548 of R&S RTO6 UserManual  
**Args:**
- `voltage` (float): 
    The voltage level of the desired trigger
- `channel` (int) [optional *channel=1*]:
    The channel number the trigger voltage is applied to. Channels from 1-4
- `pos_slope` (bool) [optional *pos_slope=True*]:
    Trigger slope is positive when true, trigger slope is negative when false

**Returns:** 
- none

    
### `set_acquisition_time(self, acquisition_time)`
Sets the Acquisition Time for a measurement. Ranges from 250E-12 to 100E+3 (RTO, RTP) | 50E+3 (RTE), incremmented by 1E-12s.
Time unit is in seconds. See pg. 1435 of R&S RTO6 UserManual  
**Args:**
- `acquisition_time` (float):
    The length of time one data aquisition waveform is seconds

**Returns:** 
- none


### `set_acquisition_record_length(self,record_length)`
Sets the Acquisition record length (number of data points) of the scope waveform. Ranges from 1000 to 1000000000 value provided is in points. Also sets the Acquire count to 1, and interpolation to Sin(x)/x. See pg. 1437, 1439, 1443, 1440 of R&S RTO6 UserManual  

$Resolution = Acquisition Time / RecordLength$  
$Sample Rate = 1/Resolution = Record Length / AcquisitionTime $
        
**Args:**
- `record_length` (int):
    The total number of recorded waveform points that span the acquisition time. Ranges from 1000 to 1000000000

**Returns:** 
- none


### `record_waveform(self, channel=1, record_to_file = False, path=None, silent=False)`
Preforms waveform measurement procedure, collects data and returns it as numpy arrays
Procedure:
1. Places scope in single mode
2. Waits for scope to trigger (see set_trigger_voltage())
3. Queries for data and parses it
4. Returns parsed data

Refs:  
- pg. 1451-1452 of R&S RTO6 UserManual 
- pg. 1399 of R&S RTO6 UserManual 
- pg. 1434 of R&S RTO6 UserManual  

**Args:**
- `channel` (int) [optional *channel=1*]:  
    The channel that the waveform data is being recorded
- `record_to_file` (bool) [optional record_to_file=False]:
    Records data to a file specified by path parameter
- `path` (str) [optional]:  
    If recorded_to_file is specified, file will be saved to this path, provide path and file name but no extension. Can be left as default, and file will be saved to execution path
- `silent` (boolean) [optional silent=False]:  
    Specifies if status remarks are made to the console. *`True`* no remarks are made

**Returns:**
- `numpy.array, numpy.array`:   
    times, voltages of waveform as numpy arrays


### `check_stopped(self)`
Checks the oscilloscope status registers to see if  triggered following a command to place it in single mode. Ref: pg. pg. 1352 and 2884-2885 of R&S RTO6 UserManual   
**Args:** 
- none

**Returns:**
- boolean:  
    *`True`* if in triggered state, *`false`* if not yet triggered



## Spectrum Analyzer Commands:
### `set_span(self, frequency)`
Sets the span frequency of the device, ranges from 0 Hz to 7.5 GHz. Ref: Pg. 2-129 DSA800 Programming Guide  
**Args:**
- `frequency` (float):  
    The span frequency the spectrum analyzer is set to from 0 Hz to 7.5 GHz. Frequency provided in Hz

**Returns:** 
- none

### `set_span_max(self)`
Sets the span of the spectrum analyzer to the max span possible.
Ref: Pg. 2-129 DSA800 Programming Guide  
**Args:** 
- none

**Returns:** 
- none

### `set_center_frequency(self, frequency)`
Sets the center frequency of the device, ranges from 0 Hz to 7.5 GHz. Ref: Pg. 2-126 DSA800 Programming Guide.  
**Args:**
- `frequency` (float):  
    The center frequency the spectrum analyzer is set to from 0 Hz to 7.5 GHz. Frequency provided in Hz.

**Returns:** 
- none


### `set_start_frequency(self, frequency)`
Sets the start frequency of the device, ranges from 0 Hz to 7.5 GHz. Ref: Pg. 2-130 DSA800 Programming Guide
**Args:**
- `frequency` (float):  
    The start frequency the spectrum analyzer is set to from 0 Hz to 7.5 GHz. Frequency provided in Hz.  

**Returns:** 
- none


### `set_stop_frequency(self, frequency)`
Sets the start frequency of the device, ranges from 0 Hz to 7.5 GHz. Ref: Pg. 2-131 DSA800 Programming Guide.  
**Args:**
- `frequency` (float):  
    The start frequency the spectrum analyzer is set to from 0 Hz to 7.5 GHz. Frequency provided in Hz. 

**Returns:** 
- none


### `set_bandwidth_resolution(self, resolution)`
Sets the bandwidth resolution of the device, ranges from 10 Hz to 1 MHz, at 1-3-10 step. Ref: Pg. 2-106 DSA800 Programming Guide.  
**Args:**
- `resolution` (float):  
    The bandwidth resolution the spectrum analyzer is set to, ranges from 10 Hz to 1 MHz, at 1-3-10 step. Resolution provided in Hz

**Returns:** 
- none


### `set_bandwidth_resolution_auto(self, auto=True)`
Sets the bandwidth resolution of device to be automatically found. Ref: Pg. 2-106 DSA800 Programming Guide.  
**Args:**
- `auto` (boolean) [optional *`auto=True`*]:  
When true, device sets bandwidth resolution automatically.

**Returns:** 
- none


### `set_sweep_count(self,count)`
Sets the sweep count of the device, ranges from 1 to 9999. Ref: Pg. 2-147 DSA800 Programming Guide  
**Args:**
- `count` (int):  
    The sweep count of the spectrum analyzer, ranges from 1 to 9999

**Returns:** 
- none


### `set_sweep_time(self, time_s)`
Sets the sweep time of the device, ranges from 20us to 7500s.  
Ref: Pg. 2-148 DSA800 Programming Guide.  
**Args:**
- `time_s` (float):  
    The sweep time of the spectrum analyzer, ranges from 20us to 7500s. time_s provided in seconds

**Returns:** 
- none


### `set_average_count(self, count)`
Sets Set the number of averages of the trace, ranges from 1 to 1000.  
Ref: Pg. 2-147 DSA800 Programming Guide

**Args:**
- `count` (int):  
    The number of averages of the trace of the spectrum analyzer, ranges from 1 to 1000

**Returns:** 
- none

### `set_trace_mode(self, mode=Mode.WRITe, trace=1)`
Sets the mode for a given trace (1 through 3). Modes are Mode.WRITe, MAXHold, MINHold, VIEW, BLANk, VIDeoavg, POWeravg.  Ref: pg. 2-195 DSA800 Programming Guide  
**Args:**
- `mode` (enum Mode) [optional *`mode=WRITe`*]:  
    Sets the selected traces mode from the list
- `trace` (int) [optional *`trace=1`*]:  
    The selected trace that the mode will be applied to ranges from 1-3

**Returns:** 
- none

### `clear_all_traces(self)`
Turns off all traces, turns them all to BLANK type. Ref pg. 2-287 DSA800 Programming Guide  
**Args:** 
- none

**Returns:** 
- none


### `record_signal(self, trace=1, record_to_file = False, path=None, silent=False)`
Preforms signal measurement, collects data and returns it as numpy arrays.  
**Procedure:**
1. Queries for data
2. Parses Data
3. Returns parsed data as numpy array

Refs: pg. 2-64 DSA800 Programming Guide  
    pg. 2-188 DSA800 Programming Guide

**Args:**
- `trace` (int) [optional *`trace=1`*]:  
    The trace that the signal data is being recorded from
- `record_to_file` (boolean) [optional *`record_to_file=False`*]:  
    Records data to a file specified by path parameter
- `path` (str) [optional path=None]:  
    If recorded_to_file is specified, file will be saved to this path, provide path and file name but no extension
    Can be left as default, and file will be saved to execution path.
- `silent` (boolean) [optional *`silent=False`*]:  
    Specifies if status remarks are made to the console, true no remarks are made

**Returns:**
- `numpy.array, numpy.array`:  
times, voltages of waveform as numpy arrays

## Tools:

### `bytes_to_float32(four_bytes)`
Converts a 4 byte argument in IEEE 754 standard: binary32 into a float decimal result.  
**Args:**
- `four_bytes` (bytes):  
    The binary value that will be converted

**Returns:**
- `float`:  
    The IEEE 754 standard result of the binary value provided


### `parse_raw_bytes_data(raw_data=None, path="./output.lmao", silent=False)`
Parses raw waveform data retrieved from the oscilloscope in the REAL,32 described on pg. 1399 of the R&S RTO6 UserManual 
Adhering to 32-Bit IEEE 754 Floating Point Format 
or from the RIGOL DSA800 series Spectrum Analyzer in Real32

If `raw_data` is not provided an attempt will be made to open a file.

**Args:**
- `raw_data` (bytes) [optional]:  
    The raw_read of the data the scope provides
- `path` (str) [optional]:  
    The save file containing the scope waveform data
- `silent` (boolean) [optional *`silent=False`*]:  
    Specifies if status remarks are made to the console, true no remarks are made

**Returns:**
- `numpy array`:  
    The decoded float values of the waveform points