# Air Force Resources Database

**Submitted by:** Tzur Tamir 207876525 
**System:** Air Force Management  
**Unit:** Air Force Resources Management 

## Table of Contents
- [Phase 1](#phase-1)
	- [Introduction](#introduction)
	- [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)
	- [DSD (Data Structure Diagram)](#dsd-data-structure-diagram)
	- [SQL Scripts](#sql-scripts)
	- [Data Insertion Methods](#data-insertion-methods)
	- [Backup and Restore](#backup-and-restore)
- [Phase 2](#phase-2-database-querying-updates-and-constraints)
	- [Select Queries](#select-queries)
	- [Delete Queries](#delete-queries)
	- [Update Queries](#update-queries)
	- [Constraints](#constraints)
	- [Rollback and Commit](#rollback-and-commit)
-  [Phase 3](#phase-3-database-integration-and-views)
	- [Integration Process and Decisions](#integration-process-and-decisions)
	- [Diagrams](#diagrams)
	- [Schema Modifications](#schema-modifications)
	- [Data Migration](#data-migration)
	- [SQL Implementation](#sql-implementation)
- [Views and Queries](#views-and-queries)
	- [View 1: Original Department Perspective](#view-1-aircraft_pilot_status-original-department-perspective)
	- [Query 1 for view 1: Upcoming Inspections and Training](#query-1-for-aircraft_pilot_status-upcoming-inspections-and-training)
	- [Query 2 for view 1: Aircraft Count by Pilot Rank](#query-2-for-aircraft_pilot_status-aircraft-count-by-pilot-rank)
	- [View 2: Coworker’s Department Perspective](#view-2-plane_operator_details-coworkers-department-perspective)
	- [Query 1 for view 2: High Capacity and Long Range Planes](#query-1-for-plane_operator_details-high-capacity-and-long-range-planes)
	- [Query 2 forview 2: Average Max Distance by Operator Type](#query-2-for-plane_operator_details-average-max-distance-by-operator-type)

# Phase 1

## Introduction

The **Air Force Resources Database** is designed to manage critical information related to aircraft operations, including aircraft details, pilots, squadrons, equipment, and fuel stocks. This system is built using PostgreSQL running in a Docker container, providing a robust and scalable solution for organizing air force resources.

### Purpose and Functionality
This database stores and manages the following data:
- **Aircraft**: Details such as model names, inspection dates, and fuel capacities, with inherited subtypes:
    - **planes**: Additional plane-specific details.
    - **helicopters**: Additional hellicopter-specific details.
- **Pilots**: Information including names, training dates, ranks, and aircraft assignments.
- **Squadrons**: Organizational groups of aircraft with names and base locations.
- **Equipment**: Types and weights of equipment assigned to aircraft.
- **Fuel Stocks**: Fuel storage details like location, stock levels, and restock dates, linked to specific fuel types.

The primary functionalities include:
- Organizing aircraft into squadrons for operational management.
- Assigning pilots to aircraft for mission planning.
- Tracking equipment allocations to aircraft.
- Managing fuel stocks and ensuring compatibility with aircraft requirements.
- Storing and retrieving detailed records for administrative and operational use.

This system enhances efficiency, safety, and coordination within air force operations by providing a centralized data management solution.

### Design Decisions
- **Inheritance**: Aircraft is a supertype with Plane and Helicopter as subtypes to handle specific attributes (e.g., MaxRange for Planes, MaxHoverTime for Helicopters).
- **Relationships**: Used many-to-many (M:N) for Equipped_With to allow flexible equipment assignments, and one-to-many (1:N) for Fuels_From and Uses to reflect fuel stock and type dependencies.
- **Optional Links**: Assigned_To (Pilot-Aircraft) is optional on both sides to accommodate unassigned pilots or aircraft.

For detailed relationship explanations, see [Relationships](#relationships) below.

## ERD (Entity-Relationship Diagram)
![ERD Diagram](Phase1/ERD&DSD/ERD_COLORED.png)  
*The ERD visualizes entities and their relationships as designed in the project.*

### Entities and Attributes

The following table explains the differnt entities and thier attributes in detail:

| Entity (Description) | Attribute |
|----------------------|-----------|
| **Equipment** (Unique identifier for equipment (Primary Key)) | EquipmentId |
| (Type of equipment (e.g., radar, weapon)) | EquipmentType |
| (Weight of equipment in kg) | Weight |
| **Aircraft** (Unique identifier for aircraft (Primary Key)) | AircraftId |
| (Model name of the aircraft (e.g., F-16)) | ModelName |
| (Date of the next maintenance inspection) | NextInspectionDate |
| (Fuel capacity in liters) | FuelCapacity |
| **Helicopter** (A type of Aircraft) (Unique identifier for helicopter, inherited from Aircraft) | AircraftId |
| (Number of people that can be boarded) | BoardingCapacity |
| (Payload capacity in kg) | PayloadCapacity |
| (Maximum hover time in hours) | MaxHoverTime |
| **Plane** (A type of Aircraft) (Unique identifier for plane, inherited from Aircraft) | AircraftId |
| (Preparation time for flight in hours) | PrepTime |
| (Maximum flight range in km) | MaxRange |
| **Pilot** (Unique identifier for pilot (Primary Key)) | PilotId |
| (Full name of the pilot) | FullName |
| (Date of the next training) | NextTrainingDate |
| (Military rank) | Rank |
| **Squadron** (Unique identifier for aircraft squadron (Primary Key)) | SquadronId |
| (Name of the squadron) | SquadronName |
| (Base location) | BaseLocation |
| **FuelStock** (Unique identifier for fuel stock (Primary Key)) | StockId |
| (Location of the stock) | Location |
| (Stock content in liters (currently filled)) | StockLevel |
| (Restock date) | RestockDate |
| **FuelType** (Unique identifier for fuel type (Primary Key)) | FuelTypeId |
| (Name of the fuel type (e.g., JP-8)) | FuelTypeName |
| **Equipped_With (Relationship)** (Aircraft identifier (part of composite key)) | AircraftId |
| (Equipment identifier (part of composite key)) | EquipmentId |
| (Quantity of equipment assigned to aircraft) | Quantity |


### Relationships
The following table explains the different relationships in the ERD:

| Relationship Name | Description |
|-------------------|-------------|
| **Part_Of**       | A Squadron consists of many Aircraft (1:N). An Aircraft must belong to a Squadron, and a Squadron must consist of Aircrafts. |
| **Assigned_To**   | An Aircraft is assigned to one Pilot (1:1), optional on both sides as an Aircraft may lack a Pilot and vice versa. |
| **Equipped_With** | An Aircraft can have multiple Equipment types, and an Equipment type can serve multiple Aircraft (M:N), optional since not all Aircraft require special equipment. |
| **Fuels_From**    | An Aircraft refuels from one FuelStock, and one FuelStock can serve multiple Aircraft (1:N). Each Aircraft must have a FuelStock, but a FuelStock may not yet serve any Aircrafts. |
| **Uses**          | An Aircraft requires one FuelType (1:N), mandatory for Aircraft to have a type, optional for a FuelType to be used by any Aircrafts. |
| **Filled_With**   | A FuelStock contains one FuelType, and one FuelType can fill multiple FuelStocks (1:N). A FuelStock must have a FuelType, but a FuelType may not have associated FuelStocks. |

## DSD (Data Structure Diagram)
![DSD Diagram](Phase1/ERD&DSD/DSD_COLORED.png)  
*The DSD outlines the relational schema derived from the ERD.*

## SQL Scripts
The following SQL scripts are provided in the repository:
- **Create Tables**: Defines all tables and triggers.  
  📜 **[View `createTables.sql`](Phase1/Scripts/createTables.sql)**  
- **Insert Data**: Adds initial sample data.  
  📜 **[View `insertTables.sql`](Phase1/Scripts/insertTables.sql)**  
- **Drop Tables**: Removes all tables in the correct order.  
  📜 **[View `dropTables.sql`](Phase1/Scripts/dropTables.sql)**  
- **Select All Tables**: Retrieves all data from each table.  
  📜 **[View `selectTables.sql`](Phase1/Scripts/selectTables.sql)**  

## Data Insertion Methods
Data was added to the database using three distinct methods:

### 1. Python Script (Squadron, FuelStock)
- **Tool**: Custom Python script to generate SQL insert statements.
- **Details**: 
  - **Squadron**: 400 rows with unique SquadronId, names (e.g., "Hawk-504B-001"), and base locations from a list of 22 options.
  - **FuelStock**: 400 rows with StockId, locations (e.g., "Warehouse A-1"), stock levels (a fraction between 0 and 1 to represent fullness ), and FuelTypeId linked to the existing 20 fuel types.
- **Files**:  
  📜 **[View `generate_sql.py`](Phase1/Programming/generate_sql.py)**
  📜 **[View `insert_squadron_fuel.sql`](Phase1/Programming/insert_squadron_fuel.sql)**  

- **Screenshots**:  
  ![running insert_squadron_fuel.sql](Phase1/Programming/sql_run)

  *running insert_squadron_fuel.sql in pgAdmin query tool.*
  
  ![result](Phase1/Programming/sql_res)

  *data successfuly added.*

### 2. Mockaroo (Aircraft, Helicopter, Plane, Equipment)
- **Tool**: [Mockaroo](https://www.mockaroo.com/) for generating realistic mock data.
- **Details**: 
  - **Aircraft**: 800 rows (AircraftId 1-800) with model names, inspection dates, and fuel capacities.
  - **Helicopter**: Subset of Aircraft with boarding and payload capacities, and hover times. 400 rows (AircraftId 1-400).
  - **Plane**: Subset of Aircraft with prep times and max ranges. 400 rows (AircraftId 401-800).
  - **Equipment**: 400 rows (EquipmentId 1-400) with types (e.g., "Radar-001") and weights (100-1000 kg).
- **Files**:
  📜 **[View `AIRCRAFT_MOCK_DATA.csv`](Phase1/FilesMockaroo/AIRCRAFT_MOCK_DATA_data.csv)**  
  📜 **[View `HELICOPTER_MOCK_DATA.csv`](Phase1/FilesMockaroo/HELICOPTER_MOCK_DATA_data.csv)**  
  📜 **[View `PLANE_MOCK_DATA.csv`](Phase1/FilesMockaroo/PLANE_MOCK_DATA_data.csv)**  
  📜 **[View `EQUIPMENT_MOCK_DATA.csv`](Phase1/FilesMockaroo/EQUIPMENT_MOCK_DATA_data.csv)**  
- **Screenshots**:  
  ![aircraft mockaroo](Phase1/FilesMockaroo/aircraft.png)

  *mockaroo aircraft configs.*
  
  ![helicopter mockaroo](Phase1/FilesMockaroo/helicopter.png)

  *helicopter aircraft configs.*
  
  ![plane mockaroo](Phase1/FilesMockaroo/plane.png)

  *mockaroo aircraft configs. applied the formula 'this+400' to aircraftId to match id scope of 401-800.*
  
  ![equipment mockaroo](Phase1/FilesMockaroo/aircraft.png)

  *mockaroo equipment configs. equipment name is generated from a combination of its general type {eq1} and its serial number{eq2}, consisting of three digits and a letter (e.g 107Z). the formula 'toUpper(this)' was applied on {eq2} for the letter in the serial number to be converted to its uppercase equivelant.*
  
  ![image](https://github.com/user-attachments/assets/a0617035-d214-45ca-a980-b92d576cdefd)

  *uploading the generated csv mock data for aircraft.*
  
  ![image](https://github.com/user-attachments/assets/794b8287-1991-415c-a5fb-1f55ec3fdc3e)

  *result of row count for aircraft after upload.*


### 3. CSV Files (Equipped_With, Pilot)
- **Tool**: Pre-generated CSV files imported via the pgAdmin 'import data' option.
- **Details**: 
  - **Equipped_With**: 500 rows linking AircraftId (1-800) to EquipmentId (1-400) with quantities (1-4).
  - **Pilot**: 500 rows (PilotId 1-500) with names (e.g., "James Smith"), next training dates, ranks, and optional AircraftId (50% linked to 1-800).
- **Files**:  
  📜 **[View `Pilot_data.csv`](Phase1/DataImportFiles/Pilot_data.csv)**  
  📜 **[View `EquippedWith_data.csv`](Phase1/DataImportFiles/EquippedWith_data.csv)**  
- **Screenshots**:
  *Showing CSV import process for EquippedWith in pgAdmin:*

   ![image](https://github.com/user-attachments/assets/d28d451f-9048-456c-88d4-5d0b4452f058)
  
  ![image](https://github.com/user-attachments/assets/1c7cc125-8a96-4575-a85c-15d48816429b)
  
  ![image](https://github.com/user-attachments/assets/160c877b-aa06-4b2d-aff8-3a9b4e12a492)

  *result of row count for EquippedWith after upload.*


  **Note:** Since FuelType is no more than a lookup table meant to inhance storage efficiency by storing the finite set of fuel names for the use of other tables, we decided it makes more sense to provide all of its data as part of the [`insertTables.sql`](Phase1/Scripts/insertTables.sql) mentioned above. That is also the reason that we decided it should have 20 rows and not 400. (It does not make since to treat this table like others, for it is the same as a "status" table, providing a finite, mostly predefined set of options).

## Backup and Restore
- **Backup**: Data is backed up using pgAdmin's backup database option.
  - Files are stored with date and time stamps.  
  📁 **[View Backup Folder](Phase1/Backup)**

 ![image](https://github.com/user-attachments/assets/eebc7fdd-2e77-48ef-a75e-5dfb9c93e772)
 
 *Showing backup result file.*
 
- **Restore**:
 Running the backup file on an empty dataset:
  
![image](https://github.com/user-attachments/assets/eccc5525-536d-47e4-b827-4661f1c9a52b)

![image](https://github.com/user-attachments/assets/16ca87f6-cd85-47a1-88f3-3cc4ce4c8bb1)
 
  *Showing restore execution and verification.*


## Edit: FuelStock Enhancements

### Reasons for the changes
To enhance the realism of the FuelStock table, the schema was updated to include MaxCapacity, and StockLevel was converted from a percentage to liters. These changes were applied to the existing 400 rows while preserving data integrity.

**updated ERD:**
![image](Phase1/ERD&DSD/ERD_NEW_COLORED.png)

### Changes Made
- **Addition of MaxCapacity**:
  - A new column, MaxCapacity, was added to define the maximum storage capacity of each fuel stock in liters.
  - The default MaxCapacity was set to 2,500,000 liters to reflect a realistic scale for air force fuel stocks.
    ```sql
    ALTER TABLE FuelStock ADD COLUMN MaxCapacity INT NOT NULL DEFAULT 2500000;
  - For existing rows, MaxCapacity was set as the greater of 1,500,000 liters or 3,500,000 * StockLevel (where StockLevel was the original percentage scaled appropriately).
    ```sql
    UPDATE FuelStock SET MaxCapacity = GREATEST(3500000 * StockLevel, 1500000);
    
- **Conversion of StockLevel**:
  - Originally, StockLevel represented the fill percentage (0-1). It was converted to liters by calculating the lesser of 2,500,000 * StockLevel (scaled) or the MaxCapacity.
  - This makes StockLevel a concrete volume in liters, aligned with MaxCapacity.
    ```sql
    UPDATE FuelStock SET StockLevel = LEAST(2500000 * StockLevel, MaxCapacity);
    
- **Creating Realistic Distribution**:
  - After conversion, most stocks were around 70% full. To introduce variety in fill levels, the following query was executed:
    ```sql
    UPDATE FuelStock
    SET StockLevel = LEAST(StockLevel * (RANDOM() * (1.44 - 0.8) + 0.8), MaxCapacity);
- an updated version of the files 'createTables.sql', 'insertTables.sql' was added to the [scripts](Phase1/Scripts) directory to ensure compatability with the updated schema.


# Phase 2: Database Querying, Updates, and Constraints


In Phase 2, we enhance the Air Force Resources Database with complex SELECT, DELETE, and UPDATE queries, add constraints for data integrity, and demonstrate transaction management using ROLLBACK and COMMIT. Queries involve multiple tables, subqueries, and date manipulations to provide actionable insights for air force operations.

## SELECT Queries
📜 **[View `Queries.sql`](Phase2\Queries.sql)**  
### Query 1: Aircraft Needing Inspection This Month with Squadron Details

**Description**: Identifies aircraft scheduled for inspection in the current month (May 2025), showing aircraft ID, model name, inspection date (year and month), squadron name, and base location. Supports maintenance scheduling in the GUI.

-   **Query**:
	```sql
	SELECT  a.AircraftId, a.ModelName, a.NextInspectionDate, EXTRACT(YEAR  FROM a.NextInspectionDate) AS InspectionYear, EXTRACT(MONTH  FROM a.NextInspectionDate) AS InspectionMonth, s.SquadronName, s.BaseLocation FROM Aircraft a JOIN Squadron s ON a.SquadronId = s.SquadronId WHERE  EXTRACT(MONTH  FROM a.NextInspectionDate) = EXTRACT(MONTH  FROM  CURRENT_DATE) AND  EXTRACT(YEAR  FROM a.NextInspectionDate) =  EXTRACT(YEAR  FROM  CURRENT_DATE) ORDER  BY a.NextInspectionDate;

-   **Execution + Result Screenshot**:
![image](https://github.com/user-attachments/assets/d7290645-71df-45be-9910-fceda5f0ae75)


### Query 2: Pilots with Overdue Training

**Description**: Lists pilots with overdue training, showing pilot ID, name, training date, days overdue, and assigned aircraft model. Uses LEFT JOIN to include unassigned pilots. Helps prioritize retraining in the GUI.

-   **Query**:
	```sql
	SELECT  p.PilotId, p.FullName, p.NextTrainingDate, EXTRACT(DAY  FROM AGE(CURRENT_DATE, p.NextTrainingDate)) AS DaysOverdue, a.ModelName AS AssignedAircraft FROM Pilot p LEFT  JOIN Aircraft a ON p.AircraftId = a.AircraftId WHERE p.NextTrainingDate <  CURRENT_DATE  ORDER  BY DaysOverdue DESC;

-   **Execution + Result Screenshot**:
![image](https://github.com/user-attachments/assets/b044f4ae-f355-41c2-9463-6b696d6ff2d8)


### Query 3: Fuel Stocks Needing Restocking Soon

**Description**: Identifies fuel stocks needing restocking within 7 days (from May 25, 2025), showing stock ID, location, stock level, restock date, fuel type, and aircraft count. Supports fuel management in the GUI.

-   **Query**:
	```sql
	SELECT  fs.StockId, fs.Location, fs.StockLevel, fs.RestockDate, ft.FuelTypeName, (SELECT  COUNT(*) FROM Aircraft a WHERE a.StockId = fs.StockId) AS AircraftCount FROM FuelStock fs JOIN FuelType ft ON fs.FuelTypeId = ft.FuelTypeId WHERE fs.RestockDate <=  CURRENT_DATE  +  INTERVAL  '7 days'  AND fs.RestockDate >= CURRENT_DATE  ORDER  BY fs.RestockDate;


-   **Execution + Result Screenshot**:
![image](https://github.com/user-attachments/assets/888693c1-14ad-4139-b5fe-901cdd96d48c)


### Query 4: Average Equipment Weight per Aircraft Model

**Description**: Calculates average equipment weight per aircraft model, showing model name, aircraft count, and average weight. Uses GROUP BY and HAVING to filter models with equipment. Aids load analysis in the GUI.

-   **Query**:
	```sql
	SELECT  a.ModelName, COUNT(DISTINCT ew.AircraftId) AS AircraftCount, ROUND(AVG(e.Weight * ew.Quantity), 2) AS AvgEquipmentWeight FROM Aircraft a LEFT  JOIN Equipped_With ew ON a.AircraftId = ew.AircraftId LEFT  JOIN Equipment e ON ew.EquipmentId = e.EquipmentId GROUP  BY a.ModelName HAVING  COUNT(DISTINCT ew.AircraftId) >  0  ORDER  BY AvgEquipmentWeight DESC;

-   **Execution + Result Screenshot**:
![image](https://github.com/user-attachments/assets/4ccce907-a2d1-4997-9961-d0ede3d4b925)


### Query 5: Helicopters with Above-Average Boarding Capacity

**Description**: Lists helicopters with boarding capacity above the average, showing helicopter ID, model name, capacity, and squadron name. Uses a subquery to calculate the average. Supports troop transport planning in the GUI.

-   **Query**:
	```sql
	SELECT  h.AircraftId, a.ModelName, h.BoardingCapacity, s.SquadronName FROM Hellicopter h JOIN Aircraft a ON h.AircraftId = a.AircraftId JOIN Squadron s ON a.SquadronId = s.SquadronId WHERE h.BoardingCapacity > ( SELECT  AVG(BoardingCapacity) FROM Hellicopter ) ORDER  BY h.BoardingCapacity DESC;


-   **Execution + Result Screenshot**: 
![image](https://github.com/user-attachments/assets/f9cfc1c7-b7ff-4033-9eb6-99cbb653bce9)


### Query 6: Planes with the Longest Range per Squadron

**Description**: Identifies the plane with the longest range in each squadron, showing squadron name, aircraft ID, model name, range, and pilot name. Uses a nested subquery with LIMIT 1. Supports long-range mission planning in the GUI.

-   **Query**:
	```sql
	SELECT  s.SquadronName, p.AircraftId, a.ModelName, p.MaxRange, pi.FullName AS PilotName FROM Plane p JOIN Aircraft a ON p.AircraftId = a.AircraftId JOIN Squadron s ON a.SquadronId = s.SquadronId LEFT  JOIN Pilot pi ON a.AircraftId = pi.AircraftId WHERE (p.AircraftId, p.MaxRange) IN ( SELECT p2.AircraftId, p2.MaxRange FROM Plane p2 JOIN Aircraft a2 ON p2.AircraftId = a2.AircraftId WHERE a2.SquadronId = s.SquadronId ORDER  BY p2.MaxRange DESC  LIMIT 1  ) ORDER  BY p.MaxRange DESC;


-   **Execution + Result Screenshot**: 
![image](https://github.com/user-attachments/assets/b0856a67-99d2-45da-9b7c-a4215bbc5af8)


### Query 7: Aircraft and Helicopter Usage per Fuel Stock

**Description**: Shows aircraft and helicopter usage for fuel stocks restocked in the last 30 days (from May 25, 2025), displaying location, restock date, total aircraft, plane count, and helicopter count. Uses GROUP BY and ORDER BY. Aids fuel allocation in the GUI.


-   **Query**:
	```sql
	SELECT  fs.Location AS FuelStockLocation, fs.RestockDate, COUNT(DISTINCT a.AircraftId) AS TotalAircraft, COUNT(DISTINCT  CASE  WHEN p.AircraftId IS  NOT  NULL  THEN p.AircraftId END) AS PlaneCount, COUNT(DISTINCT  CASE  WHEN h.AircraftId IS  NOT  NULL  THEN h.AircraftId END) AS HelicopterCount FROM FuelStock fs LEFT  JOIN Aircraft a ON fs.StockId = a.StockId LEFT  JOIN Plane p ON a.AircraftId = p.AircraftId LEFT  JOIN Hellicopter h ON a.AircraftId = h.AircraftId WHERE fs.RestockDate >=  CURRENT_DATE  -  INTERVAL  '30 days'  GROUP  BY fs.Location, fs.RestockDate ORDER  BY TotalAircraft DESC, RestockDate ASC;


-   **Execution + Result Screenshot**:
![image](https://github.com/user-attachments/assets/b37feb91-3d45-4085-af68-089bb3ad961e)


### Query 8: Monthly Inspection and Training Schedule with Readiness Status

**Description**: Provides readiness status for aircraft in 2025, showing aircraft ID, model name, pilot name, inspection status, training status, and readiness summary ("Ready" or "Not Ready"). Uses date calculations for operational planning in the GUI.

-   **Query**:
	```sql
	SELECT  a.AircraftId, a.ModelName, p.FullName AS PilotName, CASE  WHEN a.NextInspectionDate <  CURRENT_DATE  THEN  'inspection is overdue'  ELSE  'next inspection in '  ||  CAST(EXTRACT(DAY  FROM AGE(a.NextInspectionDate, CURRENT_DATE)) AS TEXT) ||  ' days'  END  AS InspectionStatus, CASE  WHEN p.NextTrainingDate <  CURRENT_DATE  THEN  'training is overdue'  ELSE  'next training in '  ||  CAST(EXTRACT(DAY  FROM AGE(p.NextTrainingDate, CURRENT_DATE)) AS TEXT) ||  ' days'  END  AS TrainingStatus, CASE  WHEN a.NextInspectionDate <  CURRENT_DATE  OR (p.NextTrainingDate <  CURRENT_DATE  AND p.AircraftId IS  NOT  NULL) THEN  'Not Ready'  ELSE  'Ready'  END  AS ReadinessSummary FROM Aircraft a LEFT  JOIN Pilot p ON a.AircraftId = p.AircraftId WHERE  EXTRACT(YEAR  FROM a.NextInspectionDate) =  2025  ORDER  BY a.AircraftId;


-   **Execution + Result Screenshot**: 
![image](https://github.com/user-attachments/assets/504d2b13-239f-4720-8e64-79101473286f)


## DELETE Queries
📜 **[View `Queries.sql`](Phase2\Queries.sql)**  
### DELETE Query 1: Remove Aircraft with Overdue Inspections

**Description**: Removes aircraft with inspections overdue by more than 120 days (before May 25, 2025), excluding those assigned to pilots. Uses ON DELETE CASCADE to remove associated records in Equipped_With, Hellicopter, and Plane tables.
**Note:** This query uses constrains that ensure CASCADE of relevant information when an aircraft is deleted. see [CONSTRAINTS](#constraints) 4-6 for further explanation.

-   **Query**:
	```sql
 	ELETE  FROM Aircraft WHERE NextInspectionDate <  CURRENT_DATE  -  INTERVAL  '120 days'  AND AircraftId NOT  IN (SELECT AircraftId FROM Pilot WHERE AircraftId IS  NOT  NULL);

-   **Constraints Screenshot**:
![image](https://github.com/user-attachments/assets/d701db06-c268-419b-9564-38519c4733d2)

-   **Execution + Result Screenshot**:
![image](https://github.com/user-attachments/assets/6b36dbbb-9a00-47c0-8aa4-47564c2a3f0a)

-   **Before State**: Aircraft had 800 rows, Helicopter and Plane had 400 each.
-   **After State**: Aircraft (783 rows), Plane (385 rows), Helicopter (398 rows)
![image](https://github.com/user-attachments/assets/686c9728-0ec2-4dfa-a857-365c9a3279e3)


### DELETE Query 2: Remove Nearly Empty Fuel Stocks Not Used by Aircraft

**Description**: Removes fuel stocks with less than 2,000,000 liters and not assigned to any aircraft, using a subquery to identify unused stocks.

-   **Query**:
	```sql
	DELETE  FROM FuelStock WHERE StockLevel <  2000000  AND StockId NOT  IN (SELECT StockId FROM Aircraft WHERE StockId IS  NOT  NULL);

-   **Execution + Result Screenshot**: 
![image](https://github.com/user-attachments/assets/ba912782-ffb0-479e-bd7b-b64014670fb2)

-   **Before State**: FuelStock had 400 rows.
-   **After State**: 7 rows deleted 
![image](https://github.com/user-attachments/assets/76347394-0f19-49d4-9d71-da6edff83871)


### DELETE Query 3: Remove Large Equipment Not Assigned to Any Aircraft

**Description**: Removes equipment weighing over 700 not assigned to any aircraft, using a subquery to identify unassigned equipment.

-   **Query**:
	```sql
 	DELETE  FROM Equipment WHERE EquipmentId NOT  IN (SELECT EquipmentId FROM Equipped_With) AND Weight >  700;

-   **Execution + Result Screenshot**: 
![image](https://github.com/user-attachments/assets/edf883e7-915b-4072-a644-69a2af9ea9e6)

-   **Before State**: Equipment had 400 rows.
-   **After State**: 21 rows deleted
![image](https://github.com/user-attachments/assets/fbb725fe-38a1-472b-9856-24fd8067f210)


## UPDATE Queries
📜 **[View `Queries.sql`](Phase2\Queries.sql)**  
### UPDATE Query 1: Increase Fuel Stock Levels for Overdue Restocks Below 30%

**Description**: Increases stock levels by 75% of max capacity for fuel stocks overdue for restocking (before May 25, 2025) and below 30% capacity, using LEAST to cap at MaxCapacity.

-   **Query**:
	```sql
	UPDATE FuelStock SET StockLevel = LEAST(StockLevel + (MaxCapacity *  0.75), MaxCapacity) WHERE RestockDate <  CURRENT_DATE  AND (StockLevel / MaxCapacity) *  100  <  30;

-   **Execution Screenshot**:
![image](https://github.com/user-attachments/assets/103cbd16-2acf-42b2-b33b-7738e2fef4f6)

-   **Before State**: 
![image](https://github.com/user-attachments/assets/67868f87-5d74-4c01-bfb6-9e74f5e7c5b2)

-   **After State**: Query now returns empty as all stocks updated 
![image](https://github.com/user-attachments/assets/a6cae2a3-0bc7-41ff-bde5-9dcef42c2c68)


### UPDATE Query 2: Update Pilot Ranks for Those with Overdue Training

**Description**: Appends "(Prob.)" to ranks of pilots with training overdue by more than 120 days (before May 25, 2025).


-   **Query**:
	```sql
	UPDATE Pilot SET Rank = CONCAT(Rank, ' (Prob.)') WHERE NextTrainingDate +  120  <  CURRENT_DATE;

-   **Execution Screenshot**: 
![image](https://github.com/user-attachments/assets/bd894050-5357-410d-84a2-e0892b0abb8a)

-   **Before State**:
![image](https://github.com/user-attachments/assets/61a72c4e-b77e-4978-9f4b-d511603c5a7f)

-   **After State**: 
![image](https://github.com/user-attachments/assets/e7dd6016-ef16-4197-ba8d-25fc85b22b5a)


### UPDATE Query 3: Adjust Inspection Dates

**Description**: Reschedules overdue aircraft inspections (before May 25, 2025) to the same day of the week in the upcoming week.


-   **Query**:
	```sql
	UPDATE Aircraft SET NextInspectionDate = NextInspectionDate +  INTERVAL  '7 days'  *  CEIL((CAST (CURRENT_DATE  - NextInspectionDate as  float)) /  7) WHERE NextInspectionDate <  CURRENT_DATE;

-   **Execution Screenshot**: 
![image](https://github.com/user-attachments/assets/6eb67572-44c5-413f-bcb3-564b351ef369)

-   **Before State**:
![image](https://github.com/user-attachments/assets/786b5159-37b3-4688-a712-30e3ac858184)

-   **After State**: Dates pushed forward by one week from May 19, 2025 
![image](https://github.com/user-attachments/assets/a86ff04b-14a8-4a9e-9d9c-1251674b375f)


## Constraints
📜 **[View `Constraints.sql`](Phase2\Constraints.sql)**
**Run Screenshot:**
![image](https://github.com/user-attachments/assets/524614af-e09d-458d-b8ef-7360db178eda)

### Constraint 1: CHECK on Squadron.BaseLocation

**Description**: Ensures BaseLocation in Squadron has at least 5 characters.

-   **Query**:
	```sql
	ALTER  TABLE Squadron ADD  CONSTRAINT check_baselocation_length CHECK (LENGTH(BaseLocation) >=  5);

-   **Violation Test**: Attempted to insert BaseLocation = 'Base'.
-   **Error Screenshot**: 
![image](https://github.com/user-attachments/assets/a306d1c7-b371-4b79-9241-66a2240c64f6)


### Constraint 2: CHECK on Equipment.Weight

**Description**: Ensures Weight in Equipment is positive and not null.

-   **Query**:
	```sql
	ALTER  TABLE Equipment ALTER  COLUMN Weight SET  NOT  NULL, ADD  CONSTRAINT check_weight_positive CHECK (Weight >  0);

-   **Violation Test**: Attempted to insert Weight = 0.
-   **Error Screenshot**: 
![image](https://github.com/user-attachments/assets/c458f638-f3ad-4fad-bd02-80a921de4c4d)


### Constraint 3: DEFAULT on Pilot.Rank

**Description**: Sets default rank of 'Lieutenant' for Pilot.Rank.


-   **Query**:
	```sql
	ALTER  TABLE Pilot ALTER  COLUMN Rank SET  DEFAULT  'Lieutenant';

-   **Default Test**: Inserted a row without specifying Rank.
-   **Result Screenshot**: 
![image](https://github.com/user-attachments/assets/446b935a-4d89-4782-953c-118f1712be3e)


### Constraint 4: ON DELETE CASCADE on Equipped_With

**Description**: Deletes equipment assignments in Equipped_With when an aircraft is deleted from Aircraft. Tested as part of [DELETE Query 1](#delete-query-1-remove-aircraft-with-overdue-inspections).


-   **Query**:
	```sql
	ALTER  TABLE Equipped_With DROP  CONSTRAINT IF EXISTS equipped_with_aircraftid_fkey, ADD  CONSTRAINT equipped_with_aircraftid_fkey FOREIGN KEY (AircraftId) REFERENCES Aircraft (AircraftId) ON  DELETE CASCADE;

### Constraint 5: ON DELETE CASCADE on Hellicopter.AircraftId

**Description**: Deletes corresponding records in Hellicopter when an aircraft is deleted from Aircraft. Tested as part of [DELETE Query 1](#delete-query-1-remove-aircraft-with-overdue-inspections).

-   **Query**:
	```sql
	ALTER  TABLE Hellicopter DROP  CONSTRAINT IF EXISTS hellicopter_aircraftid_fkey, ADD  CONSTRAINT hellicopter_aircraftid_fkey FOREIGN KEY (AircraftId) REFERENCES Aircraft (AircraftId) ON  DELETE CASCADE;

### Constraint 6: ON DELETE CASCADE on Plane.AircraftId

**Description**: Deletes corresponding records in Plane when an aircraft is deleted from Aircraft. Tested as part of [DELETE Query 1](#delete-query-1-remove-aircraft-with-overdue-inspections).


-   **Query**:
	```sql
	ALTER  TABLE Plane DROP  CONSTRAINT IF EXISTS plane_aircraftid_fkey, ADD  CONSTRAINT plane_aircraftid_fkey FOREIGN KEY (AircraftId) REFERENCES Aircraft (AircraftId) ON  DELETE CASCADE;


## Rollback and Commit
📜 **[View `RollbackCommit.sql`](Phase2\RollbackCommit.sql)**  

### Part 1: Rollback Demonstration

**Description**: Updates fuel stock levels and reverts changes using ROLLBACK.

-   **Initial State**:
    

    
    `SELECT StockId, Location, StockLevel FROM FuelStock WHERE StockId BETWEEN  1  AND  5  ORDER  BY StockId;`
    
    -   **Screenshot**:
    ![image](https://github.com/user-attachments/assets/484095e9-9bb5-4673-87b9-8027c2c91c41)

-   **Update**: Decreases StockLevel by 500,000 for StockId 1-5.
    
 
    
    `UPDATE FuelStock SET StockLevel = GREATEST(StockLevel -  500000, 0) WHERE StockId BETWEEN  1  AND  5;`
    
    -   **State After Update**:
    ![image](https://github.com/user-attachments/assets/bf664020-5a54-4710-ab76-049af2725cc0)

-   **Perform ROLLBACK**:
    
    
    `ROLLBACK;`
    
    -   **State After ROLLBACK**:
    ![image](https://github.com/user-attachments/assets/0fd9d3af-ca43-48d5-9e22-517817590d3e)



### Part 2: Commit Demonstration

**Description**: Updates aircraft inspection dates and saves changes using COMMIT.

-   **Initial State**:
    

    
    `SELECT AircraftId, ModelName, NextInspectionDate FROM Aircraft WHERE AircraftId BETWEEN  1  AND  5  ORDER  BY AircraftId;`
    
    -   **Screenshot**: 
    ![image](https://github.com/user-attachments/assets/c057fedd-607a-4aa9-b404-2a63e2ad8624)

-   **Update**: Pushes inspection dates forward by 10 days for AircraftId 1-5.
    

    
    `UPDATE Aircraft SET NextInspectionDate = NextInspectionDate +  INTERVAL  '10 days'  WHERE AircraftId BETWEEN  1  AND  5;`
    
    -   **State After Update**:
    ![image](https://github.com/user-attachments/assets/e9da15f2-34df-4424-a2d8-0ef6b5950a5a)

-   **Perform COMMIT**:

    
    `COMMIT;`
    
    -   **State After COMMIT**: 
    ![image](https://github.com/user-attachments/assets/10f9a156-4d2d-4915-8b18-adeab6cece6a)

# Phase 3: Database Integration and Views

In this phase, we integrated two databases—both under the title of Air Force management —into a unified schema. This involved reversing the backup for the other database to an ERD and creating a revised an unified schema, modifying existing tables, adding new entities, migrating data, creating views for each department's perspective, and writing meaningful queries on those views. Below is a detailed overview of the process, decisions, and outcomes.

## Integration Process and Decisions
**Second Database's backup and shcema:**
![image](https://github.com/user-attachments/assets/f20372e6-d37f-4090-a2f1-9520d25a5a32)
![image](https://github.com/user-attachments/assets/69d91647-bcd0-4565-873a-ece73dcf1861)
![image](https://github.com/user-attachments/assets/ca3d76b6-43c5-46d5-9338-7cc591c78991)
![image](https://github.com/user-attachments/assets/7bd398ca-17d6-493c-b4c5-74ff2310d3ff)
![image](https://github.com/user-attachments/assets/da982080-7e11-48f5-a3b7-a81cf694ccf3)
![image](https://github.com/user-attachments/assets/609c77b2-4090-40f8-9e49-4112ef64e180)
![image](https://github.com/user-attachments/assets/4ee8e9fd-a4aa-4e03-ac01-1bb788444122)
![image](https://github.com/user-attachments/assets/97fb162b-1ccb-40ac-ada4-60f27f1aed40)
**Foreign Keys:**
![image](https://github.com/user-attachments/assets/e6d6b495-3179-47da-adf6-fc63589efebc)


### Schema Modifications

To align our database with the revised integrated ERD, we made the following changes to the schema:

1.  **Modified Existing Tables**:
    -   **Aircraft Table**:
        -   Added BoardingCapacity (moved from Helicopter), productiondate, status, and MaxAltitude.
        -   Set default values for existing rows: BoardingCapacity = 1, productiondate = '2020-08-06', MaxAltitude = 30000, and status = 'Active'.
        -   Enforced NOT NULL constraints after populating the data.
    -   **Pilot Table**:
        -   Added license_num and experience (from coworker's pilot table).
        -   Set default values: license_num = 'UNKNOWN-' || PilotId, experience = 5.
        -   Enforced NOT NULL constraints after populating the data.
    -   **Helicopter and Plane Tables**:
        -   Moved BoardingCapacity from Helicopter to Aircraft and dropped the column from Helicopter.
2.  **Added New Entities**:
    -   Created four new tables from the coworker's database:
        -   hub: Stores hub information (hub_id, name, location, iata_code, capacity).
        -   hangar: Stores hangar information (hangar_id, location, name).
        -   operator: Stores operator information (operator_id, name, fleet_size, type, hub_id as a foreign key to hub).
        -   producer: Stores producer information (producer_id, pname, estdate, owner).
    -   Data for these tables was imported manually.
3.  **Added Foreign Keys for Relationships**:
    -   Since all relationships in the integrated ERD are 1:M, we did not create separate relationship tables. Instead, we added foreign keys to the appropriate tables:
        -   Added operator_id to Pilot (1:M relationship with operator).
        -   Added operator_id, producer_id, and hangar_id to Aircraft (1:M relationships with operator, producer, and hangar).
        -   Added hub_id as a foreign key in operator (1:M relationship with hub).
    -   Populated these foreign keys with randomized values between 1 and 400 (based on the coworker's ID range).
    -   Enforced foreign key constraints after populating the data.

### Diagrams

Below are the screenshots of the DSD and ERD diagrams created during this phase:

-   **DSD of the New Department**:
![image](https://github.com/user-attachments/assets/0bcb032c-87b5-4842-9cd1-fe1be0170146)

-   **ERD of the New Department**:
![image](https://github.com/user-attachments/assets/d7cc307f-1a40-4cfb-91b0-3c1d2e412b9e)

-   **Integrated ERD**: 
![image](https://github.com/user-attachments/assets/50f2e782-c81f-4b1e-a2dc-6dc8ba97c6e7)

-   **Integrated DSD**: 
![revised_DSD](https://github.com/user-attachments/assets/ad0038cc-dab8-4e01-b85b-8e059e0dece7)


### Data Migration

To migrate the coworker's data into our schema, we followed these steps:

1.  **Set Defaults for Missing Fields**:
    -   Added defaults to fields in Aircraft, Pilot, and Plane that were missing in the coworker's schema:
        -   Aircraft: NextInspectionDate (CURRENT_DATE + 60), FuelCapacity (5000), SquadronId (1), StockId (1), FuelTypeId (2).
        -   Pilot: NextTrainingDate (CURRENT_DATE + 60).
        -   Plane: prepTime (3).
2.  **Created Temporary Tables**:
    -   pilot_temp: To store coworker's pilot data.
    -   plane_temp: To store coworker's plane data.
    -   pilot_plane_temp: To store the M:N relationship between pilots and planes (later converted to 1:M).
3.  **Migrated Data with ID Shift**:
    -   Shifted IDs by adding 1000 to avoid conflicts (e.g., pilot_id + 1000, plane_id + 1000).
    -   Inserted coworker's pilot data into Pilot.
    -   Inserted coworker's plane data into Aircraft and Plane (splitting attributes like maxdistance into MaxRange).
    -   Converted the M:N pilot_plane relationship to 1:M by assigning each pilot the most recent aircraft (based on assignment_date) and updating the AircraftId in Pilot.
4.  **Cleaned Up**:
    -   Dropped the temporary defaults after migration.
    -   Dropped the temporary tables.

### SQL Implementation

The full schema modification and data migration process is documented in Integrate.sql.

## Views and Queries

We created two views to represent the perspectives of each department, ensuring they focus on their respective domains without mixing data unnecessarily.

### View 1: aircraft_pilot_status (Original Department Perspective)

-   **Description**: This view focuses on aircraft and their assigned pilots, including inspection and training schedules, which are critical for operational readiness in our Air Force context.
-   **SQL**:

	```sql
	CREATE  OR REPLACE VIEW public.aircraft_pilot_status AS  
	SELECT  a.aircraftid, a.modelname, a.nextinspectiondate, p.pilotid, p.fullname, p.rank, p.nexttrainingdate 
	FROM aircraft a LEFT  JOIN pilot p ON a.aircraftid = p.aircraftid;

-   **Sample Data**: Below is a screenshot of the first 10 rows retrieved using SELECT * FROM aircraft_pilot_status LIMIT 10;.

![image](https://github.com/user-attachments/assets/73243140-d3e3-4c8e-b90e-2038b71c9d9a)


### Query 1 for aircraft_pilot_status: Upcoming Inspections and Training

-   **Description**: Identifies aircraft and pilots with inspections or training due within 30 days, aiding in scheduling.
-   **SQL**:

	```sql
	`SELECT  *  FROM aircraft_pilot_status
	 WHERE nextinspectiondate <=  CURRENT_DATE  +  INTERVAL  '30 days'  
	 OR nexttrainingdate <=  CURRENT_DATE  +  INTERVAL  '30 days'  
	 LIMIT 10;

-   **Sample Output**:
    
 ![image](https://github.com/user-attachments/assets/25b890b9-56ab-4936-badd-f476d765cd7f)


### Query 2 for aircraft_pilot_status: Aircraft Count by Pilot Rank

-   **Description**: Counts aircraft by pilot rank to analyze assignment distribution.
-   **SQL**:

	```sql
	`SELECT  rank, COUNT(aircraftid) AS aircraft_count
	 FROM aircraft_pilot_status 
	 GROUP  BY rank ORDER  BY aircraft_count DESC;

-   **Sample Output**:
    
![image](https://github.com/user-attachments/assets/0ec32672-86c8-488c-93c7-ce4ea5de0e8b)

    

### View 2: plane_operator_details (Coworker’s Department Perspective)

-   **Description**: This view focuses on planes (a subset of aircraft), their operators, and hub locations, reflecting the coworker’s focus on operational logistics.
-   **SQL**:

	```sql
	CREATE  OR REPLACE VIEW public.plane_operator_details AS  
	SELECT  a.aircraftid AS aircraft_id, a.modelname AS model, a.boardingcapacity AS capacity, 
	pl.maxrange AS maxdistance, o.name AS operator_name, o.type AS operator_type, 
	h.name AS hub_name, h.location AS hub_location 
	FROM aircraft a JOIN plane pl ON a.aircraftid = pl.aircraftid 
	JOIN operator o ON a.operator_id = o.operator_id 
	JOIN hub h ON o.hub_id = h.hub_id;

-   **Sample Data**: Below is a screenshot of the first 10 rows retrieved using SELECT * FROM plane_operator_details LIMIT 10;.

![image](https://github.com/user-attachments/assets/71866e1f-3eec-4bc5-b806-d394b3ae6a60)


### Query 1 for plane_operator_details: High Capacity and Long Range Planes

-   **Description**: Identifies planes with capacity greater than 5 and max distance over 3000, useful for long-haul operations.
-   **SQL**:

	```sql
	SELECT  *  FROM plane_operator_details 
	WHERE capacity >  5  AND maxdistance >  3000  
	LIMIT 10;

-   **Sample Output**:
![image](https://github.com/user-attachments/assets/4754217a-f1f8-4335-83e4-5031ba7418e4)


### Query 2 for plane_operator_details: Average Max Distance by Operator Type

-   **Description**: Calculates the average max distance of planes by operator type to compare operational capabilities.
-   **SQL**:

	```sql
	SELECT  operator_type, AVG(maxdistance) AS avg_max_distance 
	FROM plane_operator_details 
	GROUP  BY operator_type 
	ORDER  BY avg_max_distance DESC;

-   **Sample Output**:
    
![image](https://github.com/user-attachments/assets/b64b8d10-060f-4d48-b7c0-004856898f0d)

---
