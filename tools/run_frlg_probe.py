import json,os,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[1];workspace=root.parent
project=Path(os.environ.get('HDB_PROJECT',str(root)))
research=Path(os.environ.get('HDB_COMPAT_ROOT',str(workspace/'.work/hd-rse-compat-latest/national-suite-2026-10-21')))
runtime_version=os.environ.get('HDB_RUNTIME_VERSION','0.3.95')
sources={'national_dex_gen3':research/'national_dex_gen3/extracted',
         'g9-battle-sprites-gen3':research/'g9-battle-sprites-gen3/extracted',
         'gen3-hd-sprites':research/'gen3-hd-sprites/extracted',
         '1025dex':Path(os.environ.get('HDB_DEX_ROOT',str(workspace/'.work/1025dex-double-fix'))),
         'hd-dynamic-battlefields':project}
directories={}
for name,folder in sources.items():
    for directory in [folder,*[p for p in folder.rglob('*')if p.is_dir()]]:
        rel=directory.relative_to(folder).as_posix()
        key='mods/'+name+('/'+rel if rel!='.' else '')
        directories[key]=sorted(p.name for p in directory.iterdir())
(research/'directory-index.json').write_text(json.dumps(directories))
version=os.environ.get('HDB_GAME_VERSION','firered');mode=os.environ.get('HDB_COMPAT_MODE','national')
assert version in ('firered','leafgreen')and mode in ('national','1025')
output=project/'docs/evidence/frlg'/('runtime-v'+runtime_version)/f'{version}-{mode}';output.mkdir(parents=True,exist_ok=True)
checks=[]
for size in os.environ.get('HDB_SIZES','1280x720,2560x1080,900x1600').split(','):
    assert size in ('1280x720','2560x1080','5120x1440','900x1600')
    case=output/size;case.mkdir(exist_ok=True)
    for name in ('result.json','error.txt','render.json'):(case/name).unlink(missing_ok=True)
    result=subprocess.run([str(workspace/'.tools/love-audio-runtime/love-probe.exe'),str(root/'tools/frlg_probe')],
        env={**os.environ,'HDB_RENDER':'1','HDB_WORKSPACE':str(workspace),'HDB_SIZE':size,
             'HDB_RUNTIME_VERSION':runtime_version,'HDB_DEX_ROOT':str(sources['1025dex']),
             'HDB_COMPAT_ROOT':str(research)},capture_output=True,text=True,timeout=120)
    if result.returncode or (case/'error.txt').exists():
        (case/'process.log').write_text(result.stdout+result.stderr,encoding='utf-8')
        print((result.stdout+result.stderr)[-2000:])
        if (case/'error.txt').exists():print((case/'error.txt').read_text()[:3000])
        raise RuntimeError('FRLG compatibility fixture failed')
    report=json.loads((case/'render.json').read_text());assert len(report['checks'])==12
    if os.environ.get('HDB_BATTLE_FLOW')=='1':assert report.get('battle_flow',{}).get('result')=='win'
    checks.extend(report['checks'])
summary=json.loads((case/'result.json').read_text());summary['render_checks']=len(checks)
(output/'result.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary))
