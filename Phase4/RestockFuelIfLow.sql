CREATE OR REPLACE PROCEDURE RestockFuelIfLow(stock_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    fuel_rec RECORD;
    threshold NUMERIC;
BEGIN
    -- Fetch the fuel stock record
    SELECT StockId, StockLevel, MaxCapacity INTO fuel_rec
    FROM FuelStock
    WHERE StockId = stock_id;

    -- Check if record exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'FuelStock % does not exist', stock_id;
    END IF;

    -- Calculate threshold (90% of MaxCapacity)
    threshold := fuel_rec.MaxCapacity * 0.9;

    -- Check if stock level is below threshold
    IF fuel_rec.StockLevel < threshold THEN
        -- Update stock level to 90% of MaxCapacity
        UPDATE FuelStock
        SET StockLevel = fuel_rec.MaxCapacity * 0.9
        WHERE StockId = fuel_rec.StockId;

        RAISE NOTICE 'Restocked FuelStock %: New level = %', fuel_rec.StockId, fuel_rec.MaxCapacity * 0.9;
    ELSE
        RAISE NOTICE 'FuelStock % is already at or above 90 percent capacity: Current level = %', fuel_rec.StockId, fuel_rec.StockLevel;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in RestockFuelIfLow for StockId %: %', stock_id, SQLERRM;
END;
$$;