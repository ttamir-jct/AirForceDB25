CREATE OR REPLACE FUNCTION GetPilotReadinessStatus(pilot_ids INTEGER[])
RETURNS REFCURSOR AS $$
DECLARE
    readiness_cursor REFCURSOR := 'readiness_cursor';
BEGIN
    -- Open an explicit cursor for pilot readiness
    OPEN readiness_cursor FOR
        SELECT 
            p.PilotId,
            p.FullName,
            a.AircraftId,
            a.ModelName,
            a.NextInspectionDate,
            CASE 
                WHEN a.NextInspectionDate < CURRENT_DATE THEN 'Not Ready (Overdue Inspection)'
                WHEN a.AircraftId IS NULL THEN 'Not Assigned'
                ELSE 'Ready'
            END AS ReadinessStatus
        FROM Pilot p
        LEFT JOIN Aircraft a ON p.AircraftId = a.AircraftId
        WHERE p.PilotId = ANY(pilot_ids);

    RETURN readiness_cursor;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in GetPilotReadinessStatus: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;