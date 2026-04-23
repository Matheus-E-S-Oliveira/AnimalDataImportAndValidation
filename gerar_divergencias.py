import json
import random
from datetime import datetime

import json
import random
from datetime import datetime

def gerar_divergencias(input_path, output_path):
    with open(input_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    alterados_data = 0
    alterados_sexo = 0

    for item in data:

        # 🔴 1. Alterar DataNascimento (20% pra garantir teste)
        if random.random() < 0.2 and item.get("DataNascimento"):
            try:
                dt = datetime.fromisoformat(item["DataNascimento"])
                nova_data = dt.replace(year=dt.year + 2)

                item["DataNascimento"] = nova_data.strftime("%Y-%m-%dT%H:%M:%S")
                alterados_data += 1

            except Exception as e:
                print("Erro na data:", item["DataNascimento"])

        # 🔴 2. Alterar Sexo (10%)
        if random.random() < 0.1 and item.get("Sexo"):
            item["Sexo"] = "M" if item["Sexo"] == "F" else "F"
            alterados_sexo += 1

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✔ Datas alteradas: {alterados_data}")
    print(f"✔ Sexos alterados: {alterados_sexo}")
    print("Arquivo com divergências gerado com sucesso!")
    
# USO
gerar_divergencias(
    "C:/Users/marhe/OneDrive/Área de Trabalho/Tickets/Repository_Rerum/Ticket_16/ACNB-01-04-2026-11-06-43_-_inscrições__Expozebu_2026 - Copia.json",
    "C:/Users/marhe/OneDrive/Área de Trabalho/Tickets/Repository_Rerum/Ticket_16/ACNB-01-04-2026-11-06-43_-_inscrições__Expozebu_2026 - Divergente.json"
)