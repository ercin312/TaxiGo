#!/usr/bin/env python3
"""CI: patch Runner Release/Profile for manual signing + ExportOptions-ci.plist."""

from __future__ import annotations

import os
import plistlib
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
PBX = REPO / "ios" / "Runner.xcodeproj" / "project.pbxproj"
EXPORT_OUT = REPO / "ios" / "ExportOptions-ci.plist"
BUNDLE_DEFAULT = "com.erhancinar.taxigo"


def _patch_target_config(text: str, config_name: str, team: str, profile: str, bundle_id: str) -> str:
    """Patch the Runner app target XCBuildConfiguration named Release or Profile."""
    esc = profile.replace("\\", "\\\\").replace('"', '\\"')
    # Match Runner app configs that include Runner entitlements / INFOPLIST_FILE = Runner/Info.plist
    pattern = re.compile(
        rf"(/\* {re.escape(config_name)} \*/ = \{{"
        rf".*?INFOPLIST_FILE = Runner/Info\.plist;"
        rf".*?)(\t\t\t\}};\n\t\t\tname = {re.escape(config_name)};)",
        re.DOTALL,
    )

    def repl(m: re.Match[str]) -> str:
        block = m.group(1)
        end = m.group(2)
        # Skip test targets (no INFOPLIST_FILE = Runner/Info.plist already required)
        block = re.sub(
            r"\t\t\t\tCODE_SIGN_STYLE = Automatic;\n",
            "\t\t\t\tCODE_SIGN_STYLE = Manual;\n",
            block,
        )
        if "CODE_SIGN_STYLE = Manual;" not in block:
            block += "\t\t\t\tCODE_SIGN_STYLE = Manual;\n"
        if f"DEVELOPMENT_TEAM = {team};" not in block:
            if "DEVELOPMENT_TEAM =" in block:
                block = re.sub(
                    r"\t\t\t\tDEVELOPMENT_TEAM = [^;]+;\n",
                    f"\t\t\t\tDEVELOPMENT_TEAM = {team};\n",
                    block,
                )
            else:
                block += f"\t\t\t\tDEVELOPMENT_TEAM = {team};\n"
        identity = '\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "Apple Distribution";\n'
        if "CODE_SIGN_IDENTITY[sdk=iphoneos*]" not in block:
            block += identity
        else:
            block = re.sub(
                r'\t\t\t\t"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "[^"]+";\n',
                identity,
                block,
            )
        specifier = f'\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "{esc}";\n'
        if "PROVISIONING_PROFILE_SPECIFIER" in block:
            block = re.sub(
                r"\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = \"[^\"]*\";\n",
                specifier,
                block,
            )
        else:
            block += specifier
        block = re.sub(
            r"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = [^;]+;\n",
            f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {bundle_id};\n",
            block,
        )
        return block + end

    new_text, n = pattern.subn(repl, text, count=1)
    if n != 1:
        sys.exit(f"Failed to patch Runner {config_name} config in {PBX} (matches={n})")
    return new_text


def _write_export_plist(team: str, profile_name: str, bundle_id: str) -> None:
    data = {
        "method": "app-store",
        "signingStyle": "manual",
        "teamID": team,
        "provisioningProfiles": {bundle_id: profile_name},
        "uploadSymbols": True,
    }
    EXPORT_OUT.parent.mkdir(parents=True, exist_ok=True)
    with EXPORT_OUT.open("wb") as f:
        plistlib.dump(data, f)


def main() -> None:
    team = os.environ.get("IOS_TEAM_ID", "").strip()
    profile = os.environ.get("IOS_PROVISIONING_PROFILE_NAME", "").strip()
    bundle_id = os.environ.get("IOS_BUNDLE_ID", BUNDLE_DEFAULT).strip()
    if not team or not profile:
        print("IOS_TEAM_ID and IOS_PROVISIONING_PROFILE_NAME are required.", file=sys.stderr)
        sys.exit(1)
    text = PBX.read_text(encoding="utf-8")
    text = _patch_target_config(text, "Release", team, profile, bundle_id)
    text = _patch_target_config(text, "Profile", team, profile, bundle_id)
    PBX.write_text(text, encoding="utf-8", newline="\n")
    _write_export_plist(team, profile, bundle_id)
    print(f"Patched {PBX} and wrote {EXPORT_OUT}")


if __name__ == "__main__":
    main()
