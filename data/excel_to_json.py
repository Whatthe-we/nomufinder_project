import pandas as pd
import json

# 엑셀 파일 읽기
df = pd.read_excel("lawyers_by_region_ver2.xlsx", dtype={"price": str})

# price 컬럼이 쉼표로 잘못 나뉘는 경우를 방지
def clean_price(value):
    if not isinstance(value, str):
        return []
    # 모든 숫자/원 조각을 정리하고 조합
    prices = value.replace(" ", "").replace("원", "").split(",")
    combined = []
    i = 0
    while i < len(prices):
        if i + 1 < len(prices) and prices[i + 1].isdigit():
            # ex: ["20", "000"] → "20,000원"
            combined.append(f"{prices[i]},{prices[i + 1]}원")
            i += 2
        else:
            combined.append(f"{prices[i]}원")
            i += 1
    return combined

# JSON 리스트 생성
json_data = []
for _, row in df.iterrows():
    json_data.append({
        "name": row["name"],
        "photo": row["photo"],
        "desc": row["desc"],
        "consult": [x.strip() for x in str(row["consult"]).split(",") if x.strip()],
        "price": clean_price(row["price"]),
        "specialty": [x.strip() for x in str(row["specialty"]).split(",") if x.strip()],
        "address": row["address"],
        "gender": row.get("gender", ""),
        "phone": row.get("phone", ""),
        "email": row.get("email", ""),
        "license_number": row.get("license_number", "")
    })

# JSON 저장
with open("lawyers_by_region_ver2.json", "w", encoding="utf-8") as f:
    json.dump(json_data, f, ensure_ascii=False, indent=2)