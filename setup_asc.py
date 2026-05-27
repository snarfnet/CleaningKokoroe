import jwt, time, requests, json, base64

KEY_ID = "WDXGY9WX55"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = "C:/Users/Windows/Downloads/AuthKey_WDXGY9WX55.p8"
APP_ID = "6772942942"
BASE = "https://api.appstoreconnect.apple.com/v1"

with open(KEY_PATH) as f:
    key = f.read()

def get_token():
    return jwt.encode(
        {"iss": ISSUER_ID, "iat": int(time.time()), "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"},
        key, algorithm="ES256", headers={"kid": KEY_ID}
    )

def api(method, path, **kwargs):
    url = f"{BASE}{path}" if path.startswith("/") else path
    headers = {"Authorization": f"Bearer {get_token()}", "Content-Type": "application/json"}
    r = requests.request(method, url, headers=headers, **kwargs)
    print(f"  {method} {path} -> {r.status_code}")
    if r.status_code >= 400:
        print(f"    ERROR: {r.text[:500]}")
    return r

# Step 1: Get appInfos ID and appStoreVersion ID
print("=== Step 1: Get IDs ===")
r = api("GET", f"/apps/{APP_ID}/appInfos?limit=5")
info_id = r.json()["data"][0]["id"]
print(f"  appInfo ID: {info_id}")

r = api("GET", f"/apps/{APP_ID}/appStoreVersions?limit=5")
versions = r.json()["data"]
version_id = versions[0]["id"] if versions else None
print(f"  version ID: {version_id}")

# Step 2: Set primary category to LIFESTYLE
print("\n=== Step 2: Category (LIFESTYLE) ===")
api("PATCH", f"/appInfos/{info_id}", json={"data": {
    "type": "appInfos", "id": info_id,
    "relationships": {"primaryCategory": {"data": {"type": "appCategories", "id": "LIFESTYLE"}}}
}})

# Step 3: Content rights
print("\n=== Step 3: Content Rights ===")
api("PATCH", f"/apps/{APP_ID}", json={"data": {
    "type": "apps", "id": APP_ID,
    "attributes": {"contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"}
}})

# Step 4: Copyright
print("\n=== Step 4: Copyright ===")
if version_id:
    api("PATCH", f"/appStoreVersions/{version_id}", json={"data": {
        "type": "appStoreVersions", "id": version_id,
        "attributes": {"copyright": "2026 tokyonasu"}
    }})

# Step 5: Age Rating
print("\n=== Step 5: Age Rating ===")
r = api("GET", f"/appInfos/{info_id}/ageRatingDeclaration")
if r.status_code == 200:
    ard_id = r.json()["data"]["id"]
    print(f"  ageRating ID: {ard_id}")
    api("PATCH", f"/ageRatingDeclarations/{ard_id}", json={"data": {
        "type": "ageRatingDeclarations", "id": ard_id,
        "attributes": {
            "sexualContentGraphicAndNudity": "NONE",
            "gamblingSimulated": "NONE",
            "violenceRealisticProlongedGraphicOrSadistic": "NONE",
            "matureOrSuggestiveThemes": "NONE",
            "alcoholTobaccoOrDrugUseOrReferences": "NONE",
            "medicalOrTreatmentInformation": "NONE",
            "contests": "NONE",
            "violenceRealistic": "NONE",
            "gunsOrOtherWeapons": "NONE",
            "violenceCartoonOrFantasy": "NONE",
            "sexualContentOrNudity": "NONE",
            "horrorOrFearThemes": "NONE",
            "profanityOrCrudeHumor": "NONE",
            "lootBox": False,
            "unrestrictedWebAccess": False,
            "gambling": False,
            "ageAssurance": False,
            "messagingAndChat": False,
            "parentalControls": False,
            "advertising": True
        }
    }})

# Step 6: Privacy Policy URL
print("\n=== Step 6: Privacy Policy URL ===")
r = api("GET", f"/appInfos/{info_id}/appInfoLocalizations?limit=10")
for il in r.json().get("data", []):
    locale = il["attributes"]["locale"]
    print(f"  Setting privacy URL for locale: {locale}")
    api("PATCH", f"/appInfoLocalizations/{il['id']}", json={"data": {
        "type": "appInfoLocalizations", "id": il["id"],
        "attributes": {"privacyPolicyUrl": "https://snarfnet.github.io/"}
    }})

# Step 7: Version Localizations
print("\n=== Step 7: Version Localizations ===")
if version_id:
    r = api("GET", f"/appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=10")
    locs = r.json().get("data", [])

    ja_desc = (
        "掃除のプロが教える豆知識を10,000件収録。キッチン・浴室・トイレなど"
        "20カテゴリから、今すぐ使える掃除テクニックを見つけよう。\n\n"
        "毎日変わる風水掃除アドバイスで、掃除する場所と方角をチェック。"
        "ホウキ針タイマーで3分から30分の時短掃除もサポート。\n\n"
        "主な機能:\n"
        "- 10,000件の清掃豆知識（初級～上級）\n"
        "- 20カテゴリ検索（キッチン、浴室、トイレ、リビング等）\n"
        "- 日替わり風水掃除アドバイス\n"
        "- ホウキ針タイマー（3/5/10/15/30分）\n"
        "- ランダム表示で新しい発見"
    )

    en_desc = (
        "10,000 cleaning tips from the pros. Browse 20 categories "
        "- kitchen, bathroom, toilet, living room, and more - "
        "to find cleaning techniques you can use right now.\n\n"
        "Check today's feng shui cleaning advice for the best spot "
        "and direction to clean. Use the Broom Timer for quick "
        "3 to 30 minute cleaning sessions.\n\n"
        "Features:\n"
        "- 10,000 cleaning tips (beginner to advanced)\n"
        "- 20 category search (kitchen, bathroom, toilet, etc.)\n"
        "- Daily feng shui cleaning advice\n"
        "- Broom Timer (3/5/10/15/30 min)\n"
        "- Random display for new discoveries"
    )

    ja_kw = "掃除,清掃,豆知識,風水,タイマー,キッチン,浴室,トイレ,リビング,カビ,水垢,時短,家事,クリーニング,整理,片付け,生活,暮らし,掃除の心得"
    en_kw = "cleaning,tips,housekeeping,kitchen,bathroom,toilet,feng shui,timer,home,tidy,organize,hacks,chores,dust,mold"

    for loc in locs:
        locale = loc["attributes"]["locale"]
        print(f"  Setting localization for: {locale}")
        if "ja" in locale:
            attrs = {
                "description": ja_desc,
                "keywords": ja_kw,
                "supportUrl": "https://snarfnet.github.io/",
                "marketingUrl": "https://snarfnet.github.io/"
            }
        else:
            attrs = {
                "description": en_desc,
                "keywords": en_kw,
                "supportUrl": "https://snarfnet.github.io/",
                "marketingUrl": "https://snarfnet.github.io/"
            }
        api("PATCH", f"/appStoreVersionLocalizations/{loc['id']}", json={"data": {
            "type": "appStoreVersionLocalizations", "id": loc["id"],
            "attributes": attrs
        }})

# Step 8: Review Detail
print("\n=== Step 8: Review Detail ===")
if version_id:
    api("POST", "/appStoreReviewDetails", json={"data": {
        "type": "appStoreReviewDetails",
        "attributes": {
            "contactFirstName": "Tokyo",
            "contactLastName": "Nasu",
            "contactEmail": "snarfnet@gmail.com",
            "contactPhone": "+14155550000",
            "demoAccountRequired": False,
            "demoAccountName": "",
            "demoAccountPassword": "",
            "notes": "This app displays cleaning tips from a local JSON database. No network required for core functionality. AdMob banner ad is shown at the bottom."
        },
        "relationships": {
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
        }
    }})

# Step 9: Pricing (Free)
print("\n=== Step 9: Pricing (Free) ===")
pp_data = {"s": APP_ID, "t": "USA", "p": "10000"}
pp_id = base64.b64encode(json.dumps(pp_data, separators=(",", ":")).encode()).decode().rstrip("=")
api("POST", "/appPriceSchedules", json={
    "data": {
        "type": "appPriceSchedules",
        "relationships": {
            "app": {"data": {"type": "apps", "id": APP_ID}},
            "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
            "manualPrices": {"data": [{"type": "appPrices", "id": "${usa-free}"}]}
        }
    },
    "included": [{
        "type": "appPrices",
        "id": "${usa-free}",
        "attributes": {"startDate": None, "endDate": None},
        "relationships": {
            "territory": {"data": {"type": "territories", "id": "USA"}},
            "appPricePoint": {"data": {"type": "appPricePoints", "id": pp_id}}
        }
    }]
})

# Step 10: Check build and set usesNonExemptEncryption
print("\n=== Step 10: Build check ===")
r = api("GET", f"/apps/{APP_ID}/builds?limit=5&sort=-uploadedDate")
builds = r.json().get("data", [])
if builds:
    build = builds[0]
    build_id = build["id"]
    build_ver = build["attributes"].get("version", "?")
    print(f"  Latest build: {build_id} (v{build_ver})")
    enc = build["attributes"].get("usesNonExemptEncryption")
    if enc is None:
        print("  Setting usesNonExemptEncryption = false")
        api("PATCH", f"/builds/{build_id}", json={"data": {
            "type": "builds", "id": build_id,
            "attributes": {"usesNonExemptEncryption": False}
        }})
    else:
        print(f"  usesNonExemptEncryption already set: {enc}")
else:
    print("  No builds found yet! Run CI/CD first.")

print("\n=== All Done! ===")
