#!/usr/bin/env python3
"""Check reviewed packages, projections and available source checkouts without refresh."""
import argparse
import hashlib
import json
from pathlib import Path

def digest(root):
    result=hashlib.sha256()
    for p in sorted(root.rglob('*')):
        if p.is_file() and '__pycache__' not in p.parts and p.name!='.DS_Store' and p.suffix!='.pyc':
            result.update(str(p.relative_to(root)).encode()+b'\0'+p.read_bytes()+b'\0')
    return result.hexdigest()

def check(root, manifest=None, require_sources=False):
    manifest=manifest or json.loads((root/'agents/manifests/skill-snapshots.json').read_text())
    errors=[];missing=[]
    recorded={row['canonical'] for row in manifest['skills']}
    actual={str(p.parent.relative_to(root)) for p in (root/'agents/skills').rglob('SKILL.md')}
    if actual!=recorded:errors.append('canonical inventory differs from reviewed manifest')
    for row in manifest['skills']:
        canonical=root/row['canonical'];name=row['name']
        if not (canonical/'SKILL.md').is_file() or digest(canonical)!=row['reviewed_sha256']:
            errors.append(name+': unreviewed canonical drift')
        for projection in row['projections']:
            target=root/projection
            if not (target/'SKILL.md').is_file() or digest(target)!=row['reviewed_sha256']:
                errors.append(name+': projection drift')
        if row.get('source_package'):
            source=root/row['source_package']
            if not (source/'SKILL.md').is_file():
                missing.append(name)
                if require_sources:errors.append(name+': required source checkout unavailable')
            elif digest(source)!=row['source_sha256']:
                errors.append(name+': unreviewed source drift')
            if row['source_sha256']!=row['reviewed_sha256'] and not row.get('intentional_refinement'):
                errors.append(name+': differing source needs recorded refinement')
    expected={p for row in manifest['skills'] for p in row['projections']}
    projected={str(p.parent.relative_to(root)) for base in ('skills/codex','skills/plugins') for p in (root/base).rglob('SKILL.md')}
    if projected!=expected:errors.append('projection inventory differs from reviewed manifest')
    return {'ok':not errors,'packages':len(recorded),'source_checkouts_unavailable':missing,'errors':errors}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--require-sources',action='store_true');args=p.parse_args()
    result=check(Path(__file__).resolve().parents[1],require_sources=args.require_sources)
    print(json.dumps(result,indent=2));return 0 if result['ok'] else 1

if __name__=='__main__':raise SystemExit(main())
