CREATE TABLE FuelRestockLog (
    LogId SERIAL PRIMARY KEY,
    StockId INTEGER NOT NULL,
    OldStockLevel INTEGER,
    NewStockLevel INTEGER,
    RestockTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (StockId) REFERENCES FuelStock(StockId)
);