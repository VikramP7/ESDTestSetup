*<div align="right"> Vikram Procter | June 2025 </div>*

# ESD Test Setup Controller

## Necessary Imports:
I recommend using a virtual python environment
-   PySide6: `pip install pyside6`
-   PyVisa: `pip install pyvisa-py`
-   xtralien: `pip install xtralien`
-   PySerial: `pip install pyserial`
-   Numpy: `pip install numpy` 

## Usage
-   Please explain here how to use the python script

## TODO:
-   Attach connection testing and establishment procedures to the refresh buttons on main menu
    - Find how to check if the devices are still connected (fix it to actually test)
-   Create second thread for test procedure
-   Create the test procedure
-   Attach run/stop buttons to the test procedure (multi threading)
-   Configuration import and export
-   Data export
-   Write readme

## How it Works:
### QML Hierarchy
-   Main.qml holds the everything: main window, configure dialog, peripheral controller
-   The configure dialog has child elements for each of the pages within the stack view
    - Each child page is form for entering the parameters for its peripheral device

### Signals and Slots