import time
import machine
import dht

# --- Hardware Configuration ---
# DHT22 sensor connected to GPIO15
dht_sensor = dht.DHT22(machine.Pin(15))

# Relay module (Compressor control) connected to GPIO14
relay = machine.Pin(14, machine.Pin.OUT)

# Target dryness humidity threshold (%)
TARGET_HUMIDITY = 15.0

print("--- Eco-Vortex Dryer: Automated Controller Started ---")

# Turn compressor ON at start
relay.value(1)
print("Status: Compressor active. Drying process initiated...")

try:
    while True:
        time.sleep(2)  # DHT22 updates every 2 seconds
        
        try:
            dht_sensor.measure()
            temp = dht_sensor.temperature()
            humidity = dht_sensor.humidity()
            
            print(f"Temperature: {temp:.1f}°C | Chamber Humidity: {humidity:.1f}%")
            
            # Check if drying process is complete
            if humidity <= TARGET_HUMIDITY:
                relay.value(0)  # Turn OFF compressor
                print("--------------------------------------------------")
                print(" SUCCESS: Target humidity reached! Drying complete.")
                print("--------------------------------------------------")
                break
                
        except OSError as e:
            print("Sensor read error:", e)

except KeyboardInterrupt:
    relay.value(0)
    print("\nProcess manually aborted. Compressor OFF.")
