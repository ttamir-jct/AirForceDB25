-- Query 1: Aircraft needing inspection this month with their squadron details
SELECT 
    a.AircraftId, 
    a.ModelName, 
    a.NextInspectionDate, 
    EXTRACT(YEAR FROM a.NextInspectionDate) AS InspectionYear, 
    EXTRACT(MONTH FROM a.NextInspectionDate) AS InspectionMonth, 
    s.SquadronName, 
    s.BaseLocation
FROM Aircraft a
JOIN Squadron s ON a.SquadronId = s.SquadronId
WHERE EXTRACT(MONTH FROM a.NextInspectionDate) = 5 
    AND EXTRACT(YEAR FROM a.NextInspectionDate) = 2025
ORDER BY a.NextInspectionDate;

-- Query 2: Pilots with overdue training, including their assigned aircraft
SELECT 
    p.PilotId, 
    p.FullName, 
    p.NextTrainingDate, 
    EXTRACT(DAY FROM AGE(CURRENT_DATE, p.NextTrainingDate)) AS DaysOverdue, 
    a.ModelName AS AssignedAircraft
FROM Pilot p
LEFT JOIN Aircraft a ON p.AircraftId = a.AircraftId
WHERE p.NextTrainingDate < CURRENT_DATE
ORDER BY DaysOverdue DESC;

-- Query 3: Fuel stocks needing restocking soon, with fuel type and total aircraft using that stock
SELECT 
    fs.StockId, 
    fs.Location, 
    fs.StockLevel, 
    fs.RestockDate, 
    ft.FuelTypeName, 
    (SELECT COUNT(*) 
     FROM Aircraft a 
     WHERE a.StockId = fs.StockId) AS AircraftCount
FROM FuelStock fs
JOIN FuelType ft ON fs.FuelTypeId = ft.FuelTypeId
WHERE fs.RestockDate <= CURRENT_DATE + INTERVAL '7 days'
    AND fs.RestockDate >= CURRENT_DATE
ORDER BY fs.RestockDate;

-- Query 4: Average equipment weight per aircraft model
SELECT 
    a.ModelName, 
    COUNT(DISTINCT ew.AircraftId) AS AircraftCount, 
    ROUND(AVG(e.Weight * ew.Quantity), 2) AS AvgEquipmentWeight
FROM Aircraft a
LEFT JOIN Equipped_With ew ON a.AircraftId = ew.AircraftId
LEFT JOIN Equipment e ON ew.EquipmentId = e.EquipmentId
GROUP BY a.ModelName
HAVING COUNT(DISTINCT ew.AircraftId) > 0
ORDER BY AvgEquipmentWeight DESC;

-- Query 5: Helicopters with above-average boarding capacity, including their squadron
SELECT 
    h.AircraftId, 
    a.ModelName, 
    h.BoardingCapacity, 
    s.SquadronName
FROM Hellicopter h
JOIN Aircraft a ON h.AircraftId = a.AircraftId
JOIN Squadron s ON a.SquadronId = s.SquadronId
WHERE h.BoardingCapacity > (
    SELECT AVG(BoardingCapacity) 
    FROM Hellicopter
)
ORDER BY h.BoardingCapacity DESC;

-- Query 6: Planes with the longest range per squadron, including pilot details
SELECT 
    s.SquadronName, 
    p.AircraftId, 
    a.ModelName, 
    p.MaxRange, 
    pi.FullName AS PilotName
FROM Plane p
JOIN Aircraft a ON p.AircraftId = a.AircraftId
JOIN Squadron s ON a.SquadronId = s.SquadronId
LEFT JOIN Pilot pi ON a.AircraftId = pi.AircraftId
WHERE (p.AircraftId, p.MaxRange) IN (
    SELECT p2.AircraftId, p2.MaxRange
    FROM Plane p2
    JOIN Aircraft a2 ON p2.AircraftId = a2.AircraftId
    WHERE a2.SquadronId = s.SquadronId
    ORDER BY p2.MaxRange DESC
    LIMIT 1
)
ORDER BY p.MaxRange DESC;

-- Query 7: Fuel stock usage efficiency per location (based on stock level and aircraft count)
SELECT 
    fs.Location, 
    fs.StockLevel, 
    fs.MaxCapacity, 
    (fs.StockLevel * fs.MaxCapacity) AS CurrentLiters, 
    COUNT(a.AircraftId) AS AircraftServed, 
    ROUND((fs.StockLevel * 100.0) / NULLIF(COUNT(a.AircraftId), 0), 2) AS EfficiencyScore
FROM FuelStock fs
LEFT JOIN Aircraft a ON a.FuelStockId = fs.StockId
GROUP BY fs.Location, fs.StockLevel, fs.MaxCapacity
HAVING COUNT(a.AircraftId) > 0
ORDER BY EfficiencyScore;

-- Query 8: Monthly inspection schedule with aircraft and pilot readiness
SELECT 
    EXTRACT(MONTH FROM a.NextInspectionDate) AS InspectionMonth, 
    a.AircraftId, 
    a.ModelName, 
    p.FullName AS PilotName, 
    CASE 
        WHEN p.NextTrainingDate < a.NextInspectionDate THEN 'Pilot Ready'
        ELSE 'Pilot Training Needed'
    END AS PilotReadiness
FROM Aircraft a
LEFT JOIN Pilot p ON a.AircraftId = p.AircraftId
WHERE EXTRACT(YEAR FROM a.NextInspectionDate) = 2025
ORDER BY InspectionMonth, a.AircraftId;

-- DELETE Query 1: Remove aircraft with overdue inspections (more than 30 days)
DELETE FROM Aircraft
WHERE NextInspectionDate < CURRENT_DATE - INTERVAL '30 days'
    AND AircraftId NOT IN (SELECT AircraftId FROM Pilot WHERE AircraftId IS NOT NULL);

-- DELETE Query 2: Remove fuel stocks that are empty and not used by any aircraft
DELETE FROM FuelStock
WHERE StockLevel = 0
    AND StockId NOT IN (SELECT FuelStockId FROM Aircraft WHERE FuelStockId IS NOT NULL);

-- DELETE Query 3: Remove equipment not assigned to any aircraft
DELETE FROM Equipment
WHERE EquipmentId NOT IN (SELECT EquipmentId FROM Equipped_With);

-- UPDATE Query 1: Increase fuel stock levels by 10% for stocks below 30%
UPDATE FuelStock
SET StockLevel = LEAST(StockLevel * 1.10, 1)
WHERE StockLevel < 0.3;

-- UPDATE Query 2: Update pilot ranks for those with overdue training
UPDATE Pilot
SET Rank = CONCAT(Rank, ' (Probation)')
WHERE NextTrainingDate < CURRENT_DATE;

-- UPDATE Query 3: Adjust aircraft inspection dates by pushing them forward 7 days if pilot is not trained
UPDATE Aircraft a
SET NextInspectionDate = NextInspectionDate + INTERVAL '7 days'
WHERE EXISTS (
    SELECT 1
    FROM Pilot p
    WHERE p.AircraftId = a.AircraftId
    AND p.NextTrainingDate > CURRENT_DATE
);