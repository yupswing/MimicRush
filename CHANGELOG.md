# Version 1.2 (upcoming)

 - Fixes?

# Version 1.1

 - new music (Eric Skiff http://ericskiff.com/music/)
 - fix check version mobile
 - updated credits

# Version 1.0

## General
- [x] splash screen
- [x] board and tiles
- [x] copyboard set and reset
- [x] timer
- [x] score calculation
- [x] storage (asset/memory) management
- [x] scene management
- [x] transition between scenes
- [x] cycle
- [x] scenes as a class
- [x] better size

## BUTTONS
- [x] buttons
- [x] tiles drawing http://haxecoder.com/post.php?id=21
- [x] title screen (menu [new game])

## INTERACT
- [x] multitouch implements (move to select more than one tile)
- [x] better click detection on tiles and buttons (matrix?)

## SCENES
- [x] hold scene on pause
- [x] pause only on game
- [x] resume game
- [x] delete listeners when transition starts
- [x] better pause/hold/transition akifox<->scenes
- [x] button to titlescreen

## SAVE
- [x] save/load system
- [x] preferences (save/load) (music, sound)

## GAMEPLAY
- [x] movement arrow + rotation both ways
- [x] FULL GAMEPLAY
- [x] every mistake lose 1 second no points
- [x] show time (number of seconds and circle for fractions of second)
- [x] show score (circe to show highscore %)

## SFX
- [x] music
- [x] sound effects
- [x] sound effects on gameplay
- [x] sound in mp3 and ogg

## MAKE IT LOOK GOOD
- [x] change name to mimic rush
- [x] splashtitle on desktop and movile
- [x] show WHEN reach highscore on gamescreen
- [x] parallax on gamescreen!
- [x] activate/deactive (really pause on IOS)
- [x] moving background on screens
- [x] fix splash background size
- [x] fix logo credit size (has to be 0.5)
- [x] fix background line goes to alpha 0 on edges top and bottom
- [x] moving backgrounds should be half the size
- [x] language icon
- [x] button positions based on platform (option+title)

## BUGS
- [x] play / hold / new game / finish / still resume available
- [x] flash not running
- [x] statistics bug (SecurityError needs to be handled)
- [x] flash text update for transformation
- [x] tile click when tileboard not ready
- [x] empty copyboard sometimes
- [x] alpha on gamescreen with low alpha on gameover
- [x] timer at 0 has to be 0
- [x] serious leak on hold_scene in screens management
- [x] very slow alpha hole on mobile (fixed changing from BLEND to GRADIENTFILL)

## VARIOUS
- [x] credit screen (+button in title screen)
- [x] credit content
- [x] options screen (+button in title screen)
- [x] effects on/off (akifox preferences)
- [x] effects determine transition mode
- [x] languages (use VARS and button cycle in OptionScreen)
- [x] auto-identify languages at startup mobile devices
- [x] loading screen (before real loading)

## HELP
- [x] help game mode
- [x] first run helpmode, on help button help mode
- [x] sound on help screen
- [x] translate all the helps

## HIGHSCORES
- [x] highscore screen
- [x] highscores online
- [x] highscores local
- [x] show highscores (percentiles)
- [x] double cache (var+file)
- [x] check token in get php
- [x] better solid api
- [x] statistics animation
- [x] numeric values to make the graph understandable
- [x] number on the bottom

## HELPERS
- [x] helper deployment mac (DMG)
- [x] helper deployment windows (NSIS)
- [x] helper deployment android (Signature)
- [x] helper deployment linux (tar.gz)

## FINE TUNING
- [x] better titles
- [x] translation with firetongue
- [x] unload music from memory
- [x] better pause management
- [x] better unload/destroy system (TODO to be finished)
- [x] finish apply new gfx
- [x] make new TextAA and apply
- [x] real resolution independent (points vs pixels)
- [x] background tiles (parallax) single elements instead of big pictures (no actuate but update)
- [x] background tile unload on Screen Unload
- [x] make as fast as possible parallax rendering (to save CPU)
- [x] flash demo up and running
- [x] exclude stats from flash version
- [x] flash demo no splashscreen
- [x] better memory and sound management in Sfx (just play without var)
- [x] build number in credits
- [x] check performance new transformation system (optimize)
- [x] game / board / tile LOGIC has to be diveded better
- [x] polish real resolution independent
- [x] akifox as much as possible
- [x] reorganizing classes
- [x] memory optimization
- [x] cpu optimization

## PREPARATION TO FIRST DEPLOY
- [x] website
- [ ] presskit
- [x] reset services
- [x] quick links akifox.com/mimicrush
- [x] graphics google play
- [x] graphics itunes
- [x] text stores

## PRIVATE GIT (before be made open-source)
ddd9b0d Dev; ready for open-source
53b7382 default font new api
91340ce new TextAA in PLIK
26b3876 TAG 1.1
05e97cf locales fix
8d3d429 tag 1.0.0 (final?) + api url update
b259d00 fancy titles + statistics axes
a122136 deploy mobile + fix deploy desktop
5094c7b build and deploy script for desktops
3ca8bdb windows nsis customization + mac deployment to dmg
a71db91 clean platform conditionals + windows installer
992a155 assets conditional
cb47614 desktop buy screen + clean icons
b4425c1 support asynchttp 0.3 + tag 0.9.2
80a0195 update check localisation
f202e69 version check + better build options + final name?
0b4ebf0 new icons + removed launchimage + updated libraries + better project.xml
9330793 new icons per-platform + reorganising project.xml
023f95c new assets path for releases (everything in one folder) + fix the code to accept the change
fe6dad9 credit added + fix for flash parallax (alpha not supported) + debug mode fix
7e8dd1d build number in credits + todo removed
75d699b Better Sfx system (less memory, less cpu)
21e3dd2 everything is an IDestroyable (better GC control)
16ff89d forgot to restore start screen
d681301 resolved some TODO about conversions to SpriteContainer
571a669 statistics screen polish (animation, numbers ref, positioning)
07f4357 new helptext sarcastic line + helptext fixes + parallax alpha improved
a6c5e1a new parallax system with batch drawing + effects determine transitions
ff25460 using firetongue for translations
e266845 translated help to italian + better help text + removed screenhelp
b9565c3 compressed graphics assets + fix for flash
76f50a7 Fixed slow alpha hole on mobile targets
f54abad sound on help screens
be72dd6 fix blendmode for flash + flash no domain check on debug + minor text fix
c025bf6 help system + keyboard shortcuts + remove unused artworks
59c7d15 TAG 0.8 + Flash up and running (check domain, excluded submit and share button)
1175a1b updated todo list
76adcde fix bug on screen manag. + flash target fully operational
7782719 added few todos
6c16ea1 flash runnable + readme update
6eea028 new transformation system
3ef1aed improved rotation + bugfix makecopy
968b78b var allocation improvements + bugfix on -debug
0b8755b bug still there -_-
b74a1ae timing constants unified for the Game
a1f0925 optimize ScreenGame
5bd845a TAG 0.7 + variable cleaning in ScreenGame
7b1882a rotation and reference implemented
87e528d various bugfix on ScreenGame + show highscore + new sounds
9b651f8 name fix, datasave fix
107e103 show time and score (with info) on GameScreen + fix click when wait for round
598446d TAG 0.6 + update readme todo list
28cfb30 change gamename to MimicRush + new online API
6483060 readme update, unused var removed
e07c6da minor fix (smoothing and running on iOS)
c4caf4c parallax on ScreenGame
3c53a54 TAG 0.5 + new alpha in game + loading "screen"
2c72eb5 GAME.hx clean up
88977f6 bounded keyboard events only in !mobile
d39399e update readme.md todo list
4b3289f sounds in mp3 and ogg and unload music from memory
bc61a12 multires bg_parallax
e49e374 working Parallax background + fix for new pause/change screen management
bdf9006 better pause management
d3686a7 Minor global refactor + new parallax prototype (WIP)
bcafd44 refactor CopyFox to GAME + TAG 0.4
c723c38 refactor to PLIK
4184c17 Better unload/destroy system and new transformation implemented
c36f820 Share extension + new icons (share and labels green and red)
7d912c0 Countdown sfx, new music loops
92597d9 music fix
e99d1aa 0.3 milestone
7665d86 Language icon
a66661e title+option buttons position based on platform
b8c1450 Highscore in other file, double cache online stats (var+file)
d11b746 standard openfl language detection implemented
90b9353 multi language support (en,it) and auto-identify on mobile devices
1b3ff10 fallback on errors retrieving statistics
8a99994 Highscores (Online & Local) + Language setup
1059354 Stats layout prototyped
7c03de2 Preloading common bitmaps to smooth boot
3839de9 Fix logo credit, backgrounds size and alphas
3a7208c Multiresolution, TextureAtlas
33379cd version set real 0.2
9e60e1f Memory GC on OptionScreen and CreditScreen
9b9f720 New prefsave system, new icons, effect pref implemented
a0a6d80 fix mobile help buttons not showing
7fd1d88 Better sliding technique (only two at a time), background alpha fix
be68b35 HelpScreen sliding pictures, fix button
c551064 removed unused png, unload graphics in creditscreen
d6341fb Credit screen completed
98d47a7 Setup help screen, credit screen e stats screen
a88ce37 added launch image, fancy backgrounds, credit screen draft, keys on menus
951cb70 lighten mobile listeners (no keyboard)
a325409 Better TitleScreen, button in game to titlescreen, new icons, temporary game over
2e74b30 Implemented hold/resume with listeners
a4e8c84 Few remove listeners missed
9768e9a OptionScreen
e42cbfc App icons
60bcee2 Sound effects on gameplay, resume game when paused
3c3bb01 Added alphas (pause superimpose), smaller background
3861a4e fix action on buttons (reactive)
8e37e1c Hold scene in background, fix button multiple click
da868d6 Multitouch
4e2e00b Titlescreen with buttons and sf
428a115 lighter splash, better size
d6a6f6e updated stage size to fit content
b27204e Todo update
fd6054c Transform included in Akifox.lib
af9906c Pause fix
d8abfa1 updated to new Screen class
57f594c Implemented splash screen
62006e9 Splash screen implemented
9ccc80c Gameassets and preloader to AkifoxLib; button test
dead638 Implements screens, new fonts test, preloaded fix, new gametes
82ca529 Libraries on haxelib, score and time textfields
5e527f0 preloader update
5f605ff Working prototype
