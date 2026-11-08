"""Publish a versioned package without overwriting an existing release."""

import argparse
import os
from pathlib import Path
import subprocess

from package import MOD_NAME, ROOT, preflight


def publish_release(archive: Path, version: str, repository: str, commit: str) -> None:
    tag = f'v{version}'
    existing = subprocess.run(
        ['gh', 'release', 'view', tag, '--repo', repository],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if existing.returncode == 0:
        print(f'Release {tag} already exists; bump VERSION for a new release.')
        return
    command = [
        'gh', 'release', 'create', tag, str(archive), '--repo', repository,
        '--target', commit, '--title', f'Free Oxen And Horses {version}', '--generate-notes',
    ]
    if '-' in version:
        command.append('--prerelease')
    subprocess.run(command, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('archive', type=Path)
    args = parser.parse_args()
    try:
        version = preflight(ROOT)
    except ValueError as error:
        parser.error(str(error))
    if not args.archive.is_file() or args.archive.name != f'{MOD_NAME}-{version}.zip':
        parser.error('Archive must exist and match VERSION')
    repository = os.environ.get('GITHUB_REPOSITORY')
    commit = os.environ.get('GITHUB_SHA')
    if not repository or not commit:
        parser.error('GITHUB_REPOSITORY and GITHUB_SHA must identify the release source')
    publish_release(args.archive.resolve(), version, repository, commit)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
