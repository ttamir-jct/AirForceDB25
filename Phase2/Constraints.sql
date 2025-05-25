-- Constraint 1: CHECK on Squadron.BaseLocation (must be at least 5 characters)
ALTER TABLE Squadron
ADD CONSTRAINT check_baselocation_length CHECK (LENGTH(BaseLocation) >= 5);

--failed insert:
INSERT INTO Squadron (SquadronId, SquadronName, BaseLocation)
VALUES (1001, 'Test Squadron', 'Base');

-- Constraint 2: CHECK on Equipment.Weight that wight is positive
ALTER TABLE Equipment
ALTER COLUMN Weight SET NOT NULL,
ADD CONSTRAINT check_weight_positive CHECK (Weight > 0);
--failed insert:
INSERT INTO Equipment (EquipmentId, EquipmentType, Weight)
VALUES (1001, 'Test Radar', 0);

-- Constraint 3: DEFAULT on Pilot.Rank (default to 'Lieutenant')
ALTER TABLE Pilot
ALTER COLUMN Rank SET DEFAULT 'Lieutenant';
--insert - rank will become default:
INSERT INTO Pilot (PilotId, FullName, NextTrainingDate)
VALUES (1001, 'Test Pilot', '2025-06-01');

-- Constraints for delete query #1:

-- Add ON DELETE CASCADE to Equipped_With
ALTER TABLE Equipped_With
DROP CONSTRAINT IF EXISTS equipped_with_aircraftid_fkey,
ADD CONSTRAINT equipped_with_aircraftid_fkey
    FOREIGN KEY (AircraftId) REFERENCES Aircraft (AircraftId) ON DELETE CASCADE;

-- Modify helicopter_aircraft_fkey to include ON DELETE CASCADE
ALTER TABLE Hellicopter
DROP CONSTRAINT IF EXISTS hellicopter_aircraftid_fkey,
ADD CONSTRAINT hellicopter_aircraftid_fkey
    FOREIGN KEY (AircraftId) REFERENCES Aircraft (AircraftId) ON DELETE CASCADE;

-- Modify plane_aircraft_fkey to include ON DELETE CASCADE
ALTER TABLE Plane
DROP CONSTRAINT IF EXISTS plane_aircraftid_fkey,
ADD CONSTRAINT plane_aircraftid_fkey
    FOREIGN KEY (AircraftId) REFERENCES Aircraft (AircraftId) ON DELETE CASCADE;
