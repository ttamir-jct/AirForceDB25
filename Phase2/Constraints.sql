-- Constraint 1: CHECK on Squadron.BaseLocation (must be at least 5 characters)
ALTER TABLE Squadron
ADD CONSTRAINT check_baselocation_length CHECK (LENGTH(BaseLocation) >= 5);

-- Constraint 2: NOT NULL on Equipment.Weight
ALTER TABLE Equipment
ALTER COLUMN Weight SET NOT NULL;

-- Constraint 3: DEFAULT on Pilot.Rank (default to 'Lieutenant')
ALTER TABLE Pilot
ALTER COLUMN Rank SET DEFAULT 'Lieutenant';