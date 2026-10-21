#!/usr/bin/env python3
"""
Central entrypoint to run alias-manager scripts based on OS and provided command.

Usage:
  python main.py <command> [args...]

Commands forwarded to scripts in the `scripts/` directory: add, rm, see

On Windows this will attempt to run the PowerShell (.ps1) scripts.
On Unix-like systems this will run the shell (.sh) scripts.
"""
from __future__ import annotations

import sys
import shutil
import subprocess
from pathlib import Path
import platform
from typing import List


SCRIPT_MAP = {
    "add": "add-alias",
    "rm": "rm-alias",
    "see": "see-custom-aliases",
}


def find_script(command: str, prefer_shell: str | None = None) -> tuple[Path, str]:
    """Return (script_path, runner) where runner is the executable to call (bash/pwsh/powershell).

    prefer_shell may be 'bash' or 'powershell' to force a type.
    """
    base = Path(__file__).parent / "scripts"
    name = SCRIPT_MAP.get(command)
    if not name:
        raise ValueError(f"Unknown command: {command}")

    # prefer extension based on OS unless overridden
    is_windows = platform.system().lower().startswith("win")

    candidates: List[tuple[Path, str]] = []
    sh_path = base / (name + ".sh")
    ps_path = base / (name + ".ps1")

    if prefer_shell == "bash":
        candidates.append((sh_path, "bash"))
    elif prefer_shell == "powershell":
        # prefer pwsh then powershell
        runner = shutil.which("pwsh") or shutil.which("powershell")
        if runner:
            candidates.append((ps_path, runner))
        else:
            candidates.append((ps_path, "powershell"))
    else:
        if is_windows:
            runner = shutil.which("pwsh") or shutil.which("powershell")
            candidates.append((ps_path, runner or "powershell"))
            candidates.append((sh_path, "bash"))
        else:
            candidates.append((sh_path, "bash"))
            # on non-Windows we may still try pwsh if ps1 exists and pwsh is present
            runner = shutil.which("pwsh")
            if runner:
                candidates.append((ps_path, runner))

    for path, runner in candidates:
        if path.exists():
            return path, runner

    # Not found: return the most likely candidate (first one) for error message
    return candidates[0]


def run_script(script_path: Path, runner: str | None, args: List[str]) -> int:
    """Run script_path using runner and forward stdout/stderr.

    runner may be an absolute path to an executable or a bare name like 'bash'.
    """
    if not script_path.exists():
        print(f"Script not found: {script_path}")
        return 2

    # Build command
    cmd: List[str] = []
    if script_path.suffix == ".sh":
        # Use bash (prefer full path) and pass script and args
        bash = shutil.which("bash") or "bash"
        cmd = [bash, str(script_path), *args]
    elif script_path.suffix == ".ps1":
        # runner might be 'pwsh' or 'powershell' or a path
        runner_exec = runner or (shutil.which("pwsh") or shutil.which("powershell") or "powershell")
        # Use -File to run the script and forward args
        cmd = [runner_exec, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script_path), *args]
    else:
        # fallback: try executing directly
        cmd = [str(script_path), *args]

    try:
        # Stream output directly
        proc = subprocess.run(cmd)
        return proc.returncode
    except FileNotFoundError:
        print(f"Runner not found: {runner}. Tried to run: {cmd}")
        return 3
    except Exception as exc:  # pragma: no cover - top-level safety
        print(f"Error while executing {script_path}: {exc}")
        return 4


def usage() -> None:
    print("Usage: main.py <add|rm|see> [args...]")
    print("This script will call the corresponding script in the scripts/ directory.")


def main(argv: List[str]) -> int:
    if len(argv) < 2:
        usage()
        return 1

    cmd = argv[1]
    # optional --force-shell=NAME to force 'bash' or 'powershell'
    prefer_shell = None
    extra_args: List[str] = []
    for a in argv[2:]:
        if a.startswith("--force-shell="):
            prefer_shell = a.split("=", 1)[1]
        else:
            extra_args.append(a)

    try:
        script_path, runner = find_script(cmd, prefer_shell)
    except ValueError as ve:
        print(str(ve))
        usage()
        return 1

    rc = run_script(script_path, runner, extra_args)
    return rc


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
