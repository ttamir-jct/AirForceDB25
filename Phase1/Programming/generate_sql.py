import random
from datetime import datetime, timedelta

# רשימות הגיוניות
squadron_prefixes = [
    "Hawk", "Dragon", "Eagle", "Falcon", "Raven", "Phoenix", "Viper", "Tiger", 
    "Wolf", "Bear", "Lion", "Cobra", "Shark", "Panther", "Owl", "Condor", 
    "Sparrow", "Stallion", "Hornet", "Pegasus", "Griffin"
]
squadron_suffixes = ["504B", "83V", "112K", "99X", "305M","44J","211H","707L","666D","532Z","243I","282Y","113O"]  # ניתן להוסיף עוד
base_locations = [
    "Hatzor Base", "Ramat David Base", "Nevatim Base", "Tel Nof Base", "Ovda Base", 
    "Palmachim Base", "Sde Dov Base", "Eilat Base", "Hatzerim Base", "Ramon Base", 
    "Haifa Base", "Ben Gurion Base", "Ein Shemer Base", "Megiddo Base", "Beersheba Base", 
    "Teyman Base", "Kiryat Shmona Base", "Ashdod Base", "Jerusalem Base", "Efrat Base", 
    "Yokneam Base", "Safed Base"
]
fuel_locations = [
    "Warehouse A", "Depot B", "Storage C", "Tank D", "Facility E", "Silo F", "Hangar G", 
    "Bay H", "Unit I", "Zone J", "Area K", "Base L", "Dock M", "Site N", "Plant O", 
    "Hub P", "Post Q", "Station R", "Yard S", "Vault T", "Port U", "Camp V"
]

with open('insert_squadron_fuel.sql', 'w', encoding='utf-8') as sqlfile:
    sqlfile.write("-- insert_squadron_fuel.sql\n\n")

    # Squadron: 400 רשומות
    sqlfile.write("-- Squadron\n")
    for i in range(1, 401):
        squad_name = f"{random.choice(squadron_prefixes)}-{random.choice(squadron_suffixes)}-{i:03d}"
        location = random.choice(base_locations)
        sqlfile.write(f"INSERT INTO Squadron (SquadronId, SquadronName, BaseLocation) VALUES ({i}, '{squad_name}', '{location}');\n")

    # FuelStock: 400 רשומות
    sqlfile.write("\n-- FuelStock\n")
    base_date = datetime(2025, 5, 1)
    for i in range(1, 401):
        stock_level = random.randint(30, 100)/100  # רמת המלאי של הדלק
        restock_date = (base_date + timedelta(days=i % 400)).strftime('%Y-%m-%d')
        fuel_type_id = (i % 20) + 1  # 1-20
        location = f"{random.choice(fuel_locations)}-{i % 20 + 1}"
        sqlfile.write(f"INSERT INTO FuelStock (StockId, Location, StockLevel, RestockDate, FuelTypeId) VALUES ({i}, '{location}', {stock_level}, '{restock_date}', {fuel_type_id});\n")

print("insert_squadron_fuel.sql נוצר בהצלחה!")
