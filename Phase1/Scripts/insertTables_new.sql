-- FuelType - lookup table for gas types
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (1, 'JP-8');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (2, 'Jet-A');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (3, 'AVGAS');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (4, 'JP-5');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (5, 'Jet-A1');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (6, 'JP-4');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (7, 'AVGAS 100LL');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (8, 'JP-7');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (9, 'TS-1');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (10, 'Jet-B');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (11, 'AVGAS 80');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (12, 'JP-6');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (13, 'BioJet-1');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (14, 'SAF-50');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (15, 'JP-10');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (16, 'AVGAS 91');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (17, 'Jet-A Plus');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (18, 'JP-9');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (19, 'Kerosene-1');
INSERT INTO FuelType (FuelTypeId, FuelTypeName) VALUES (20, 'Synthetic Jet');

-- Squadron
INSERT INTO Squadron (SquadronId, SquadronName, BaseLocation) VALUES (1, 'טייסת הנשר', 'בסיס חצור');
INSERT INTO Squadron (SquadronId, SquadronName, BaseLocation) VALUES (2, 'טייסת הדרקון', 'בסיס רמת דוד');
INSERT INTO Squadron (SquadronId, SquadronName, BaseLocation) VALUES (3, 'טייסת נשר', 'בסיס נבטים');

-- FuelStock
INSERT INTO FuelStock (StockId, Location, StockLevel, MaxCapacity, RestockDate, FuelTypeId)
VALUES (1, 'Warehouse A', 1250000, 2500000, '2025-05-01', 1);
INSERT INTO FuelStock (StockId, Location, StockLevel, MaxCapacity, RestockDate, FuelTypeId)
VALUES (2, 'Warehouse B', 1500000, 2000000, '2025-06-01', 2);
INSERT INTO FuelStock (StockId, Location, StockLevel, MaxCapacity, RestockDate, FuelTypeId)
VALUES (3, 'Warehouse C', 1450000, 2800000, '2025-09-01', 3);
-- Aircraft
INSERT INTO Aircraft (AircraftId, NextInspectionDate, ModelName, FuelCapacity, SquadronId, StockId, FuelTypeId) VALUES (1, '2025-06-01', 'F-16', 7000, 1, 1, 1);
INSERT INTO Aircraft (AircraftId, NextInspectionDate, ModelName, FuelCapacity, SquadronId, StockId, FuelTypeId) VALUES (2, '2025-07-01', 'Apache', 5000, 2, 2, 2);
INSERT INTO Aircraft (AircraftId, NextInspectionDate, ModelName, FuelCapacity, SquadronId, StockId, FuelTypeId) VALUES (3, '2025-08-01', 'Cessna', 3000, 3, 3, 3);
INSERT INTO Aircraft (AircraftId, NextInspectionDate, ModelName, FuelCapacity, SquadronId, StockId, FuelTypeId) VALUES (4, '2025-09-01', 'F-15', 8000, 1, 1, 1); 
INSERT INTO Aircraft (AircraftId, NextInspectionDate, ModelName, FuelCapacity, SquadronId, StockId, FuelTypeId) VALUES (5, '2025-10-01', 'Black Hawk', 4500, 2, 2, 2); 
INSERT INTO Aircraft (AircraftId, NextInspectionDate, ModelName, FuelCapacity, SquadronId, StockId, FuelTypeId) VALUES (6, '2025-11-01', 'Chinook', 6000, 3, 3, 3); 

-- Plane
INSERT INTO Plane (AircraftId, PrepTime, MaxRange) VALUES (1, 2, 1500);
INSERT INTO Plane (AircraftId, PrepTime, MaxRange) VALUES (3, 1, 800);
INSERT INTO Plane (AircraftId, PrepTime, MaxRange) VALUES (4, 3, 2000);

-- Hellicopter
INSERT INTO Hellicopter (AircraftId, BoardingCapacity, PayloadCapacity, MaxHoverTime) VALUES (2, 12, 4000, 3);
INSERT INTO Hellicopter (AircraftId, BoardingCapacity, PayloadCapacity, MaxHoverTime) VALUES (5, 8, 3000, 2);
INSERT INTO Hellicopter (AircraftId, BoardingCapacity, PayloadCapacity, MaxHoverTime) VALUES (6, 15, 5000, 4);

-- Pilot
INSERT INTO Pilot (PilotId, FullName, NextTrainingDate, Rank, AircraftId) VALUES (1, 'יוסי כהן', '2025-05-15', 'סרן', 1);
INSERT INTO Pilot (PilotId, FullName, NextTrainingDate, Rank, AircraftId) VALUES (2, 'מיכה לוי', '2025-06-15', 'סגן', 2);
INSERT INTO Pilot (PilotId, FullName, NextTrainingDate, Rank, AircraftId) VALUES (3, 'איתן דוד', '2025-07-15', NULL, NULL);

-- Equipment
INSERT INTO Equipment (EquipmentId, EquipmentType, Weight) VALUES (1, 'מכ"ם', 500);
INSERT INTO Equipment (EquipmentId, EquipmentType, Weight) VALUES (2, 'טיל מונחה חום', 800);
INSERT INTO Equipment (EquipmentId, EquipmentType, Weight) VALUES (3, 'מיכל דלק נוסף', 300);

-- Equipped_With
INSERT INTO Equipped_With (AircraftId, EquipmentId, Quantity) VALUES (1, 1, 2);
INSERT INTO Equipped_With (AircraftId, EquipmentId, Quantity) VALUES (2, 2, 1);
INSERT INTO Equipped_With (AircraftId, EquipmentId, Quantity) VALUES (3, 3, 1);