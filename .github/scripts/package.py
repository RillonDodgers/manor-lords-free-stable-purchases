"""Package Free Oxen And Horses for UE4SS, Vortex, and Nexus Mods."""

import argparse
import os
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parents[2]
MOD_NAME = 'FreeOxenAndHorses'
MOD_FILES = ('Scripts/main.lua', 'enabled.txt', 'VERSION')


def preflight(root: Path) -> str:
    """Check the payload and read its single source of version information."""
    for relative in MOD_FILES:
        if not (root / relative).is_file():
            raise ValueError(f'Missing mod file: {relative}')
    version = (root / 'VERSION').read_text(encoding='utf-8').strip()
    if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?', version):
        raise ValueError('VERSION must contain a version such as 1.0.0 or 1.0.0-beta.1')
    return version


def create_package(root: Path, output_dir: Path, version: str) -> Path:
    """Wrap only the mod payload in its UE4SS install directory."""
    output_dir.mkdir(parents=True, exist_ok=True)
    archive = (output_dir / f'{MOD_NAME}-{version}.zip').resolve()
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as package:
        for relative in MOD_FILES:
            package.write(root / relative, f'{MOD_NAME}/{relative}')
    return archive


def write_actions_metadata(archive: Path, version: str) -> None:
    """Expose package details when running in GitHub Actions."""
    if os.environ.get('GITHUB_OUTPUT'):
        with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as output:
            output.write(f'path={archive.as_posix()}\nversion={version}\ntag=v{version}\n')
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as summary:
            summary.write(f'## {archive.name}\n\nDownload the artifact below. '
                          'Upload this ZIP directly to Nexus Mods or install it through Vortex.\n')


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=Path.cwd())
    args = parser.parse_args()
    try:
        version = preflight(ROOT)
    except ValueError as error:
        parser.error(str(error))
    archive = create_package(ROOT, args.output_dir, version)
    write_actions_metadata(archive, version)
    print(archive)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
