# FreightDW Local - Data Architect Portfolio

A comprehensive SQL Server data warehouse project demonstrating enterprise-grade dimensional modeling and data architecture patterns for the freight/logistics domain.

## Project Goals

Build a production-ready data warehouse that showcases:
- ✅ Star schema design
- ✅ Slowly Changing Dimensions (SCD Type 1 & 2)
- ✅ Role-playing dimensions
- ✅ Fact table architecture with proper grain
- 🔄 Performance optimization & indexing (in progress)
- 🔄 Analytics queries & business insights (planned)

## Modules

### Module 1: Database & Date Dimension
**File:** `01_create_database.sql`

Creates the FreightDW database and builds Dim_Date:
- 1,461 days spanning 2022-2025
- Columns: DateKey, FullDate, DayOfWeek, DayName, Month, MonthName, Quarter, Year, IsWeekend
- Verification queries showing weekend distribution and day counts

**Why this matters:** Every warehouse needs a conformed date dimension for time-based analysis.

---

### Module 2: Dimension Tables
**File:** `02_dimensions.sql`

Creates 4 core business dimensions:

#### Dim_Customer (SCD Type 2)
- **Why Type 2?** Tracks historical changes (e.g., credit rating downgrades)
- Columns: CustomerSK (surrogate), CustomerBK (business key), CustomerName, CustomerType, Country, City, CreditRating, IsActive
- Includes EffectiveStartDate, EffectiveEndDate, IsCurrent for historical tracking
- Sample: 5 customers (Acme Logistics, Pacific Trade Co, Global Freight Ltd, Dragon Imports, Euro Cargo GmbH)

#### Dim_Carrier (SCD Type 1)
- **Why Type 1?** Carrier details rarely change; current state is sufficient
- Columns: CarrierSK, CarrierBK, CarrierName, CarrierType (Sea/Air/Road/Rail), Country, SCACCode (nullable for non-sea)
- Sample: 6 carriers (MSC, Maersk, CMA CGM, Qantas, Emirates, Toll)

#### Dim_Port (Role-Playing Dimension)
- **Why role-playing?** One table used twice in Fact_Shipment (OriginPortSK & DestPortSK)
- Columns: PortSK, PortBK (UN/LOCODE), PortName, PortType (Sea/Air/Inland), Country, Region
- Sample: 8 ports across Asia Pacific, Europe, and Middle East

#### Dim_Commodity (SCD Type 0)
- **Why Type 0?** Commodity definitions are static; no history tracking needed
- Columns: CommoditySK, CommodityBK, CommodityName, HSCode (nullable), Category, IsDangerous, RequiresRefrig
- Sample: 6 commodities (Electronics, Apparel, Machinery, Food, Chemicals, Pharmaceuticals)

**Design decisions:**
- Surrogate keys (SK) for internal use and stability
- Business keys (BK) for traceability to source systems
- BIT data types for flags (IsDangerous, RequiresRefrig) instead of VARCHAR for performance

---

### Module 3: Fact Table - Shipments
**File:** `03_fact_shipment.sql`

The central fact table connecting all dimensions:

#### Grain
**One row = one complete shipment** from origin to destination (end-to-end)

#### Columns
- **Surrogate Key:** ShipmentSK (IDENTITY)
- **Business Keys:** ShipmentID, LoadNumber (composite unique constraint)
- **Foreign Keys:** CustomerSK, OriginPortSK, DestPortSK, CarrierSK, CommoditySK, BookingDateSK, DepartureDateSK, ArrivalDateSK
- **Measures:** ShipmentCost (DECIMAL 12,2), Revenue (DECIMAL 12,2), WeightKg (DECIMAL 10,2), VolumeCbm (DECIMAL 10,2), NumContainers (INT)
- **Derived:** DaysInTransit (SMALLINT, nullable for in-transit shipments)
- **Status:** ShipmentStatus (In Transit/Delivered/Delayed/Cancelled), IsOnTime (BIT)
- **Audit:** CreatedDate, LastUpdatedDate (DATETIME)

#### Key Design Decisions

**Data Types:**
- DECIMAL(12,2) for all financial/measurement data (cost, revenue, weight, volume)
- Why? Precision matters. FLOAT introduces rounding errors that compound in aggregations.

**Role-Playing Dimensions:**
- Dim_Date used 3 times: BookingDateSK, DepartureDateSK, ArrivalDateSK
- Dim_Port used 2 times: OriginPortSK, DestPortSK
- Avoids table duplication; standard star schema practice

**Nullable ArrivalDateSK:**
- In-transit shipments haven't arrived yet → NULL
- Once delivered, filled with actual arrival date

**Sample Data:** 10 realistic shipments showing:
- Mix of delivery status (7 delivered, 3 in-transit)
- Multiple carriers and routes
- Air freight (0 containers) vs sea freight (2-3 containers)
- On-time and delayed shipments

#### Verification Queries
- Total shipment count: 10
- Revenue by customer: Shows aggregation across customers
- Status breakdown: In-transit vs delivered with average days in transit

---

### Module 4: Performance & Indexing (IN PROGRESS)
**File:** `04_performance_indexing.sql` (coming next)

Will add:
- Clustered index on ShipmentSK (primary key optimization)
- Non-clustered indexes on foreign keys (faster joins)
- Query execution plans (before/after)
- Real-world analytics queries

---

## Architecture: Star Schema

```
                    Dim_Date
                  (1,461 rows)
                       |
        Dim_Customer -- Fact_Shipment -- Dim_Port
        (5 rows)     (10 rows)        (8 rows)
                       |
                  Dim_Carrier
                  (6 rows)
                       |
                  Dim_Commodity
                  (6 rows)
```

**Why this pattern?**
- Denormalized fact table for query performance
- Normalized dimensions for data consistency
- Foreign key relationships ensure referential integrity
- Allows BI tools to auto-generate queries via drag-and-drop

---

## Key Concepts Demonstrated

### 1. Surrogate vs Natural Keys
- **Surrogate (SK):** System-generated, meaningless numbers (e.g., ShipmentSK=1,2,3...)
  - Used for: PKs, FKs, internal references
  - Benefit: Never changes, small, fast
  
- **Natural (BK):** Business-meaningful identifiers (e.g., ShipmentID='SHIP0001')
  - Used for: Traceability, source system reconciliation
  - Kept alongside surrogate for auditability

### 2. Slowly Changing Dimensions (SCD)
- **Type 1 (Overwrite):** Dim_Carrier — lose history, update in place
- **Type 2 (Keep History):** Dim_Customer — add new row, preserve old row with end date
- **Type 0 (Never Change):** Dim_Commodity — static reference data

### 3. Role-Playing Dimensions
- One dimension table used multiple times with different foreign keys
- Example: Dim_Date for booking, departure, arrival dates
- Saves storage and ensures consistency

### 4. Fact Table Grain
- **Atomic level:** One row per shipment (not per day, not per port)
- Enables flexible aggregation (sum revenue by carrier, avg days by route, etc.)
- Critical for correct analytics

---

## Data Quality & Validation

- Foreign key constraints prevent orphaned records
- Unique constraint on (ShipmentID, LoadNumber) prevents duplicates
- Default values and NOT NULL ensure data consistency
- Audit columns (CreatedDate, LastUpdatedDate) enable change tracking

---

## Portfolio Highlights

✅ **Enterprise Design Patterns:** Star schema, SCD strategies, role-playing dimensions  
✅ **Production Thinking:** Surrogate keys, data types, constraints, audit trails  
✅ **Business Context:** Real freight/logistics domain (aligned with Sydney tech market)  
✅ **Documentation:** Why decisions matter, not just that they work  
✅ **Scalability:** Patterns hold for 100M rows, not just 10

---

## Next Steps (Module 4+)

- Add indexes for query performance
- Build analytics queries (KPIs, trends, anomalies)
- Document execution plans and optimization reasoning
- Consider: aggregation tables, materialized views, partitioning strategies

---

## How to Use This Project

1. Execute `01_create_database.sql` first (creates database and Dim_Date)
2. Execute `02_dimensions.sql` (creates all dimension tables)
3. Execute `03_fact_shipment.sql` (creates Fact_Shipment and loads sample data)
4. Run verification queries to confirm data integrity
5. Use as foundation for analytics and optimization modules

---

**Built by:** Brian Santoso  
**Date:** July 2026  
**Purpose:** Data Architect Portfolio — Sydney Market
