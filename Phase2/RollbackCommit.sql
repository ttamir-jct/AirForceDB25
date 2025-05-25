-- Part 1: Rollback Demonstration

-- a. Initial state
SELECT StockId, location, StockLevel FROM FuelStock WHERE StockId BETWEEN 1 AND 5 order by StockId;

-- b. Update: decrease StockLevel by 500,000
UPDATE FuelStock
SET StockLevel = GREATEST(StockLevel -500000, 0)
WHERE StockId BETWEEN 1 AND 5;

-- c. State after update
SELECT StockId, location, StockLevel FROM FuelStock WHERE StockId BETWEEN 1 AND 5 order by StockId;

ROLLBACK;

-- State after rollback
SELECT StockId, location, StockLevel FROM FuelStock WHERE StockId BETWEEN 1 AND 5 order by StockId;


-- Part 2: Commit Demonstration

-- a. Initial state
SELECT AircraftId, ModelName, NextInspectionDate FROM Aircraft WHERE AircraftId BETWEEN 1 AND 5 order by AircraftId;

-- b. Update: Push inspection dates forward by 10 days
UPDATE Aircraft
SET NextInspectionDate = NextInspectionDate + INTERVAL '10 days'
WHERE AircraftId BETWEEN 1 AND 5;

-- c. State after update
SELECT AircraftId, ModelName, NextInspectionDate FROM Aircraft WHERE AircraftId BETWEEN 1 AND 5 order by AircraftId;

COMMIT;

-- State after commit
SELECT AircraftId, ModelName, NextInspectionDate FROM Aircraft WHERE AircraftId BETWEEN 1 AND 5 order by AircraftId;
