CREATE OR REPLACE PROCEDURE UpdatePilotTrainingDates(pilot_ids INTEGER[])
LANGUAGE plpgsql AS $$
DECLARE
    pilot_cursor CURSOR FOR
        SELECT PilotId, FullName, NextTrainingDate
        FROM Pilot
        WHERE PilotId = ANY(pilot_ids);
    pilot_rec RECORD;
BEGIN
    -- Open explicit cursor
    OPEN pilot_cursor;

    -- Loop through pilots to update
    LOOP
        FETCH pilot_cursor INTO pilot_rec;
        EXIT WHEN NOT FOUND;

        -- Update training date
        BEGIN
            UPDATE Pilot
            SET NextTrainingDate = CURRENT_DATE + INTERVAL '6 months'
            WHERE PilotId = pilot_rec.PilotId;

            RAISE NOTICE 'Updated training date for Pilot % (%): New date = %', 
                         pilot_rec.PilotId, pilot_rec.FullName, CURRENT_DATE + INTERVAL '6 months';
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error updating Pilot %: %', pilot_rec.PilotId, SQLERRM;
                CONTINUE;
        END;
    END LOOP;

    CLOSE pilot_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in UpdatePilotTrainingDates: %', SQLERRM;
END;
$$;