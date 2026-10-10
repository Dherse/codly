"""Project-local pinned tools for Linux x86_64; download only during setup."""
import hashlib, io, json, pathlib, platform, tarfile, urllib.request
root = pathlib.Path(__file__).resolve().parents[1]
assert platform.system() == 'Linux' and platform.machine() == 'x86_64', 'Use Ubuntu/WSL x86_64 for this bootstrap'
versions = json.loads((root / 'tool-versions.json').read_text())
tools = root / '.tools'
tools.mkdir(exist_ok=True)
def download(url):
    return urllib.request.urlopen(url, timeout=90).read()
v = versions['node']
if not (tools / 'node' / 'bin' / 'node').exists():
    filename = f'node-{v}-linux-x64.tar.xz'
    data = download(f'https://nodejs.org/dist/{v}/{filename}')
    checks = download(f'https://nodejs.org/dist/{v}/SHASUMS256.txt').decode()
    expected = next(line.split()[0] for line in checks.splitlines() if line.endswith('  ' + filename))
    assert hashlib.sha256(data).hexdigest() == expected, 'Node checksum mismatch'
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:xz') as archive:
        archive.extractall(tools, filter='data')
    (tools / 'node').symlink_to(f'node-{v}-linux-x64', target_is_directory=True)
if not (tools / 'mdbook').exists():
    v = versions['mdbook']
    release = json.loads(download(f'https://api.github.com/repos/rust-lang/mdBook/releases/tags/{v}'))
    asset = next(a for a in release['assets'] if a['name'].endswith('x86_64-unknown-linux-musl.tar.gz'))
    data = download(asset['browser_download_url'])
    expected = versions.get('mdbook_sha256') or asset.get('digest', '').removeprefix('sha256:')
    assert expected and hashlib.sha256(data).hexdigest() == expected, 'mdBook checksum mismatch'
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as archive:
        archive.extractall(tools, filter='data')
print('Project tools ready.')
