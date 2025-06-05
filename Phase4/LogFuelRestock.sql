CREATE OR REPLACE FUNCTION LogFuelRestock()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO FuelRestockLog (StockId, OldStockLevel, NewStockLevel)
    VALUES (OLD.StockId, OLD.StockLevel, NEW.StockLevel);
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in LogFuelRestock: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER FuelRestockLogTrigger
AFTER UPDATE OF StockLevel ON FuelStock
FOR EACH ROW
WHEN (OLD.StockLevel IS DISTINCT FROM NEW.StockLevel)
EXECUTE FUNCTION LogFuelRestock();