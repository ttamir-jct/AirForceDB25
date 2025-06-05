DO $$
DECLARE
    readiness_cursor REFCURSOR;
    readiness_rec RECORD;
    pilot_ids INTEGER[] := ARRAY[1001, 1002, 1003]; -- Example list of pilot IDs
BEGIN
    -- Update training dates for pilots
    CALL UpdatePilotTrainingDates(pilot_ids);

    -- Get readiness status
    readiness_cursor := GetPilotReadinessStatus(pilot_ids);
    
    -- Fetch and display readiness status
    LOOP
        FETCH readiness_cursor INTO readiness_rec;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Pilot % (%): Aircraft % (%), Status: %', 
                     readiness_rec.PilotId, readiness_rec.FullName, 
                     readiness_rec.AircraftId, readiness_rec.ModelName, 
                     readiness_rec.ReadinessStatus;
    END LOOP;

    CLOSE readiness_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in UpdateAndCheckPilotReadiness: %', SQLERRM;
END;
$$;