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
WHERE EXTRACT(MONTH FROM a.NextInspectionDate) = EXTRACT(MONTH FROM CURRENT_DATE) 
    AND EXTRACT(YEAR FROM a.NextInspectionDate) = EXTRACT(YEAR FROM CURRENT_DATE)
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

-- Query 7: Aircraft and helicopter usage per fuel stock with recent restock check
SELECT 
    fs.Location AS FuelStockLocation, 
    fs.RestockDate, 
    COUNT(DISTINCT a.AircraftId) AS TotalAircraft, 
    COUNT(DISTINCT CASE WHEN p.AircraftId IS NOT NULL THEN p.AircraftId END) AS PlaneCount, 
    COUNT(DISTINCT CASE WHEN h.AircraftId IS NOT NULL THEN h.AircraftId END) AS HelicopterCount
FROM FuelStock fs
LEFT JOIN Aircraft a ON fs.StockId = a.StockId
LEFT JOIN Plane p ON a.AircraftId = p.AircraftId
LEFT JOIN Hellicopter h ON a.AircraftId = h.AircraftId
WHERE fs.RestockDate >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY fs.Location, fs.RestockDate
ORDER BY TotalAircraft DESC, RestockDate ASC;

-- Query 8: Monthly inspection and training schedule with readiness status
SELECT 
    a.AircraftId, 
    a.ModelName, 
    p.FullName AS PilotName, 
    CASE 
        WHEN a.NextInspectionDate < CURRENT_DATE
		THEN 'inspection is overdue'
        ELSE 'next inspection in ' || CAST(EXTRACT(DAY FROM AGE(a.NextInspectionDate,CURRENT_DATE)) as TEXT) || ' days'
    END
	AS InspectionStatus, 
    CASE 
        WHEN p.NextTrainingDate < CURRENT_DATE THEN 'training is overdue'
        ELSE 'next training in ' || CAST(EXTRACT(DAY FROM AGE(p.NextTrainingDate,CURRENT_DATE)) as TEXT)||' days'
    END AS TrainingStatus, 
    CASE 
        WHEN a.NextInspectionDate < CURRENT_DATE OR (p.NextTrainingDate < CURRENT_DATE AND p.AircraftId IS NOT NULL) THEN 'Not Ready'
        ELSE 'Ready'
    END AS ReadinessSummary
FROM Aircraft a
LEFT JOIN Pilot p ON a.AircraftId = p.AircraftId
WHERE EXTRACT(YEAR FROM a.NextInspectionDate) = 2025
ORDER BY a.AircraftId;

-- DELETE Query 1: Remove aircraft with overdue inspections (more than 120 days)
DELETE FROM Aircraft
WHERE NextInspectionDate < CURRENT_DATE - INTERVAL '120 days'
    AND AircraftId NOT IN (SELECT AircraftId FROM Pilot WHERE AircraftId IS NOT NULL);

-- DELETE Query 2: Remove fuel stocks that are nearly empty and are not used by any aircraft
DELETE FROM FuelStock
WHERE StockLevel < 2000000
    AND StockId NOT IN (SELECT StockId FROM Aircraft WHERE StockId IS NOT NULL);


-- DELETE Query 3: Remove large equipment not assigned to any aircraft
DELETE FROM Equipment
WHERE EquipmentId NOT IN (SELECT EquipmentId FROM Equipped_With)
AND Weight > 700;

-- UPDATE Query 1: Increase fuel stock levels for overdue restocks below 30%
UPDATE FuelStock
SET StockLevel = LEAST(StockLevel + (MaxCapacity * 0.75), MaxCapacity)
WHERE RestockDate < CURRENT_DATE
    AND (StockLevel / MaxCapacity) * 100 < 30;

-- UPDATE Query 2: Update pilot ranks for those with overdue training
UPDATE Pilot
SET Rank = CONCAT(Rank, ' (Prob.)')
WHERE NextTrainingDate +120 < CURRENT_DATE;

-- UPDATE Query 3: Adjust inspection dates to the same day of week after today
UPDATE Aircraft
SET NextInspectionDate = NextInspectionDate + 
    INTERVAL '7 days' * CEIL((CAST (CURRENT_DATE - NextInspectionDate as float)) / 7)
WHERE NextInspectionDate < CURRENT_DATE;
