import jwt, time, requests, json, os, hashlib

KEY_ID = "WDXGY9WX55"
ISSUER_ID = "2be0734f-943a-4d61-9dc9-5d9045c46fec"
KEY_PATH = "C:/Users/Windows/Downloads/AuthKey_WDXGY9WX55.p8"
BASE = "https://api.appstoreconnect.apple.com/v1"
LOC_ID = "9ca512f0-3ad6-431f-a613-82819f8b1186"  # ja locale

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

# 1. Create screenshot set for APP_IPHONE_67
print("=== Create Screenshot Set (6.7 inch) ===")
r = api("POST", "/appScreenshotSets", json={"data": {
    "type": "appScreenshotSets",
    "attributes": {"screenshotDisplayType": "APP_IPHONE_67"},
    "relationships": {
        "appStoreVersionLocalization": {
            "data": {"type": "appStoreVersionLocalizations", "id": LOC_ID}
        }
    }
}})
set_id = r.json()["data"]["id"]
print(f"  Set ID: {set_id}")

# 2. Upload each screenshot
screenshots_dir = "C:/Users/Windows/CleaningKokoroe/screenshots"
files = sorted([f for f in os.listdir(screenshots_dir) if f.startswith("hq_") and f.endswith(".png")])

for i, fname in enumerate(files):
    filepath = os.path.join(screenshots_dir, fname)
    filesize = os.path.getsize(filepath)

    with open(filepath, "rb") as f:
        data = f.read()
    checksum = hashlib.md5(data).hexdigest()

    print(f"\n=== Upload {fname} ({filesize} bytes) ===")

    # Reserve screenshot
    r = api("POST", "/appScreenshots", json={"data": {
        "type": "appScreenshots",
        "attributes": {
            "fileName": fname,
            "fileSize": filesize
        },
        "relationships": {
            "appScreenshotSet": {
                "data": {"type": "appScreenshotSets", "id": set_id}
            }
        }
    }})

    if r.status_code != 201:
        print(f"  Failed to reserve {fname}")
        continue

    ss_data = r.json()["data"]
    ss_id = ss_data["id"]
    upload_ops = ss_data["attributes"]["uploadOperations"]
    print(f"  Screenshot ID: {ss_id}, upload ops: {len(upload_ops)}")

    # Upload parts
    for op in upload_ops:
        url = op["url"]
        offset = op["offset"]
        length = op["length"]
        req_headers = {h["name"]: h["value"] for h in op["requestHeaders"]}
        chunk = data[offset:offset + length]
        print(f"  Uploading chunk offset={offset} length={length}")
        r = requests.put(url, headers=req_headers, data=chunk)
        print(f"    PUT -> {r.status_code}")

    # Commit
    print(f"  Committing {fname}...")
    r = api("PATCH", f"/appScreenshots/{ss_id}", json={"data": {
        "type": "appScreenshots",
        "id": ss_id,
        "attributes": {
            "uploaded": True,
            "sourceFileChecksum": checksum
        }
    }})

print("\n=== All screenshots uploaded! ===")
