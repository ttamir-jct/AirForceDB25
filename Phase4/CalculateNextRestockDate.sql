CREATE OR REPLACE FUNCTION CalculateNextRestockDate(stock_id INTEGER)
RETURNS DATE AS $$
DECLARE
    fuel_rec RECORD;
    aircraft_rec RECORD;
    total_daily_consumption NUMERIC := 0;
    current_level NUMERIC;
    threshold_level NUMERIC;
    days_until_threshold INTEGER;
    DAILY_CONSUMPTION_RATE CONSTANT NUMERIC := 0.1; -- 10% of FuelCapacity per aircraft per day
BEGIN
    -- Fetch the fuel stock record
    SELECT StockId, StockLevel, MaxCapacity INTO fuel_rec
    FROM FuelStock
    WHERE StockId = stock_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'FuelStock % does not exist.', stock_id;
    END IF;

    -- Calculate current level and threshold (30% of MaxCapacity)
    current_level := fuel_rec.StockLevel;
    threshold_level := fuel_rec.MaxCapacity * 0.3;

    -- Calculate total daily consumption by linked aircraft
    FOR aircraft_rec IN SELECT FuelCapacity
                       FROM Aircraft
                       WHERE StockId = stock_id
    LOOP
        total_daily_consumption := total_daily_consumption + (aircraft_rec.FuelCapacity * DAILY_CONSUMPTION_RATE);
    END LOOP;

    -- Avoid division by zero
    IF total_daily_consumption = 0 THEN
        RAISE NOTICE 'No aircraft linked to FuelStock %. Setting restock date to 30 days from now.', stock_id;
        RETURN CURRENT_DATE + INTERVAL '30 days';
    END IF;

    -- Calculate days until stock reaches 30%
    days_until_threshold := FLOOR((current_level - threshold_level) / total_daily_consumption);

    -- Return estimated restock date
    RETURN CURRENT_DATE + (days_until_threshold * INTERVAL '1 day');
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in CalculateNextRestockDate for StockId %: %', stock_id, SQLERRM;
END;
$$ LANGUAGE plpgsql;