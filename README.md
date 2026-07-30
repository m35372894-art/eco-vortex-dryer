# Open-Source Cold Eco-Dryer (Ranque-Hilsch Vortex Tube)

An ultra-budget, eco-friendly cold drying system designed for delicate organic products (herbs, berries, microgreens) using the Ranque-Hilsch Vortex Effect.

## 📌 Problem & Solution
Traditional heat-based dehydrators destroy heat-sensitive vitamins and antioxidants in delicate produce. Industrial vacuum-freeze dryers cost upwards of $1000+. 

This project utilizes a Ranque-Hilsch Vortex Tube made from standard mechanical fittings to separate compressed air into hot and cold/dry streams, enabling zero-heat moisture removal for under $30.

## 🛠️ Hardware Requirements
* Microcontroller: Raspberry Pi Pico (RP2040)
* Sensor: DHT22 (Temperature & Relative Humidity)
* Actuator: 5V Relay Module (to control air compressor)
* Core: 1/2" T-Fitting + 25cm PVC Tube + Tangential Nozzle
* Dryer Chamber: Sealed 5L Food Container with mesh tray

## 📐 Vortex Tube Specifications
* Main Tube Inner Diameter ($D$): 12 mm
* Hot Tube Length: 250 mm (~20D)
* Diaphragm Orifice: 4 mm (1/3D)
* Compressed Air Inlet: 4 mm (Tangential)

## 🚀 MicroPython Control Logic
The system monitors relative humidity inside the chamber in real-time and automatically shuts off the air compressor via a relay when target dryness is reached.

## 📜 License
This project is open-source and available under the [MIT License](LICENSE).
