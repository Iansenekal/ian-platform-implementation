#!/usr/bin/env python3
from __future__ import annotations

import argparse
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from typing import Any


CONTROL_FILES = [
    "platform/security/secrets-management/SECRETS_MANAGEMENT.md",
    "platform/security/secrets-management/SECRETS_ROTATION_PROCEDURE.md",
    "tools/pre-commit-secrets-check.sh",
    ".github/workflows/ci.yml",
]


@dataclass
class EnvContext:
    repository: str
    commit_sha: str
    ref: str
    actor: str
    event_name: str
    run_id: str
    run_number: str
    run_attempt: str


def run_cmd(cmd: list[str]) -> str:
    proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return proc.stdout.strip()


def get_commit_sha() -> str:
    if "GITHUB_SHA" in os.environ:
        return os.environ["GITHUB_SHA"]
    try:
        return run_cmd(["git", "rev-parse", "HEAD"])
    except Exception:  # noqa: BLE001
        return "unknown"


def collect_env() -> EnvContext:
    return EnvContext(
        repository=os.getenv("GITHUB_REPOSITORY", Path.cwd().name),
        commit_sha=get_commit_sha(),
        ref=os.getenv("GITHUB_REF", "local"),
        actor=os.getenv("GITHUB_ACTOR", "local-user"),
        event_name=os.getenv("GITHUB_EVENT_NAME", "local"),
        run_id=os.getenv("GITHUB_RUN_ID", "local"),
        run_number=os.getenv("GITHUB_RUN_NUMBER", "local"),
        run_attempt=os.getenv("GITHUB_RUN_ATTEMPT", "1"),
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(8192), b""):
            digest.update(chunk)
    return digest.hexdigest()


def collect_controls() -> list[dict[str, str]]:
    controls: list[dict[str, str]] = []
    for relative in CONTROL_FILES:
        path = Path(relative)
        if not path.is_file():
            raise SystemExit(f"required control file missing: {relative}")
        controls.append(
            {
                "path": relative,
                "sha256": sha256_file(path),
            }
        )
    return controls


def run_secrets_scan() -> dict[str, Any]:
    proc = subprocess.run(
        ["bash", "tools/pre-commit-secrets-check.sh", "--ci"],
        capture_output=True,
        text=True,
    )
    result = {
        "passed": proc.returncode == 0,
        "return_code": proc.returncode,
        "stdout": proc.stdout.strip(),
        "stderr": proc.stderr.strip(),
    }
    if not result["passed"]:
        raise SystemExit(
            "secrets scan failed while generating evidence:\n"
            f"stdout:\n{result['stdout']}\n"
            f"stderr:\n{result['stderr']}"
        )
    return result


def build_evidence() -> dict[str, Any]:
    now = datetime.now(timezone.utc).isoformat()
    env = collect_env()
    controls = collect_controls()
    scan_result = run_secrets_scan()

    return {
        "evidence_type": "secrets_rotation",
        "generated_at_utc": now,
        "workflow": {
            "repository": env.repository,
            "commit_sha": env.commit_sha,
            "ref": env.ref,
            "actor": env.actor,
            "event_name": env.event_name,
            "run_id": env.run_id,
            "run_number": env.run_number,
            "run_attempt": env.run_attempt,
        },
        "rotation_policy": {
            "privileged_credentials_days": 90,
            "service_tokens_days": 30,
            "emergency_rotation": "immediate",
            "policy_source": "platform/security/secrets-management/SECRETS_ROTATION_PROCEDURE.md",
        },
        "controls_snapshot": controls,
        "scan_result": scan_result,
    }


def write_outputs(evidence: dict[str, Any], output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    json_path = output_dir / "secrets-rotation-evidence.json"
    md_path = output_dir / "secrets-rotation-evidence.md"

    json_path.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    markdown = [
        "# Secrets Rotation Evidence",
        "",
        f"Generated at (UTC): `{evidence['generated_at_utc']}`",
        f"Repository: `{evidence['workflow']['repository']}`",
        f"Commit: `{evidence['workflow']['commit_sha']}`",
        f"Workflow run: `{evidence['workflow']['run_id']}`",
        "",
        "## Rotation Policy",
        f"- Privileged credentials: every `{evidence['rotation_policy']['privileged_credentials_days']}` days",
        f"- Service tokens: every `{evidence['rotation_policy']['service_tokens_days']}` days",
        f"- Emergency rotation: `{evidence['rotation_policy']['emergency_rotation']}`",
        "",
        "## Secrets Scan",
        f"- Passed: `{evidence['scan_result']['passed']}`",
        f"- Return code: `{evidence['scan_result']['return_code']}`",
        f"- Output: `{evidence['scan_result']['stdout']}`",
        "",
        "## Controls Snapshot",
    ]
    for control in evidence["controls_snapshot"]:
        markdown.append(f"- `{control['path']}` sha256 `{control['sha256']}`")

    md_path.write_text("\n".join(markdown) + "\n", encoding="utf-8")
    return json_path, md_path


def create_attestation_bundle(
    evidence: dict[str, Any], output_dir: Path, evidence_json_path: Path, evidence_md_path: Path
) -> tuple[Path, Path]:
    checksums_path = output_dir / "checksums.sha256"
    statement_path = output_dir / "attestation-statement.json"

    file_hashes = {
        evidence_json_path.name: sha256_file(evidence_json_path),
        evidence_md_path.name: sha256_file(evidence_md_path),
    }

    checksums_lines = [f"{digest}  {name}" for name, digest in sorted(file_hashes.items())]
    checksums_path.write_text("\n".join(checksums_lines) + "\n", encoding="utf-8")

    statement = {
        "_type": "https://in-toto.io/Statement/v1",
        "subject": [
            {"name": name, "digest": {"sha256": digest}} for name, digest in sorted(file_hashes.items())
        ],
        "predicateType": "https://slsa.dev/provenance/v1",
        "predicate": {
            "buildType": "ian-platform/secrets-rotation-evidence",
            "builder": {"id": "github-actions" if evidence["workflow"]["run_id"] != "local" else "local"},
            "buildDefinition": {
                "externalParameters": {
                    "repository": evidence["workflow"]["repository"],
                    "ref": evidence["workflow"]["ref"],
                    "commit_sha": evidence["workflow"]["commit_sha"],
                    "event_name": evidence["workflow"]["event_name"],
                },
                "internalParameters": {
                    "run_id": evidence["workflow"]["run_id"],
                    "run_number": evidence["workflow"]["run_number"],
                    "run_attempt": evidence["workflow"]["run_attempt"],
                },
            },
            "runDetails": {
                "metadata": {
                    "invocation_id": evidence["workflow"]["run_id"],
                    "startedOn": evidence["generated_at_utc"],
                }
            },
        },
    }
    statement_path.write_text(json.dumps(statement, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return checksums_path, statement_path


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate secrets-rotation compliance evidence")
    parser.add_argument(
        "--output-dir",
        default="artifacts/secrets-rotation",
        help="Directory to write evidence artifacts",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    evidence = build_evidence()
    json_path, md_path = write_outputs(evidence, Path(args.output_dir))
    checksums_path, statement_path = create_attestation_bundle(evidence, Path(args.output_dir), json_path, md_path)
    print(f"evidence-json: {json_path}")
    print(f"evidence-md: {md_path}")
    print(f"attestation-checksums: {checksums_path}")
    print(f"attestation-statement: {statement_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
