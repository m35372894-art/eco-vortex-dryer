# Low-Cost Cold Air Dehydrator Using Ranque-Hilsch Vortex Tube

A minimal, open-source cold drying system designed for thermal-sensitive bio-materials (herbs, berries, and cellular samples). 

Standard thermal dehydrators degrade heat-sensitive antioxidants and vitamins through high temperatures, while commercial freeze-dryers remain cost-prohibitive ($1,000+). This project demonstrates a $20–$30 alternative using micro-vortex fluid dynamics to remove moisture at ambient temperature.

## Physics & Working Principle
The core mechanism relies on compressed air dynamic energy separation inside a customized 1/2" T-fitting (Ranque-Hilsch Vortex Effect). 

1. Compressed air enters tangentially into the swirl chamber.
2. The outer high-velocity vortex loses kinetic energy and exhausts warm air through the control valve.
3. The inner low-pressure core expands rapidly, drops in temperature, and yields dry air that absorbs moisture from the drying chamber without heat damage.

## System Components
* Controller: Raspberry Pi Pico (RP2040) / MicroPython
* Sensor: DHT22 (Precision RH% and temperature monitoring)
* Actuator: 5V Optocoupler Relay Module
* Vortex Chamber: Modified brass T-fitting with 3D-printed tangential nozzle insert

## Vortex Tube Critical Dimensions
* Chamber Inner Diameter ($D$): 12 mm
* Hot Tube Length: 250 mm (~20.8$D$)
* Cold Diaphragm Orifice: 4 mm (~0.33$D$)
* Inlet Nozzle: 4 mm tangential entry

## Control Logic
The MicroPython script reads chamber RH% via DHT22 every 2 seconds. Once relative humidity drops to the target threshold (default: 15%), the controller trips the relay, halting the compressor to optimize power consumption.

## License
MIT License - Open for modification and research use
