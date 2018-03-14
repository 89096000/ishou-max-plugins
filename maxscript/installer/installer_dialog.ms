fileIn "installer.ms";

/**
 * PRE INSTALL DIALOG (CHOOSE INSTALL / UNINSTALL)
 */

-- UTF-8 strings (strings.ini file isnt supporting utf8)
_TITLE = "マックス影";
_INSTALL_MSG1 = "ツールをインストールします。";
_INSTALL_MSG2 = "他のバージョンがアンインストールします。";
_INSTALL_TXT = "インストール";
_UPDATE_TXT = "アップデート";
_UNINSTALL_TXT = "消す";
_REINSTALL_TXT = "再インストール";

rollout kage_pre_install ((_TITLE) + " " + \
                              (kageInstaller.getVersion asString:true) + \
                              " installation")
(
   label title_lbl "" offset:[0, 5];
   label descr_lbl "" offset:[0, 5];
   label descr_lbl2 "" offset:[0, -2];
   button install_btn "インストール" width:100 offset:[0, 10] across:3
   button uninstall_btn "消す" width:100 offset:[0, 10]
   button close_btn "終了" width:100 offset:[0, 10]
   
   on kage_pre_install open do
   (
      local isInstalled = kageInstaller.getIsKageInstalled();
      local oldVersion  = kageInstaller.getInstalledVersion();
      local version     = kageInstaller.getVersion();
      local version_str = kageInstaller.getVersion asString:true

      title_lbl.text = (_TITLE) + " " + version_str;
	    descr_lbl.text = _INSTALL_MSG1;
	    descr_lbl2.text = _INSTALL_MSG2;

      print ("Current Version is " + (oldVersion as string))
      print ("New Version is " + version_str)

      if (not isInstalled OR oldVersion == 0) then
         install_btn.text = _INSTALL_TXT;
      else if (oldVersion < version) then
         install_btn.text = _UPDATE_TXT;
      else if (oldVersion == version) then
         install_btn.text = _REINSTALL_TXT;
   )
   
   on install_btn pressed do 
   (
      destroyDialog kage_pre_install;
      kageInstaller.install();
   )
   
   on uninstall_btn pressed do
   (
      destroyDialog kage_pre_install;
      kageInstaller.uninstall();
   )
   
   on close_btn pressed do
   (
      destroyDialog kage_pre_install;
   )
)--End rollout.


createDialog kage_pre_install 330 \
                               110 \
                               modal:true \
                               lockWidth:true \
                               lockHeight:true \
                               style:#(#style_sysmenu, #style_toolwindow);