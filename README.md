# Air Force Resources Database

**Submitted by:** [Tzur Tamir 207876525]  
**System:** Air Force Resources Management  
**Unit:** Aircraft Operations  

## Table of Contents
- [Introduction](#introduction)
- [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)
- [DSD (Data Structure Diagram)](#dsd-data-structure-diagram)
- [SQL Scripts](#sql-scripts)
- [Data Insertion Methods](#data-insertion-methods)
- [Backup and Restore](#backup-and-restore)

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
![ERD Diagram](Phase1/ERD.png)  
[^add screenshot^]  
*The ERD visualizes entities and their relationships as designed in the project.*

## DSD (Data Structure Diagram)
![DSD Diagram](Phase1/DSD.png)  
[^add screenshot^]  
*The DSD outlines the relational schema derived from the ERD.*

## SQL Scripts
The following SQL scripts are provided in the repository:
- **Create Tables**: Defines all tables and triggers.  
  📜 **[View `createTables.sql`](Phase1/scripts/createTables.sql)**  
- **Insert Data**: Adds initial sample data.  
  📜 **[View `insertTables.sql`](Phase1/scripts/insertTables.sql)**  
- **Drop Tables**: Removes all tables in the correct order.  
  📜 **[View `dropTables.sql`](Phase1/scripts/dropTables.sql)**  
- **Select All**: Retrieves all data from each table.  
  📜 **[View `selectAll.sql`](Phase1/scripts/selectAll.sql)**  

## Data Insertion Methods
Data was added to the database using three distinct methods:

### 1. Python Script (Squadron, FuelStock)
- **Tool**: Custom Python script to generate SQL insert statements.
- **Details**: 
  - **Squadron**: 400 rows with unique `SquadronId`, names (e.g., "Hawk-504B-001"), and base locations from a list of 22 options.
  - **FuelStock**: 400 rows with `StockId`, locations (e.g., "Warehouse A-1"), stock levels (5000-20000 liters), and `FuelTypeId` linked to 20 fuel types.
- **File**:  
  📜 **[View `insert_squadron_fuel.sql`](Phase1/scripts/insert_squadron_fuel.sql)**  
- **Screenshot**:  
  [^add screenshot^] *Showing execution of the Python-generated SQL in pgAdmin.*

### 2. Mockaroo (Aircraft, Helicopter, Plane, Equipment)
- **Tool**: [Mockaroo](https://www.mockaroo.com/) for generating realistic mock data.
- **Details**: 
  - **Aircraft**: 800 rows (`AircraftId` 1-800) with model names, inspection dates, and fuel capacities.
  - **Helicopter**: Subset of Aircraft with boarding and payload capacities, and hover times.
  - **Plane**: Subset of Aircraft with prep times and max ranges.
  - **Equipment**: 400 rows (`EquipmentId` 1-400) with types (e.g., "Radar-001") and weights (100-1000 kg).
- **Files**: Generated as CSV, then converted to SQL or imported directly.
- **Screenshot**:  
  [^add screenshot^] *Showing Mockaroo interface with schema and sample data.*

### 3. CSV Files (Equipped_With, Pilot)
- **Tool**: Pre-generated CSV files imported via PostgreSQL `COPY` or pgAdmin.
- **Details**: 
  - **Equipped_With**: 500 rows linking `AircraftId` (1-800) to `EquipmentId` (1-400) with quantities (1-4).
  - **Pilot**: 500 rows (`PilotId` 1-500) with names (e.g., "James Smith"), training dates, ranks, and optional `AircraftId` (50% linked to 1-800).
- **Files**:  
  📜 **[View `pilot_data.csv`](Phase1/data/pilot_data.csv)**  
  📜 **[View `fuel_equip_data.csv`](Phase1/data/fuel_equip_data.csv)**  
- **Screenshot**:  
  [^add screenshot^] *Showing CSV import process in pgAdmin or psql output.*

## Relationships
Based on the attached Excel, here’s an explanation of the relationships in the ERD:

| Relationship Name | Description |
|-------------------|-------------|
| **Part_Of**       | A Squadron consists of many Aircraft (1:N). An Aircraft must belong to a Squadron, but a Squadron can exist without Aircraft initially (organizational grouping). |
| **Assigned_To**   | An Aircraft is assigned to one Pilot (1:1), optional on both sides as an Aircraft may lack a Pilot and vice versa. |
| **Equipped_With** | An Aircraft can have multiple Equipment types, and an Equipment type can serve multiple Aircraft (M:N), optional since not all Aircraft require special equipment. |
| **Fuels_From**    | An Aircraft refuels from one FuelStock, and one FuelStock can serve multiple Aircraft (1:N). Each Aircraft must have a FuelStock, but a FuelStock may not yet serve Aircraft. |
| **Uses**          | An Aircraft requires one FuelType (1:N), mandatory for Aircraft to have a type, optional for a FuelType to be used by Aircraft. |
| **Filled_With**   | A FuelStock contains one FuelType, and one FuelType can fill multiple FuelStocks (1:N). A FuelStock must have a FuelType, but a FuelType may not have associated FuelStocks. |

These relationships ensure flexibility and scalability in managing air force resources.

## Backup and Restore
- **Backup**: Data is backed up using `pg_dump` from the PostgreSQL container.
  - Command: `docker exec my_postgres pg_dump -U myuser mydatabase > backup_YYYYMMDD_HHMM.sql`
  - Files are stored with date and time stamps.  
  📁 **[View Backup Folder](Phase1/Backup)**  
  [^add screenshot^] *Showing backup command execution and resulting file.*
- **Restore**: Data is restored using `psql` to reload the backup.
  - Command: `docker exec -i my_postgres psql -U myuser -d mydatabase < backup_YYYYMMDD_HHMM.sql`
  [^add screenshot^] *Showing restore command execution and verification.*

---
