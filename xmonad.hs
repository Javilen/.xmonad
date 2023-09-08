--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.

-- Imports

import XMonad
import Data.Monoid
import Data.Maybe (fromJust)
import System.IO (hPutStrLn)
import System.Exit
import Graphics.X11.ExtraTypes.XF86


import XMonad.Util.Cursor
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import qualified XMonad.Util.Hacks as Hacks (trayerAboveXmobarEventHook)  -- Need version -17 of xmonad-contrib to use

import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.WindowSwallowing

--import XMonad.Layout.Tabbed
--import XMonad.Layout.Gaps -- gaps around the edges
import XMonad.Layout.Spacing --gaps between windows
import XMonad.Layout.Fullscreen 
import XMonad.Layout.ThreeColumns 
import XMonad.Layout.Magnifier (magnifiercz') 
import XMonad.Layout.NoBorders  (noBorders, smartBorders)
import XMonad.Layout.ToggleLayouts  (ToggleLayout(..), toggleLayouts)
import XMonad.Layout.Renamed  -- Important for the full screen modification
import XMonad.Layout.LayoutModifier  -- Needed for spacing function 

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
--myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myWorkspaces    = ["dev","web","doc","com","tty","tty2","com2","ssh","virt"]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] 

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#43556a"
myFocusedBorderColor = "#ff0000"  -- "ff0000"  
-- Clickable components
--
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)
    , ((modm,             xK_KP_Enter), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "rofi -show drun")

    -- launch pcmanfm
    , ((modm,               xK_d     ), spawn "pcmanfm")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm,               xK_q     ), kill)

    -- launch ROFI power menu
    , ((modm .|. shiftMask, xK_q     ), unGrab >> spawn "~/.config/rofi/qtilepowermenu.sh")

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
    , ((modm,               xK_Down     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
    , ((modm,               xK_Up     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask,  xK_Return), windows W.swapMaster)
    , ((modm .|. controlMask,  xK_Up), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    , ((modm .|. shiftMask, xK_Down     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    , ((modm .|. shiftMask, xK_Up     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
    , ((modm, xK_Left                ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm, xK_Right               ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    --  Make full screen with a toggle
    , ((modm,               xK_f     ), sendMessage( Toggle "Full" ) >> sendMessage ToggleStruts) -- >>  unGrab >> spawn "python3 ~/.xmonad/scripts/nodark.py")

    -- Toggle taskbar
    , ((modm,  xK_b     ), unGrab >> spawn "~/.xmonad/scripts/taskbar.sh trayer")

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Take a screenshot
    , ((modm              , xK_Print), spawn "flameshot gui -p ~/Pictures")

    -- Change screen brightness
    , ((0,    xF86XK_MonBrightnessUp), spawn "brightnessctl set +5%")
    , ((0,    xF86XK_MonBrightnessDown), spawn "brightnessctl set 5%-")

    -- Change screen brightness (fine)
    , ((modm,    xF86XK_MonBrightnessUp), spawn "brightnessctl set +2%")
    , ((modm,    xF86XK_MonBrightnessDown), spawn "brightnessctl set 2%-")

    -- Multi-display gui config 
    , ((0,    xF86XK_Display), spawn "arandr")

    -- Toggle the status bar gap
    -- Use this binding wconfigith avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
--     , ((modm              , xK_b     ), sendMessage (ToggleStruts))   -- not very usefull

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_c     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_c     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessagimport XMonad.Layout.Fullscreene with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
     ++

    
     -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
     -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    
     [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
-- myLayout = tiled ||| tabs ||| Full
 
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall     = renamed [Replace "tall"]
       --    $ windowNavigation
       --    $ subLayout [] (smartBorders Simplest)
       --    $ limitWindows 12
           $ mySpacing 8
           $ Tall nmaster delta ratio  
threeCol = renamed [Replace "threeCol"]
         $ magnifiercz' 1.3
         $ mySpacing 8
         $ ThreeColMid nmaster delta ratio

-- threeCol = magnifiercz' 1.3 $ mySpacing 8 $ ThreeColMid nmaster delta ratio
nmaster = 1
ratio = 1/2
delta = 3/100

myLayout = avoidStruts $ toggleLayouts (noBorders Full) 
                myDefaultLayout
             where
               myDefaultLayout =     tall
                                 ||| Mirror tall
                                 ||| threeCol
--                                 ||| noBorders Full
--                                 ||| Mirror threeCol
                             
                                 




------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "Steam"           --> doFloat
    , className =? "zoom"           --> doFloat
    , className =? "Reminders"           --> doFloat
    , className =? "gsimplecal"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- myEventHook = mempty <+> fullscreenEventHook
myEventHook =  mempty <+> fullscreenEventHook <+> swallowEventHook (className =? "Alacritty" <||> className =? "Termite") (return True) <+> Hacks.trayerAboveXmobarEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()
--myLogHook =  dynamicLogWithPP $ xmobarPP
--          { ppOutput = hPutStrLn xmobar
--          }


------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook :: X ()
myStartupHook = do 
   spawnOnce "~/.xmonad/scripts/autostart.sh &"
   setDefaultCursor xC_left_ptr
--   spawnOnce "trayer  --monitor 1 --edge top --align center --SetDockType true --SetPartialStrut false --expand true --widthtype request  --transparent true --tint 0x000000 --height 18 &"
  -- spawn Once "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 10 --transparent true --tint 0x5f5f5f --height 18"
   --spawnOnce "~/.config/polybar/launch.sh &"
   setWMName "LG3D"
-----------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO ()
main = do
--   xmproc0 <- spawnPipe "xmobar -x 0 ~/.xmonad/xmobar/nord-xmobarrc"
   xmproc0 <- spawnPipe "xmobar -x 0 ~/.xmonad/xmobar/.xmobarrc0"
--   xmproc1 <- spawnPipe "xmobar -x 1 ~/.xmonad/xmobar/.xmobarrc1" 
--   xmonad . docks .  ewmh =<< xmobar def
   xmonad $ docks $  ewmh  def
        {  modMask            = myModMask
        ,  terminal           = myTerminal
        ,  focusFollowsMouse  = myFocusFollowsMouse
        ,  clickJustFocuses   = myClickJustFocuses
        ,  borderWidth        = myBorderWidth
        ,  workspaces         = myWorkspaces
        ,  normalBorderColor  = myNormalBorderColor
        ,  focusedBorderColor = myFocusedBorderColor
        ,  keys               = myKeys
        ,  mouseBindings      = myMouseBindings
        , layoutHook          = myLayout
        ,  manageHook = myManageHook <+> manageDocks
        ,  handleEventHook   =  myEventHook 
        ,  startupHook        = myStartupHook
        ,  logHook            = dynamicLogWithPP $ xmobarPP
              { ppOutput = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
                           --   >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
                -- Current workspace
              , ppCurrent = xmobarColor "#51EFA8" "" . wrap "[" "]"
--                            ("<box type=Bottom width=2 mb=2 color=" ++ "#c678dd" ++ ">") "</box>"
                -- Visible but not current workspace
              , ppVisible = xmobarColor "#c678dd" "" .wrap "(" ")" . clickable   --  clickable 
--                           ("<box type=Bottom mb=4 width=2 color=" ++ "#FDFB00" ++ ">") "</box>" . clickable

                -- Hidden workspace
              , ppHidden = xmobarColor "#51afef" "" . wrap
                           ("<box type=Bottom width=2 mb=3 color=" ++ "#51EBEF" ++ ">") "</box>" . clickable
--                           ("<box type=Top width=2 mt=2 color=" ++ "#51afef" ++ ">") "</box>" . clickable
                -- Hidden workspaces (no windows)
              , ppHiddenNoWindows = xmobarColor "#51afef" ""  . clickable
                -- Title of active window
              , ppTitle = xmobarColor "#dfdfdf" "" . shorten 30
                -- Separator character  
--              , ppWsSep =  "<fc=" ++ "#5b6268" ++ "> <fn=1>|</fn> </fc>"
                -- Urgent workspace
              , ppUrgent = xmobarColor "#ff6c6b" "" . wrap "!" "!"
                -- Adding # of windows on current workspace to the bar
--              , ppExtras  = [windowCount]
                -- order of things in xmobar
--              , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                              } 
        }
-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
-- Deas: not used in current configuration
efaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
