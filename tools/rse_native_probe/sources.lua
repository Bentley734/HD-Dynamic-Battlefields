return function(workspace,project)
 local compat=os.getenv('HDB_COMPAT_ROOT')or workspace..'/.work/hd-rse-compat-latest/national-suite-2026-10-21'
 return {
  ['hd-dynamic-battlefields']=os.getenv('HDB_MOD_ROOT')or project,
  wildfollowers=os.getenv('HDB_WILDFOLLOWERS_ROOT')or workspace..'/.work/hd-rse-compat-latest/wildfollowers-3.4.5/extracted',
  gen3transparency=os.getenv('HDB_MENU_ROOT')or workspace..'/.work/menu-gen3-font-fix',
  national_dex_gen3=compat..'/national_dex_gen3/extracted',
  ['g9-battle-sprites-gen3']=compat..'/g9-battle-sprites-gen3/extracted',
  ['gen3-hd-sprites']=compat..'/gen3-hd-sprites/extracted',
  ['1025dex']=os.getenv('HDB_DEX_ROOT')or workspace..'/.work/1025dex-double-fix',
 }
end
