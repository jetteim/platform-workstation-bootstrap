#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('tokenizer',ROOT/'agents/skills/platform/brain/scripts/tokenizer-metadata.py')
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
class TokenizerTests(unittest.TestCase):
    def test_selected_tokenizer_ids_and_template(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);(root/'tokenizer_config.json').write_text(json.dumps({'chat_template':'synthetic-template'}))
            for first,last in ((1,2),(73,74)):
                (root/'tokenizer.json').write_text(json.dumps({'added_tokens':[
                    {'id':first,'content':'<|im_start|>','special':True},
                    {'id':last,'content':'<|im_end|>','special':True}]}))
                self.assertEqual(M.inspect(root)['chatml_token_ids'],{'im_start':first,'im_end':last})
            (root/'tokenizer.json').write_text('{}');self.assertFalse(M.inspect(root)['chatml_supported'])
    def test_conflicting_tokenizer_files_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            (root/'tokenizer_config.json').write_text(json.dumps({'chat_template':'synthetic','added_tokens_decoder':{'3':{'content':'<|im_start|>','special':True}}}))
            (root/'tokenizer.json').write_text(json.dumps({'added_tokens':[{'id':1,'content':'<|im_start|>','special':True}]}))
            with self.assertRaises(ValueError):M.inspect(root)
if __name__=='__main__':unittest.main()
