#!/usr/bin/env python3
"""Inspect selected local tokenizer metadata; never download a model."""
import argparse
import hashlib
import json
from pathlib import Path

def inspect(root):
    config=json.loads((root/'tokenizer_config.json').read_text())
    tokenizer=json.loads((root/'tokenizer.json').read_text())
    ids={}
    for entry in tokenizer.get('added_tokens',[]):
        if entry.get('special') and type(entry.get('id')) is int:
            ids[entry['content']]=entry['id']
    for token_id,entry in config.get('added_tokens_decoder',{}).items():
        if entry.get('special'):
            content=entry['content'];value=int(token_id)
            if content in ids and ids[content]!=value:raise ValueError('inconsistent tokenizer metadata')
            ids[content]=value
    template=config.get('chat_template')
    if not template:raise ValueError('chat template missing')
    # ChatML is optional; missing tokens mean this example does not apply.
    chatml={label:ids.get(content) for label,content in [('im_start','<|im_start|>'),('im_end','<|im_end|>')]}
    return {'chatml_supported':all(type(v) is int for v in chatml.values()),
            'chatml_token_ids':chatml,
            'chat_template_sha256':hashlib.sha256(json.dumps(template,sort_keys=True).encode()).hexdigest(),
            'source':'local-tokenizer-metadata'}

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('model_directory',type=Path);args=parser.parse_args()
    try:result=inspect(args.model_directory)
    except (OSError,ValueError,KeyError,TypeError):
        print(json.dumps({'ok':False,'error':'invalid-or-missing-tokenizer-metadata'}));return 2
    print(json.dumps({'ok':True,**result},indent=2));return 0

if __name__=='__main__':raise SystemExit(main())
