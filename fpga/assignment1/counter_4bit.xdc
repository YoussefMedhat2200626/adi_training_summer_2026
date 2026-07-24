## ---------------------------------------------------------------------------------------------------
## Clock - Bank 13
## ---------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN Y9 [get_ports clk_100mhz]; # Using the ZedBoard GCLK pin

# Create clock constraint for 100 MHz (Period = 10 ns)
create_clock -period 10.000 -name clk_100mhz -waveform {0.000 5.000} [get_ports clk_100mhz]

## ---------------------------------------------------------------------------------------------------
## Reset (User DIP Switch) - Bank 35
## ---------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN F22 [get_ports rst];  # "SW0"

## ---------------------------------------------------------------------------------------------------
## User LEDs - Bank 33
## ---------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {leds[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {leds[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {leds[2]}];  # "LD2"

## ---------------------------------------------------------------------------------------------------
## IOSTANDARD Constraints (Bank-wide as per your previous setup)
## ---------------------------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]]; # LEDs
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]]; # Switches
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]]; # Clock
