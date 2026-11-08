"""Package Free Oxen And Horses for UE4SS, Vortex, and Nexus Mods."""

import argparse
import os
from pathlib import Path
import re
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--version', default=os.environ.get('REQUESTED_VERSION') or None)
parser.add_argument('--output-dir', type=Path, default=Path.cwd())
args = parser.parse_args()

version = args.version
if not version and os.environ.get('GITHUB_REF_TYPE') == 'tag':
    version = os.environ['GITHUB_REF_NAME'].removeprefix('v')
version = version or '1.0.0'
if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?', version):
    parser.error('Use a version such as 1.0.0 or 1.0.0-beta.1')

root = Path(__file__).resolve().parents[2]
files = [Path('Scripts/main.lua'), Path('enabled.txt')]
for relative in files:
    if not (root / relative).is_file():
        raise SystemExit(f'Missing mod file: {relative}')

args.output_dir.mkdir(parents=True, exist_ok=True)
archive = (args.output_dir / f'FreeOxenAndHorses-{version}.zip').resolve()
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as package:
    for relative in files:
        package.write(root / relative, (Path('FreeOxenAndHorses') / relative).as_posix())

if os.environ.get('GITHUB_OUTPUT'):
    with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as output:
        output.write(f'path={archive.as_posix()}\n')
if os.environ.get('GITHUB_STEP_SUMMARY'):
    with open(os.environ['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as summary:
        summary.write(f'## {archive.name}\n\nDownload the artifact below. '
                      'Upload this ZIP directly to Nexus Mods or install it through Vortex.\n')
print(archive)
