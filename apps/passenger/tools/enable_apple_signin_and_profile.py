#!/usr/bin/env python3
"""Enable Sign In with Apple (with required settings) and refresh TaxiGo profile."""

from __future__ import annotations

import base64
import sys
import time
from pathlib import Path

import jwt
import requests

# Prefer asc-min if present; else fail clearly
CANDIDATES = [
    Path(r"C:\Users\excalibur\AppData\Local\Temp\asc-min-taxigo"),
    Path(r"C:\Users\excalibur\AppData\Local\Temp\ios-secrets-taxigo"),
]
OUT = next((p for p in CANDIDATES if (p / "issuer.txt").exists()), None)
DEST = Path(r"C:\Users\excalibur\AppData\Local\Temp\ios-secrets-taxigo")
DEST.mkdir(parents=True, exist_ok=True)

BUNDLE_ID = "com.erhancinar.taxigo"
PROFILE_NAME = "TaxiGo App Store"


def load() -> tuple[str, str, str]:
    if OUT is None:
        sys.exit("ASC credentials folder missing")
    return (
        (OUT / "key_id.txt").read_text(encoding="utf-8").strip(),
        (OUT / "issuer.txt").read_text(encoding="utf-8").strip(),
        (OUT / "key_content.txt").read_text(encoding="utf-8").strip(),
    )


KEY_ID, ISSUER, KEY_RAW = load()


def pem() -> str:
    if "BEGIN PRIVATE KEY" in KEY_RAW:
        return KEY_RAW if KEY_RAW.endswith("\n") else KEY_RAW + "\n"
    return base64.b64decode(KEY_RAW).decode()


def token() -> str:
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER, "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
        pem(),
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


def api(method: str, path: str, ok_statuses: set[int] | None = None, **kwargs):
    r = requests.request(
        method,
        f"https://api.appstoreconnect.apple.com{path}",
        headers={"Authorization": f"Bearer {token()}", "Content-Type": "application/json"},
        timeout=90,
        **kwargs,
    )
    ok = ok_statuses or set()
    if r.status_code >= 400 and r.status_code not in ok:
        print(r.status_code, r.text[:2000], file=sys.stderr)
        r.raise_for_status()
    if not r.content:
        return None
    return r.json()


def main() -> None:
    bundle_id = api("GET", f"/v1/bundleIds?filter[identifier]={BUNDLE_ID}")["data"][0]["id"]
    print("bundle", bundle_id)

    # Enable Sign In with Apple with required consent setting
    body = {
        "data": {
            "type": "bundleIdCapabilities",
            "attributes": {
                "capabilityType": "APPLE_ID_AUTH",
                "settings": [
                    {
                        "key": "APPLE_ID_AUTH_APP_CONSENT",
                        "options": [{"key": "PRIMARY_APP_CONSENT"}],
                    }
                ],
            },
            "relationships": {
                "bundleId": {"data": {"type": "bundleIds", "id": bundle_id}}
            },
        }
    }
    resp = api("POST", "/v1/bundleIdCapabilities", json=body, ok_statuses={409})
    print("APPLE_ID_AUTH:", "ok" if resp else "already/conflict")

    # Recreate profile
    for p in api("GET", "/v1/profiles?filter[profileType]=IOS_APP_STORE&limit=200")["data"]:
        if "taxigo" in (p["attributes"].get("name") or "").lower():
            print("delete", p["id"], p["attributes"]["name"])
            api("DELETE", f"/v1/profiles/{p['id']}")

    certs = api("GET", "/v1/certificates?filter[certificateType]=DISTRIBUTION&limit=20")["data"]
    cert_id = certs[0]["id"]
    created = api(
        "POST",
        "/v1/profiles",
        json={
            "data": {
                "type": "profiles",
                "attributes": {"name": PROFILE_NAME, "profileType": "IOS_APP_STORE"},
                "relationships": {
                    "bundleId": {"data": {"type": "bundleIds", "id": bundle_id}},
                    "certificates": {"data": [{"type": "certificates", "id": cert_id}]},
                },
            }
        },
    )["data"]
    detail = api("GET", f"/v1/profiles/{created['id']}")["data"]
    raw = base64.b64decode(detail["attributes"]["profileContent"])
    name = detail["attributes"]["name"]
    (DEST / "taxigo_profile_name.txt").write_text(name, encoding="utf-8")
    (DEST / "taxigo_profile_b64.txt").write_text(base64.b64encode(raw).decode(), encoding="utf-8")
    (DEST / "taxigo.mobileprovision").write_bytes(raw)
    # Quick check entitlement in profile text
    text = raw.decode("latin1", errors="ignore")
    print("profile", name, "bytes", len(raw))
    print("has applesignin", "applesignin" in text)
    print("has aps-environment", "aps-environment" in text)


if __name__ == "__main__":
    main()
