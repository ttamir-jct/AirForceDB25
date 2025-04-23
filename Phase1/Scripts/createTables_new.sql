CREATE TABLE Equipment
(
  EquipmentId INT NOT NULL,
  EquipmentType VARCHAR(50) NOT NULL,
  Weight INT NOT NULL,
  PRIMARY KEY (EquipmentId)
);

CREATE TABLE Squadron
(
  SquadronId INT NOT NULL,
  SquadronName VARCHAR(40) NOT NULL,
  BaseLocation VARCHAR(40) NOT NULL,
  PRIMARY KEY (SquadronId)
);

CREATE TABLE FuelType
(
  FuelTypeId INT NOT NULL,
  FuelTypeName VARCHAR(40) NOT NULL,
  PRIMARY KEY (FuelTypeId)
);

CREATE TABLE FuelStock
(
  StockId INT NOT NULL,
  Location VARCHAR(40) NOT NULL,
  StockLevel INT NOT NULL,
  MaxCapacity INT NOT NULL,
  RestockDate DATE NOT NULL,
  FuelTypeId INT NOT NULL,
  PRIMARY KEY (StockId),
  FOREIGN KEY (FuelTypeId) REFERENCES FuelType(FuelTypeId)
);

CREATE TABLE Aircraft
(
  NextInspectionDate DATE NOT NULL,
  AircraftId INT NOT NULL,
  ModelName VARCHAR(40) NOT NULL,
  FuelCapacity INT NOT NULL,
  SquadronId INT NOT NULL,
  StockId INT,
  FuelTypeId INT NOT NULL,
  PRIMARY KEY (AircraftId),
  FOREIGN KEY (SquadronId) REFERENCES Squadron(SquadronId),
  FOREIGN KEY (StockId) REFERENCES FuelStock(StockId),
  FOREIGN KEY (FuelTypeId) REFERENCES FuelType(FuelTypeId),
  CONSTRAINT chk_fueltype_match CHECK (
        StockId IS NULL OR 
        FuelTypeId = (SELECT FuelTypeId FROM FuelStock WHERE FuelStock.StockId = Aircraft.StockId)
    )
);

CREATE TABLE Hellicopter
(
  BoardingCapacity INT NOT NULL,
  PayloadCapacity INT NOT NULL,
  MaxHoverTime INT NOT NULL,
  AircraftId INT NOT NULL,
  PRIMARY KEY (AircraftId),
  FOREIGN KEY (AircraftId) REFERENCES Aircraft(AircraftId)
);

CREATE TABLE Plane
(
  PrepTime INT NOT NULL,
  MaxRange INT NOT NULL,
  AircraftId INT NOT NULL,
  PRIMARY KEY (AircraftId),
  FOREIGN KEY (AircraftId) REFERENCES Aircraft(AircraftId)
);

CREATE TABLE Pilot
(
  PilotId INT NOT NULL,
  FullName VARCHAR(50) NOT NULL,
  NextTrainingDate DATE NOT NULL,
  Rank VARCHAR(10),
  AircraftId INT,
  PRIMARY KEY (PilotId),
  FOREIGN KEY (AircraftId) REFERENCES Aircraft(AircraftId)
);

CREATE TABLE Equipped_With
(
  Quantity INT NOT NULL,
  AircraftId INT NOT NULL,
  EquipmentId INT NOT NULL,
  PRIMARY KEY (AircraftId, EquipmentId),
  FOREIGN KEY (AircraftId) REFERENCES Aircraft(AircraftId),
  FOREIGN KEY (EquipmentId) REFERENCES Equipment(EquipmentId)
);