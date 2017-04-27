fileIn "installer.ms";

/**
 * PRE INSTALL DIALOG (CHOOSE INSTALL / UNINSTALL)
 */

-- UTF-8 strings (strings.ini file isnt supporting utf8)
_TITLE = "こんにちは世界";
_INSTALL_MSG1 = "ツールをインストールします。";
_INSTALL_MSG2 = "他のバージョンがアンインストールします。";
_INSTALL_TXT = "Install";
_UPDATE_TXT = "Upadate";
_UNINSTALL_TXT = "Remove";
_REINSTALL_TXT = "ReInstall";

rollout sekai_pre_install ((_TITLE) + " " + \
                              (sekaiInstaller.getVersion asString:true) + \
                              " installation")
(
   label title_lbl "" offset:[0, 5];
   label descr_lbl "" offset:[0, 5];
   label descr_lbl2 "" offset:[0, -2];
   button install_btn "Install" width:60 offset:[0, 10] across:3
   button uninstall_btn "Uninstall" width:60 offset:[0, 10]
   button close_btn "Close" width:60 offset:[0, 10]
   
   on sekai_pre_install open do
   (
      local isInstalled = sekaiInstaller.getIsSekaiInstalled();
      local oldVersion  = sekaiInstaller.getInstalledVersion();
      local version     = sekaiInstaller.getVersion();
      local version_str = sekaiInstaller.getVersion asString:true

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
      destroyDialog sekai_pre_install;
      sekaiInstaller.install();
   )
   
   on uninstall_btn pressed do
   (
      destroyDialog sekai_pre_install;
      sekaiInstaller.uninstall();
   )
   
   on close_btn pressed do
   (
      destroyDialog sekai_pre_install;
   )
)--End rollout.


createDialog sekai_pre_install 330 \
                               110 \
                               modal:true \
                               lockWidth:true \
                               lockHeight:true \
                               style:#(#style_sysmenu, #style_toolwindow);