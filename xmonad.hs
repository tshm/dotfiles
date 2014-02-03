import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Control.Monad
import qualified XMonad.StackSet as W
import System.IO

myWorkspaces = ["main","vim","web","media","dev"]

myManageHook = composeAll . concat $
	[ -- Applications that go to web
	  [ className =? b --> doF (W.shift "web") | b <- myClassWebShifts ]
	  -- Applications that go to media
	, [ className =? c --> viewShift "media" | c <- myClassMediaShifts ]
	]
	where
		viewShift = doF . liftM2 (.) W.greedyView W.shift
		myClassWebShifts  = ["Iceweasel"]
		myClassMediaShifts = ["MPlayer", "mplayer2", "smplayer2"]

main = do
	xmproc <- spawnPipe "/usr/bin/xmobar /home/tshm/.xmobarrc"
	xmonad $ defaultConfig
		{ manageHook = manageDocks <+> myManageHook
		, workspaces  = myWorkspaces
		, layoutHook = avoidStruts  $  layoutHook defaultConfig
		, logHook = dynamicLogWithPP xmobarPP
			{ ppOutput = hPutStrLn xmproc
			, ppTitle = xmobarColor "green" "" . shorten 50
			}
		, borderWidth = 2
		, terminal    = "urxvt"
		, modMask     = mod4Mask
		} `additionalKeys`
		[ ((mod4Mask, xK_comma), spawn "~/bin/dmenu.sh")
		]
