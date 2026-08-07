#!/usr/bin/env python3
"""Create/download App Store provisioning profile for TaxiGo via ASC API."""

from __future__ import annotations

import base64
import json
import sys
import time
from pathlib import Path

import jwt
import requests

OUT = Path(r"C:\Users\excalibur\AppData\Local\Temp\ios-secrets-taxigo")
BUNDLE_ID = "com.erhancinar.taxigo"
PROFILE_NAME = "TaxiGo App Store"
TEAM_ID = (OUT / "team.txt").read_text(encoding="utf-8").strip()
KEY_ID = (OUT / "key_id.txt").read_text(encoding="utf-8").strip()
ISSUER = (OUT / "issuer.txt").read_text(encoding="utf-8").strip()
KEY_RAW = (OUT / "key_content.txt").read_text(encoding="utf-8").strip()


def private_key_pem() -> str:
    if "BEGIN PRIVATE KEY" in KEY_RAW:
        return KEY_RAW if KEY_RAW.endswith("\n") else KEY_RAW + "\n"
    return base64.b64decode(KEY_RAW).decode("utf-8")


def token() -> str:
    now = int(time.time())
    payload = {
        "iss": ISSUER,
        "iat": now,
        "exp": now + 1100,
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(
        payload,
        private_key_pem(),
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


def api(method: str, path: str, **kwargs):
    url = f"https://api.appstoreconnect.apple.com{path}"
    headers = {"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}
    r = requests.request(method, url, headers=headers, timeout=60, **kwargs)
    if r.status_code >= 400:
        print(r.status_code, r.text[:2000], file=sys.stderr)
        r.raise_for_status()
    if r.status_code == 204 or not r.content:
        return None
    return r.json()


def main() -> None:
    print(f"Team={TEAM_ID} Key={KEY_ID} Bundle={BUNDLE_ID}")

    bundles = api("GET", f"/v1/bundleIds?filter[identifier]={BUNDLE_ID}&limit=10")
    items = bundles.get("data") or []
    if not items:
        print("Bundle ID not found — creating…")
        created = api(
            "POST",
            "/v1/bundleIds",
            json={
                "data": {
                    "type": "bundleIds",
                    "attributes": {
                        "identifier": BUNDLE_ID,
                        "name": "TaxiGo",
                        "platform": "IOS",
                    },
                }
            },
        )
        bundle = created["data"]
    else:
        bundle = items[0]
    bundle_res_id = bundle["id"]
    print("Bundle resource:", bundle_res_id, bundle["attributes"].get("identifier"))

    # Enable common capabilities if needed (push, etc.) — ignore failures
    for cap in ("PUSH_NOTIFICATIONS", "SIGN_IN_WITH_APPLE"):
        try:
            api(
                "POST",
                "/v1/bundleIdCapabilities",
                json={
                    "data": {
                        "type": "bundleIdCapabilities",
                        "attributes": {"capabilityType": cap},
                        "relationships": {
                            "bundleId": {
                                "data": {"type": "bundleIds", "id": bundle_res_id}
                            }
                        },
                    }
                },
            )
            print("Enabled capability", cap)
        except Exception as e:
            print("Capability", cap, ":", e)

    certs = api(
        "GET",
        "/v1/certificates?filter[certificateType]=DISTRIBUTION&limit=50",
    )
    dist = certs.get("data") or []
    if not dist:
        # try IOS_DISTRIBUTION naming
        certs = api("GET", "/v1/certificates?limit=50")
        dist = [
            c
            for c in (certs.get("data") or [])
            if "DISTRIBUTION" in (c.get("attributes", {}).get("certificateType") or "")
        ]
    if not dist:
        sys.exit("No DISTRIBUTION certificate found in App Store Connect")
    cert = dist[0]
    cert_id = cert["id"]
    print(
        "Using cert:",
        cert_id,
        cert["attributes"].get("name"),
        cert["attributes"].get("certificateType"),
    )

    # Existing profile?
    profiles = api(
        "GET",
        f"/v1/profiles?filter[profileType]=IOS_APP_STORE&filter[name]={PROFILE_NAME}&limit=10",
    )
    profile = None
    for p in profiles.get("data") or []:
        if p["attributes"].get("name") == PROFILE_NAME:
            profile = p
            break

    if profile is None:
        # Also search by listing and matching bundle later
        all_p = api("GET", "/v1/profiles?filter[profileType]=IOS_APP_STORE&limit=200")
        for p in all_p.get("data") or []:
            name = p["attributes"].get("name") or ""
            if "taxigo" in name.lower():
                profile = p
                print("Found existing profile by name:", name)
                break

    if profile is None:
        print("Creating profile", PROFILE_NAME)
        created = api(
            "POST",
            "/v1/profiles",
            json={
                "data": {
                    "type": "profiles",
                    "attributes": {
                        "name": PROFILE_NAME,
                        "profileType": "IOS_APP_STORE",
                    },
                    "relationships": {
                        "bundleId": {
                            "data": {"type": "bundleIds", "id": bundle_res_id}
                        },
                        "certificates": {
                            "data": [{"type": "certificates", "id": cert_id}]
                        },
                    },
                }
            },
        )
        profile = created["data"]

    # Refresh to get profileContent
    pid = profile["id"]
    detail = api("GET", f"/v1/profiles/{pid}")
    attrs = detail["data"]["attributes"]
    name = attrs["name"]
    content_b64 = attrs.get("profileContent")
    if not content_b64:
        sys.exit("profileContent missing")

    prof_path = OUT / "taxigo.mobileprovision"
    # profileContent is already base64 of the .mobileprovision bytes
    raw = base64.b64decode(content_b64)
    prof_path.write_bytes(raw)
    (OUT / "taxigo_profile_name.txt").write_text(name, encoding="utf-8")
    (OUT / "taxigo_profile_b64.txt").write_text(
        base64.b64encode(raw).decode("ascii"), encoding="utf-8"
    )
    print("Wrote", prof_path, "name=", name, "bytes=", len(raw))


if __name__ == "__main__":
    main()
