CREATE OR REPLACE FUNCTION ValidateTrainingDateAndRemoveProbation()
RETURNS TRIGGER AS $$
DECLARE
    new_rank VARCHAR(50);
BEGIN
    -- Validate that the new training date is in the future
    IF NEW.NextTrainingDate <= CURRENT_DATE THEN
        RAISE EXCEPTION 'NextTrainingDate (%) must be after the current date (%) for Pilot %', 
                        NEW.NextTrainingDate, CURRENT_DATE, NEW.PilotId;
    END IF;

    -- Check if rank has probation status (e.g., 'Captain (Prob.)')
    IF NEW.Rank LIKE '%(Prob.)' THEN
        -- Remove '(Prob.)' from rank
        new_rank := REGEXP_REPLACE(NEW.Rank, '\s*\(Prob\.\)$', '');
        UPDATE Pilot
        SET Rank = new_rank
        WHERE PilotId = NEW.PilotId;
        RAISE NOTICE 'Removed probation status for Pilot %: New rank = %', NEW.PilotId, new_rank;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in ValidateTrainingDateAndRemoveProbation: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TrainingDateValidation
AFTER UPDATE OF NextTrainingDate ON Pilot
FOR EACH ROW
EXECUTE FUNCTION ValidateTrainingDateAndRemoveProbation();