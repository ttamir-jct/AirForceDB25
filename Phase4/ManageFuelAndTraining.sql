DO $$
DECLARE
    stock_id INTEGER;
    next_restock_date DATE;
    stock_ids INTEGER[] := ARRAY[]; -- fill with actual stock IDs
BEGIN
    -- Loop through each stock ID
    FOREACH stock_id IN ARRAY stock_ids
    LOOP
        BEGIN
            -- Restock the fuel stock
            CALL RestockFuelIfLow(stock_id);

            -- Calculate and update the next restock date
            next_restock_date := CalculateNextRestockDate(stock_id);
            UPDATE FuelStock
            SET RestockDate = next_restock_date
            WHERE StockId = stock_id;

            RAISE NOTICE 'Updated RestockDate for FuelStock % to %', stock_id, next_restock_date;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error processing FuelStock %: %', stock_id, SQLERRM;
                CONTINUE;
        END;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in ManageFuelAndTraining: %', SQLERRM;
END;
$$;