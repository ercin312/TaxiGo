#!/usr/bin/env python3
"""Enable Apple Sign In on TaxiGo bundle + recreate App Store profile."""

from __future__ import annotations

import base64
import sys
import time
from pathlib import Path

import jwt
import requests

OUT = Path(r"C:\Users\excalibur\AppData\Local\Temp\asc-min-taxigo")
DEST = Path(r"C:\Users\excalibur\AppData\Local\Temp\ios-secrets-taxigo")
DEST.mkdir(parents=True, exist_ok=True)

BUNDLE_ID = "com.erhancinar.taxigo"
PROFILE_NAME = "TaxiGo App Store"
KEY_ID = (OUT / "key_id.txt").read_text(encoding="utf-8").strip()
ISSUER = (OUT / "issuer.txt").read_text(encoding="utf-8").strip()
KEY_RAW = (OUT / "key_content.txt").read_text(encoding="utf-8").strip()
TEAM = (OUT / "team.txt").read_text(encoding="utf-8").strip()


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


def api(method: str, path: str, **kwargs):
    r = requests.request(
        method,
        f"https://api.appstoreconnect.apple.com{path}",
        headers={"Authorization": f"Bearer {token()}", "Content-Type": "application/json"},
        timeout=90,
        **kwargs,
    )
    if r.status_code >= 400:
        print(r.status_code, r.text[:1500], file=sys.stderr)
        r.raise_for_status()
    if not r.content:
        return None
    return r.json()


def main() -> None:
    bundles = api("GET", f"/v1/bundleIds?filter[identifier]={BUNDLE_ID}")["data"]
    bundle_id = bundles[0]["id"]
    print("bundle", bundle_id)

    try:
        api(
            "POST",
            "/v1/bundleIdCapabilities",
            json={
                "data": {
                    "type": "bundleIdCapabilities",
                    "attributes": {"capabilityType": "APPLE_ID_AUTH"},
                    "relationships": {
                        "bundleId": {"data": {"type": "bundleIds", "id": bundle_id}}
                    },
                }
            },
        )
        print("APPLE_ID_AUTH enabled")
    except Exception as e:
        print("APPLE_ID_AUTH:", e)

    # Delete existing TaxiGo profiles so we recreate with new caps
    profiles = api("GET", "/v1/profiles?filter[profileType]=IOS_APP_STORE&limit=200")["data"]
    for p in profiles:
        if "taxigo" in (p["attributes"].get("name") or "").lower():
            print("Deleting", p["attributes"]["name"], p["id"])
            api("DELETE", f"/v1/profiles/{p['id']}")

    certs = api("GET", "/v1/certificates?filter[certificateType]=DISTRIBUTION&limit=20")["data"]
    if not certs:
        certs = [
            c
            for c in api("GET", "/v1/certificates?limit=50")["data"]
            if "DISTRIBUTION" in (c["attributes"].get("certificateType") or "")
        ]
    cert_id = certs[0]["id"]
    print("cert", cert_id)

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
    name = detail["attributes"]["name"]
    raw = base64.b64decode(detail["attributes"]["profileContent"])
    (DEST / "taxigo.mobileprovision").write_bytes(raw)
    (DEST / "taxigo_profile_name.txt").write_text(name, encoding="utf-8")
    (DEST / "taxigo_profile_b64.txt").write_text(base64.b64encode(raw).decode(), encoding="utf-8")
    print("Wrote profile", name, len(raw), "team", TEAM)


if __name__ == "__main__":
    main()
