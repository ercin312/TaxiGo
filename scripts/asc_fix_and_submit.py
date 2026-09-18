#!/usr/bin/env python3
"""Fix TaxiGo App Store Connect metadata and attempt Submit for Review."""

from __future__ import annotations

import base64
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

subprocess.check_call(
    [sys.executable, "-m", "pip", "install", "PyJWT", "cryptography", "-q"]
)
import jwt as pyjwt  # noqa: E402

BUNDLE = "com.erhancinar.taxigo"
PRIVACY = "https://alanyaproje.com/taxigo/privacy.html"
SUPPORT = "https://alanyaproje.com/taxigo/support.html"
MARKETING = "https://alanyaproje.com/taxigo/"
NOTES = (
    "PASSENGER: +905550000001 / 123456\n"
    "DRIVER: +905550000002 / 123456\n\n"
    'On Sign In, tap "App Review — Passenger" or "App Review — Driver" '
    "(one tap). Or enter Username + Password and tap Sign In.\n"
    "No SMS. No Apple ID required.\n\n"
    "Driver account opens an approved driver home with vehicle profile, "
    "wallet balance, and ride history already seeded.\n"
    "Passenger: wallet + trip history pre-populated.\n"
    "This app has no Chats feature — use Trip History / Complaints.\n"
    "Allow location for map/booking review."
)
WHATS_NEW = (
    "Fix App Review driver login: approved driver profile is always "
    "available so Sign In no longer shows Driver profile not found."
)


def token(pem: str, issuer: str, key_id: str) -> str:
    now = int(time.time())
    return pyjwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
        pem,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )


def make_api(pem: str, issuer: str, key_id: str):
    def api(method: str, path: str, body=None, ok=(200, 201, 204)):
        data = None if body is None else json.dumps(body).encode()
        req = urllib.request.Request(
            f"https://api.appstoreconnect.apple.com{path}",
            data=data,
            method=method,
            headers={
                "Authorization": f"Bearer {token(pem, issuer, key_id)}",
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                raw_body = r.read().decode()
                return r.status, json.loads(raw_body) if raw_body else {}
        except urllib.error.HTTPError as e:
            err = e.read().decode()
            print(f"HTTP {e.code} {method} {path}\n{err[:5000]}")
            if e.code in ok:
                return e.code, json.loads(err) if err else {}
            raise SystemExit(f"API failed {e.code} {method} {path}")

    return api


def main() -> None:
    key_id = os.environ["KEY_ID"].strip()
    issuer = os.environ["ISSUER_ID"].strip()
    raw = os.environ["API_KEY"].strip()
    prefer_build = (os.environ.get("BUILD_NUMBER") or "15").strip()

    pem = raw if "BEGIN PRIVATE KEY" in raw else base64.b64decode(raw).decode()
    if not pem.endswith("\n"):
        pem += "\n"

    api = make_api(pem, issuer, key_id)

    _, apps = api("GET", f"/v1/apps?filter[bundleId]={BUNDLE}")
    if not apps.get("data"):
        raise SystemExit(f"App not found for {BUNDLE}")
    app_id = apps["data"][0]["id"]
    print("app", app_id)

    _, versions = api(
        "GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=5"
    )
    version = versions["data"][0]
    version_id = version["id"]
    print("version", version["attributes"])

    # usesIdfa
    api(
        "PATCH",
        f"/v1/appStoreVersions/{version_id}",
        {
            "data": {
                "type": "appStoreVersions",
                "id": version_id,
                "attributes": {"usesIdfa": False},
            }
        },
    )
    print("usesIdfa=false")

    # version localization urls — skip whatsNew (not editable on first version)
    _, locs = api(
        "GET", f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    )
    for loc in locs["data"]:
        lid = loc["id"]
        attrs = {
            "supportUrl": SUPPORT,
            "marketingUrl": MARKETING,
        }
        try:
            api(
                "PATCH",
                f"/v1/appStoreVersionLocalizations/{lid}",
                {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": lid,
                        "attributes": attrs,
                    }
                },
            )
            print("patched loc", loc["attributes"].get("locale"), lid)
        except SystemExit as e:
            print("loc patch skip", e)

    # appInfo localization privacy (App Information > Privacy Policy URL)
    _, infos = api("GET", f"/v1/apps/{app_id}/appInfos")
    for info in infos.get("data", []):
        iid = info["id"]
        print("appInfo", iid, info["attributes"])
        status, ilocs = api(
            "GET", f"/v1/appInfos/{iid}/appInfoLocalizations", ok=(200, 404)
        )
        if status != 200:
            continue
        for il in ilocs.get("data", []):
            print(
                "appInfoLoc before",
                il["id"],
                il["attributes"].get("locale"),
                il["attributes"].get("privacyPolicyUrl"),
            )
            try:
                api(
                    "PATCH",
                    f"/v1/appInfoLocalizations/{il['id']}",
                    {
                        "data": {
                            "type": "appInfoLocalizations",
                            "id": il["id"],
                            "attributes": {"privacyPolicyUrl": PRIVACY},
                        }
                    },
                )
                print("patched appInfoLoc privacy", il["id"])
            except SystemExit as e:
                print("appInfoLoc patch skip", e)

    # review detail
    _, rd = api("GET", f"/v1/appStoreVersions/{version_id}/appStoreReviewDetail")
    detail_id = rd["data"]["id"]
    api(
        "PATCH",
        f"/v1/appStoreReviewDetails/{detail_id}",
        {
            "data": {
                "type": "appStoreReviewDetails",
                "id": detail_id,
                "attributes": {
                    "demoAccountRequired": True,
                    "demoAccountName": "+905550000001",
                    "demoAccountPassword": "123456",
                    "contactFirstName": "Erhan",
                    "contactLastName": "Cinar",
                    "contactEmail": "destek@taxigo.app",
                    "contactPhone": "+905550000001",
                    "notes": NOTES,
                },
            }
        },
    )
    print("review detail ok")

    # build
    _, builds = api(
        "GET", f"/v1/builds?filter[app]={app_id}&sort=-uploadedDate&limit=20"
    )
    build_id = None
    for b in builds["data"]:
        if (
            str(b["attributes"].get("version")) == prefer_build
            and b["attributes"].get("processingState") == "VALID"
        ):
            build_id = b["id"]
            break
    if build_id:
        api(
            "PATCH",
            f"/v1/appStoreVersions/{version_id}/relationships/build",
            {"data": {"type": "builds", "id": build_id}},
        )
        print("build attached", prefer_build, build_id)

    # Release version from any prior submissions (cancel + delete items)
    _, subs = api(
        "GET", f"/v1/apps/{app_id}/reviewSubmissions?filter[platform]=IOS&limit=15"
    )
    open_ready_id = None
    for s in subs.get("data", []):
        st = s["attributes"].get("state")
        sid = s["id"]
        print("sub", sid, st)
        if st == "READY_FOR_REVIEW":
            open_ready_id = sid
        if st in ("UNRESOLVED_ISSUES", "READY_FOR_REVIEW", "CANCELING", "CANCELED"):
            status, items = api(
                "GET", f"/v1/reviewSubmissions/{sid}/items", ok=(200, 404)
            )
            for it in items.get("data") or []:
                print("  item", it["id"], it["attributes"])
                try:
                    api(
                        "DELETE",
                        f"/v1/reviewSubmissionItems/{it['id']}",
                        ok=(204, 200, 409, 403),
                    )
                    print("  deleted item", it["id"])
                except SystemExit as e:
                    print("  delete item skip", e)
            if st in ("UNRESOLVED_ISSUES", "READY_FOR_REVIEW"):
                try:
                    api(
                        "PATCH",
                        f"/v1/reviewSubmissions/{sid}",
                        {
                            "data": {
                                "type": "reviewSubmissions",
                                "id": sid,
                                "attributes": {"canceled": True},
                            }
                        },
                    )
                    print("canceled", sid)
                    if open_ready_id == sid:
                        open_ready_id = None
                except SystemExit as e:
                    print("cancel skip", e)

    time.sleep(3)

    # Prefer existing READY_FOR_REVIEW submission, else create
    if open_ready_id:
        sid = open_ready_id
        print("reusing submission", sid)
    else:
        _, created = api(
            "POST",
            "/v1/reviewSubmissions",
            {
                "data": {
                    "type": "reviewSubmissions",
                    "attributes": {"platform": "IOS"},
                    "relationships": {
                        "app": {"data": {"type": "apps", "id": app_id}}
                    },
                }
            },
        )
        sid = created["data"]["id"]
        print("created submission", sid, created["data"]["attributes"])

    try:
        api(
            "POST",
            "/v1/reviewSubmissionItems",
            {
                "data": {
                    "type": "reviewSubmissionItems",
                    "relationships": {
                        "reviewSubmission": {
                            "data": {"type": "reviewSubmissions", "id": sid}
                        },
                        "appStoreVersion": {
                            "data": {"type": "appStoreVersions", "id": version_id}
                        },
                    },
                }
            },
        )
        print("item linked")
    except SystemExit as e:
        print("link item failed, trying submit anyway:", e)

    try:
        _, submitted = api(
            "PATCH",
            f"/v1/reviewSubmissions/{sid}",
            {
                "data": {
                    "type": "reviewSubmissions",
                    "id": sid,
                    "attributes": {"submitted": True},
                }
            },
        )
        print("SUBMITTED", submitted["data"]["attributes"])
    except SystemExit:
        _, v = api("GET", f"/v1/appStoreVersions/{version_id}")
        print("version after fail", v["data"]["attributes"])
        _, items = api("GET", f"/v1/reviewSubmissions/{sid}/items", ok=(200, 404))
        print("submission items", json.dumps(items, indent=2)[:2000])
        # Also check build export compliance
        _, builds = api(
            "GET",
            f"/v1/builds?filter[app]={app_id}&filter[version]={prefer_build}&limit=5",
        )
        for b in builds.get("data", []):
            print("build attrs", b["id"], b["attributes"])
            try:
                api(
                    "PATCH",
                    f"/v1/builds/{b['id']}",
                    {
                        "data": {
                            "type": "builds",
                            "id": b["id"],
                            "attributes": {
                                "usesNonExemptEncryption": False,
                            },
                        }
                    },
                )
                print("set usesNonExemptEncryption=false on", b["id"])
            except SystemExit as e:
                print("encryption patch skip", e)
        raise

    _, versions2 = api(
        "GET", f"/v1/apps/{app_id}/appStoreVersions?filter[platform]=IOS&limit=3"
    )
    for v in versions2["data"]:
        print(
            "END",
            v["attributes"].get("versionString"),
            v["attributes"].get("appStoreState"),
            v["attributes"].get("appVersionState"),
        )
    print("DONE")


if __name__ == "__main__":
    main()
