import pandas as pd
from sqlalchemy import create_engine, text
from pathlib import Path
import json

def read_file(path: str):
    if str(path).endswith(".json"):
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)

    else:
        raise Exception("Formato de arquivo não suportado")
    
def extract_animals(animal, extracted_animals, visited):
    if not animal: return
    
    if visited is None: visited = set()
    
    identifier = get_identifier(animal)
    
    if not identifier:
        identifier = f"TEMP_{animal.get('Nome', 'SEM_NOME')}_{animal.get('DataNascimento', '')}"
    
    if identifier in visited: return

    visited.add(identifier)
    
    father = animal.get("Pai")
    mother = animal.get("Mae")
    
    current = {
        "RGN": animal.get("Rgn"),
        "RGD": animal.get("Rgd") or None,
        "nome": animal.get("Nome"),
        "sexo": animal.get("Sexo"),
        "dataNascimento": animal.get("DataNascimento"),
        "paiId": get_identifier(father),
        "maeId": get_identifier(mother),
    }
    
    extracted_animals.append(current)
    
    extract_animals(father, extracted_animals, visited)
    extract_animals(mother, extracted_animals, visited)

def get_identifier(animal):
    if not animal:
        return None
    
    return animal.get("Rgd") or animal.get("Rgn")

def process_data(data):
    extracted_animals = []
    visited = set()
        
    for animal in data:
        extract_animals(animal, extracted_animals, visited)
            
    df = pd.DataFrame(extracted_animals)
    return df

def clean_data(df):
    df["identificador"] = df["RGD"].fillna(df["RGN"])
    df = df[df["identificador"].notna()]
    
    df["dataNascimento"] = pd.to_datetime(df["dataNascimento"], errors="coerce")
    invalid_dates = df[df["dataNascimento"].isna()]

    if not invalid_dates.empty:
        print(f"[WARN] {len(invalid_dates)} animais com data inválida")

    df = df[df["dataNascimento"].notna()]
        
    df["nome"] = df["nome"].fillna("").str.strip().str.upper()
    df = df.drop_duplicates(subset=["identificador", "nome"])
    
    return df

def database_connection():
    engine = create_engine(
    "mssql+pyodbc://@PC-RERUM000210/AnimaisDB?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes&TrustServerCertificate=yes"
    )
    
    return engine
            
# ================== MAIN ==================
def main():
    file = Path("C:/Users/marhe/OneDrive/Área de Trabalho/Tickets/Repository_Rerum/Ticket_16/ACNB-01-04-2026-11-06-43_-_inscrições__Expozebu_2026.json")
    engine = database_connection()
    
    data = read_file(file)
    
    df = process_data(data)
    df = clean_data(df)
    
    df["RGD"] = df["RGD"].where(pd.notna(df["RGD"]), None)
    df["RGN"] = df["RGN"].where(pd.notna(df["RGN"]), None)
    df["identificador"] = df["identificador"].astype(str)
    df = df[df["identificador"] != "nan"]

    df["nome"] = df["nome"].fillna("").str.strip().str.upper()
    df["sexo"] = df["sexo"].fillna("").str.strip().str.upper()
    
    with engine.begin() as conn:
        conn.execute(text("TRUNCATE TABLE Animal_Importacao"))
        
        df.to_sql("Animal_Importacao", conn, if_exists="append", index=False, chunksize=100, method="multi")
        
        result = conn.execute(text("EXEC dbo.sp_Processar_Importacao_Animais"))
        
        if result.returns_rows:
            disagreements = result.fetchall()
    
            for d in disagreements:
                print(d)
    
if __name__ == "__main__":
    main()