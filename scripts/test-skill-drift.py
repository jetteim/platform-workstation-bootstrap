#!/usr/bin/env python3
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('drift',ROOT/'scripts/check-skill-drift.py')
D=importlib.util.module_from_spec(spec);spec.loader.exec_module(D)

class DriftTests(unittest.TestCase):
    def test_reviewed_refinement_and_unrecorded_source_drift(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);source=root/'source/skill';canonical=root/'agents/skills/platform/demo';projection=root/'skills/codex/demo'
            for p in (source,canonical,projection):p.mkdir(parents=True)
            (source/'SKILL.md').write_text('upstream')
            for p in (canonical,projection):(p/'SKILL.md').write_text('reviewed refinement')
            row={'name':'demo','canonical':'agents/skills/platform/demo','projections':['skills/codex/demo'],
                 'reviewed_sha256':D.digest(canonical),'source_package':'source/skill',
                 'source_sha256':D.digest(source),'intentional_refinement':'stricter local secret policy'}
            manifest={'skills':[row]}
            self.assertTrue(D.check(root,manifest)['ok'])
            row['intentional_refinement']='';self.assertFalse(D.check(root,manifest)['ok'])
            row['intentional_refinement']='stricter local secret policy'
            (source/'SKILL.md').write_text('unexpected change');self.assertFalse(D.check(root,manifest)['ok'])
            self.assertEqual((canonical/'SKILL.md').read_text(),'reviewed refinement')

    def test_projection_drift_and_optional_missing_source(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);canonical=root/'agents/skills/platform/demo';projection=root/'skills/codex/demo'
            for p in (canonical,projection):p.mkdir(parents=True);(p/'SKILL.md').write_text('same')
            row={'name':'demo','canonical':'agents/skills/platform/demo','projections':['skills/codex/demo'],
                 'reviewed_sha256':D.digest(canonical),'source_package':'missing/skill','source_sha256':D.digest(canonical)}
            manifest={'skills':[row]};self.assertTrue(D.check(root,manifest)['ok'])
            self.assertFalse(D.check(root,manifest,True)['ok'])
            (projection/'SKILL.md').write_text('changed');self.assertFalse(D.check(root,manifest)['ok'])

if __name__=='__main__':unittest.main()
