from decimal import Decimal
import time
import math

import xtralien
import serial
from serial.tools import list_ports


com_no = 3  # USB COM port number of the connected Source Measure Unit
channel = 'smu1'  # SMU channel to use
i_range = 1  # Current range to use, see manual for details

# Parameters are defined using the Decimal class to avoid floating point errors
start_v = Decimal('0')  # Sweep start voltage in volts
end_v = Decimal('2.5')  # Sweep end voltage in volts
inc_v = Decimal('0.05')  # Sweep voltage increment in volts

wave = []
N = 100
val = 0
for i in range(0,N):
    wave.append(1*math.sin(i*(2*math.pi)/N))
    #wave.append((val/100))
    #val += 5
    #val %= 100
    #wave.append(3*((-1)**i))

#wave = [0,3,0] # simulated TLP pulse
N = len(wave)


# set up graphics
#console_graph = drawing.ConsoleWave(15, wave=wave)
#console_graph.draw_axis()

# Connect to the Source Measure Unit using USB
with xtralien.Device(f'COM{com_no}') as SMU:
    # Set the current range for SMU 1
    SMU[channel].set.range(i_range, response=0)
    time.sleep(0.05)
    # Turn on SMU 1
    SMU[channel].set.enabled(True, response=0)
    time.sleep(0.05)

    print(SMU.cloi.hello())

    #Initialise the set voltage
    loops = 0
    wave_index = 0
    # Loop through the voltages to measure
    while loops < 1:
        """
        if wave_index == 0:
            console_graph.undraw_cursor(N-1)
        else:
            console_graph.undraw_cursor(wave_index-1)
        """
        # Set voltage, measure voltage and current
        voltage, current = SMU[channel].oneshot(wave[wave_index])[0]

        # Print measured voltage and current
        #print(f'V: {voltage} V; I: {current} A')
        #console_graph.draw_cursor(wave_index, current, voltage=voltage)

        # Increment the set voltage
        wave_index += 1
        if wave_index == len(wave):
            wave_index = 0
            loops += 1
        #time.sleep(0.05)

    #console_graph.release_terminal()
    # Reset output voltage and turn off SMU 1
    SMU[channel].set.voltage(0, response=0)
    time.sleep(0.1)
    SMU[channel].set.enabled(False, response=0)

