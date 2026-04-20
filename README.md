# 🐄 Animal Data Import and Validation Pipeline

Pipeline for importing and validating animal data from JSON using Python and SQL Server.

---

## 🎯 Overview

This project implements a complete data ingestion pipeline for animal records, handling:

- JSON data extraction
- Recursive parsing of hierarchical data (father/mother)
- Data cleaning and normalization
- Staging table loading
- Controlled insertion into the main database
- Detection of data inconsistencies (divergences)

---

## 🧰 Technologies

- Python
- Pandas
- SQLAlchemy
- SQL Server
- PyODBC

---

## 🔄 Execution Flow

1. Read JSON file  
2. Recursively extract animals and their lineage  
3. Convert data into DataFrame  
4. Clean and normalize data  
5. Load into staging table (`Animal_Importacao`)  
6. Execute SQL procedure  
7. Return and display data divergences  

---

## 🧩 Code Structure

### 📥 `read_file(path)`
Reads the JSON file and returns structured data.

---

### 🔁 `extract_animals(animal, extracted_animals, visited)`
Recursively extracts animal data, including parent hierarchy.

- Prevents duplication using a visited set
- Traverses father (`Pai`) and mother (`Mae`)

---

### 🆔 `get_identifier(animal)`
Returns the unique identifier:

- Uses `RGD` if available  
- Otherwise uses `RGN`

---

### 🔄 `process_data(data)`
Processes all animals and converts them into a Pandas DataFrame.

---

### 🧹 `clean_data(df)`
Performs data cleaning and validation:

- Creates `identificador` (RGD or RGN)
- Removes invalid records
- Converts dates
- Filters invalid dates
- Normalizes names (uppercase + trim)
- Removes duplicates

---

### 🔌 `database_connection()`
Creates a connection to SQL Server using SQLAlchemy.

---

### 🚀 `main()`

Main execution pipeline:

- Load JSON file
- Process and clean data
- Prepare fields for database
- Truncate staging table
- Insert data using bulk operation
- Execute stored procedure
- Print divergences (if any)

---

## 🗄️ Database Integration

### 📌 Staging Table
- `Animal_Importacao`

### 📌 Final Table
- `Animal`

### ⚙️ Stored Procedure
- `sp_Processar_Importacao_Animais`

**Responsibilities:**
- Insert new animals
- Prevent duplicates
- Detect divergences between staging and database

---

## 📏 Business Rules

- Unique animal identification:
  - `RGD` or `RGN` + `nome`

- Records without identifier are discarded  
- Invalid dates are ignored  
- Duplicate records are removed  

---

## ▶️ How to Run

```bash
python AnimalDataImportAndValidation.py
```

---

## 📊 Output

* Data inserted into staging table
* Procedure execution results
* Divergences printed in console

---

## ⚠️ Notes

* The `identificador` field is used only in staging
* Core validation logic is handled in SQL Server
* The process is idempotent (safe to run multiple times)

---

## 🔥 Summary

This project implements a full ETL pipeline:

* **Extract** → JSON parsing
* **Transform** → Data cleaning and normalization
* **Load** → SQL Server staging + final tables
* **Validate** → Stored procedures for consistency and integrity

---

## 👨‍💻 Author

Matheus Eric Santos de Oliveira
