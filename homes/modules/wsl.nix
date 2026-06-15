{ pkgs, ... }:

{
  home = {
    packages = [
      pkgs.wsl-open
    ];
  };

  programs.yazi.settings = {
    opener.windows-gui = [
      {
        run = ''win_path="$(wslpath -w -- %s1)" && cmd.exe /C start "" "$win_path"'';
        orphan = true;
        desc = "Open with Windows";
      }
    ];

    open.prepend_rules = [
      {
        url = "*.{xls,xlsx,xlsm,xlsb,xlt,xltx,xltm,ods}";
        use = "windows-gui";
      }
      {
        url = "*.{doc,docx,docm,dot,dotx,dotm,rtf,odt}";
        use = "windows-gui";
      }
      {
        url = "*.{ppt,pptx,pptm,pps,ppsx,pot,potx,potm,odp}";
        use = "windows-gui";
      }
      {
        url = "*.{vsd,vsdx,vsdm}";
        use = "windows-gui";
      }
      {
        mime = "application/pdf";
        use = "windows-gui";
      }
    ];
  };
}
