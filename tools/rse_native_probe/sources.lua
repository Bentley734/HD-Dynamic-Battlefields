return function(workspace,project)
 local compat=os.getenv('HDB_COMPAT_ROOT')or workspace..'/.work/hd-frlg-compat'
 return {
  ['hd-dynamic-battlefields']=project,
  gen3transparency=os.getenv('HDB_MENU_ROOT')or workspace..'/.work/menu-gen3-font-fix',
  national_dex_gen3=compat..'/national_dex_gen3/extracted',
  ['g9-battle-sprites-gen3']=compat..'/g9-battle-sprites-gen3/extracted',
  ['gen3-hd-sprites']=compat..'/gen3-hd-sprites/extracted',
  ['1025dex']=os.getenv('HDB_DEX_ROOT')or workspace..'/.work/hd-rse-compat-latest/1025dex-1.5.1/extracted/1025dex',
 }
end
