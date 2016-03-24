-- ~/.xmonad/xmonad.hs
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)
import Control.Monad
import qualified XMonad.StackSet as W
import System.IO

myWorkspaces :: [String]
myWorkspaces = ["main","snd","web","media","dev"]

myManageHook :: ManageHook
myManageHook = composeAll . concat $
	[ -- Applications that go to web
	  [ className =? b --> doF (W.shift "web") | b <- myClassWebShifts ]
	  -- Applications that go to media
	, [ className =? c --> viewShift "media" | c <- myClassMediaShifts ]
		-- Applications that go float
	, [ className =? "Tilda" --> doFloat ]
	]
	where
		viewShift = doF . liftM2 (.) W.greedyView W.shift
		myClassWebShifts  = ["Iceweasel"]
		myClassMediaShifts = ["MPlayer", "mplayer2", "smplayer2"]

main :: IO ()
main = do
	xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
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
		} `additionalKeysP`
		[ ("M-,", spawn "~/bin/dmenu.sh"),
		  -- ex=`cat ~/.dmenu | dmenu` && exec $ex
		  ("<XF86AudioMedia>", spawn "sudo systemctl hibernate")
		]
