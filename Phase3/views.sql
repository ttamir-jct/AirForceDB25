-- Step 1: Modify existing tables with new columns as NULL first
ALTER TABLE Aircraft
ADD BoardingCapacity INT ,
ADD productiondate DATE ,
ADD status VARCHAR(50) DEFAULT 'Active' NOT NULL,
ADD MaxAltitude INT ;

-- Step 2: Populate new columns in Aircraft with default values for existing rows
UPDATE Aircraft
SET 
    BoardingCapacity = 1, -- Default value
    productiondate = '2020-08-06', -- Default value
    MaxAltitude = 30000 -- Default value
WHERE BoardingCapacity IS NULL ;

-- Step 3: Modify Pilot table with new columns as NULL
ALTER TABLE Pilot
ADD license_num VARCHAR(50),
ADD experience INT;

-- Step 4: Populate new columns in Pilot with default values for existing rows
UPDATE Pilot
SET 
    license_num = 'UNKNOWN-' || PilotId, -- Generate a default license number
    experience = 5 -- Default value (years)
WHERE license_num IS NULL;

-- Step 5: Move existing data from Helicopter and Plane to Aircraft
-- Update BoardingCapacity from Helicopter
UPDATE Aircraft a
SET BoardingCapacity = (select BoardingCapacity from Hellicopter h2 where h2.AircraftId=a.AircraftId)
WHERE EXISTS (select * from Hellicopter h where h.AircraftId=a.AircraftId);


-- Step 6: Drop columns from Helicopter and Plane after data migration
ALTER TABLE Hellicopter
DROP COLUMN BoardingCapacity;

-- Step 7: Set new columns to NOT NULL with defaults where applicable
ALTER TABLE Aircraft
ALTER COLUMN BoardingCapacity SET NOT NULL,
ALTER COLUMN productiondate SET NOT NULL,
ALTER COLUMN status SET DEFAULT 'Active',
ALTER COLUMN status SET NOT NULL,
ALTER COLUMN MaxAltitude SET NOT NULL;

ALTER TABLE Pilot
ALTER COLUMN license_num SET NOT NULL,
ALTER COLUMN experience SET NOT NULL;

-- Step 8: Create new tables
CREATE TABLE hub (
    hub_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    location VARCHAR(80) NOT NULL,
    iata_code VARCHAR(10) NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE hangar (
    hangar_id INT PRIMARY KEY,
    location VARCHAR(80) NOT NULL,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE operator (
    operator_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    fleet_size INT NOT NULL,
    type VARCHAR(30) NOT NULL,
    hub_id integer NOT NULL
);

CREATE TABLE producer (
    producer_id INT PRIMARY KEY,
    pname VARCHAR(50) NOT NULL,
    estdate DATE NOT NULL,
    owner VARCHAR(50) NOT NULL
);

-- Step 9: import data for 4 new tables - done manually

--step 10: add relationship fields without FK constraints
--pilot.operatorID
ALTER TABLE Pilot
ADD operator_id INT;
--aircraft.operatorId, aircraft.producerId, aircraft.hangarId
ALTER TABLE Aircraft
ADD operator_id INT,
ADD producer_id INT,
ADD hangar_id INT;

--step 10: fill in relationship fields with randomized integers (basing on the fact that all IDs in the coworker's table range from 1-400)
UPDATE Pilot
SET operator_id= (RANDOM()*400)
WHERE operator_id IS NULL;

UPDATE Aircraft
SET operator_id = (RANDOM()*400),
producer_id = (RANDOM()*400),
hangar_id = (RANDOM()*400)
WHERE operator_id IS NULL;

--step 11: add required relationship constraints - convert relationship fields to FKs
ALTER TABLE Aircraft ADD FOREIGN KEY (hangar_id) REFERENCES hangar(hangar_id);
ALTER TABLE Aircraft ADD FOREIGN KEY (producer_id) REFERENCES producer(producer_id);
ALTER TABLE Aircraft ADD FOREIGN KEY (operator_id) REFERENCES operator(operator_id);
ALTER TABLE Pilot ADD FOREIGN KEY (operator_id) REFERENCES operator(operator_id);
ALTER TABLE Operator ADD FOREIGN KEY (hub_id) REFERENCES hub(hub_id);

--steps for migration of coworker's plane and pilot data

--step 12: add defaults for fields in plane,aircraft and pilot that do not exist in coworker's plane and pilot schemas
ALTER TABLE Aircraft
ALTER COLUMN NextInspectionDate SET DEFAULT CURRENT_DATE + 60,
ALTER COLUMN FuelCapacity SET default 5000,
ALTER COLUMN SquadronId SET default 1,
ALTER COLUMN StockId SET default 1,
ALTER COLUMN FuelTypeId set default 2;

ALTER TABLE Pilot
ALTER COLUMN NextTrainingDate SET DEFAULT CURRENT_DATE + 60;

ALTER TABLE Plane
ALTER COLUMN prepTime SET DEFAULT 3;

--step 13: create temp tables to store the coworker's data
CREATE TABLE pilot_temp (
    pilot_id integer NOT NULL,
    name character varying(50) NOT NULL,
    license_num character varying(30) NOT NULL,
    rank character varying(20) NOT NULL,
    experience integer NOT NULL,
    operator_id integer NOT NULL
);


CREATE TABLE plane_temp (
    plane_id integer NOT NULL,
    model character varying(25) NOT NULL,
    productiondate date NOT NULL,
    capacity integer NOT NULL,
    maxaltitude integer NOT NULL,
    maxdistance integer NOT NULL,
    status character varying(30) NOT NULL,
    producer_id integer NOT NULL,
    hangar_id integer NOT NULL,
    operator_id integer NOT NULL
);


CREATE TABLE pilot_plane_temp (
    assignment_date date NOT NULL,
    plane_id integer NOT NULL,
    pilot_id integer NOT NULL
);
--add the data from the coworker's tables into temp tables - done manually
--step 14: insert the data from the foriegn table, apply the shift of aircraftId = 1||aircraftId, pilotId = 1||pilotId,  and braking plane data into relevant fields for aircraft and plane
insert into pilot (pilotid,fullname,license_num, rank,experience,operator_id)
(select pilot_id+1000 as pilotId,
name as FullName,
license_num, rank,experience,operator_id
From pilot_temp);

insert into aircraft (aircraftid,modelname,productiondate,boardingcapacity,maxaltitude,status,producer_id,hangar_id,operator_id)
(select plane_id+1000,model,productiondate,capacity,maxaltitude,status,producer_id,hangar_id,operator_id
From plane_temp);

insert into plane(aircraftId, maxRange)
(select plane_id+1000,maxdistance as MaxRange
From plane_temp);

update pilot tmp
set aircraftid = (select plane_id from pilot_plane_temp where pilot_id=tmp.pilotid-1000 ORDER BY assignment_date DESC LIMIT 1 )+1000
where exists(select plane_id from pilot_plane_temp where pilot_id=tmp.pilotid-1000)

--step 15: remove  defaults added in step 11
ALTER TABLE Aircraft
ALTER COLUMN FuelCapacity drop default,
ALTER COLUMN SquadronId drop default,
ALTER COLUMN StockId drop default,
ALTER COLUMN FuelTypeId drop default;

ALTER TABLE Plane
ALTER COLUMN prepTime drop default;


--step 16: drop the temp tables
DROP TABLE plane_temp;
DROP TABLE pilot_temp;
DROP TABLE pilot_plane_temp;