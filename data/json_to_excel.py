import json
import pandas as pd

# JSON 파일 로드
with open("lawyers_by_region.json", "r", encoding="utf-8") as f:
    data = json.load(f)

# 리스트 형태 항목들은 문자열로 변환
rows = []
for entry in data:
    rows.append({
        "name": entry.get("name", ""),
        "photo": entry.get("photo", ""),
        "desc": entry.get("desc", ""),
        "consult": ", ".join(entry.get("consult", [])),
        "price": ", ".join(entry.get("price", [])),
        "specialty": ", ".join(entry.get("specialty", [])),
        "address": entry.get("address", "")
    })

# DataFrame 생성 및 저장
df = pd.DataFrame(rows)
df.to_excel("lawyers_by_region.xlsx", index=False)