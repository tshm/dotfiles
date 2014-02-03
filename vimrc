"if has("gui_win32")
"	let $PATH="C:/Program Files (x86)/Git/cmd;".$PATH.";c:/cygwin/bin/"
"	set shell=c:\Windows\system32\cmd.exe
"endif

source ~/.dotconfig/vimrc_common

"if has("gui_running")
"	set columns=95 lines=50
"endif

"call vam#ActivateAddons(['vim-javascript', 'vim-coffee-script', 'xmledit', 'jade', 'tagbar', 'tComment', 'surround', 'gitv'], {'auto_install' : 0})
