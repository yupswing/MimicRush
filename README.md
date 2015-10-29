[![TileCraft](https://img.shields.io/badge/app-MimicRush%201.2.0-brightgreen.svg)](#)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-win%2Bmac%2Blinux%2Bios%2Bandroid-yellow.svg)](http://www.openfl.org)
# ![MIMICRUSH](https://dl.dropboxusercontent.com/u/683344/akifox/mimicrush/git/title.png)

Easy peasy casual game with a nice twist.

- Developed by [Simone Cingano](http://akifox.com)

- Inspired by [TRID](http://www.kenney.nl/games/trid) by [Kenney.nl](http://www.kenney.nl)

- Music by (CC) [Erik Skiff](http://ericskiff.com/music/)

---
[Read the full changelog](CHANGELOG.md)
---
[Download for FREE!](http://akifox.com/mimicrush/)
---


# The project

I've developed this project to learn HAXE and OpenFL.

I've decided to release the project open-source since I believe it could be useful for other people.

I am sorry if a lot of the code is uncommented and ugly,
but I am still pretty sure there is something to learn especially for newbies.

Enjoy mimic-rush


# Details

The game use few major libraries and few of my own.
- `akifox-transform` is used for all the transformation (diagonal text and buttons)
- `akifox-asynchttp` is used to send and retrive score from the score server
- `plik` is a bigger library that handle most of the cores: sound, music, screen transitions.

I've also stripped away the code that generate a token to talk with the score server
to avoid fake score submission, or score submission by 3rd part forks.

I hope you will understand, all the rest is completely open-source and ready to be
compiled. Do what you want with it (according to the MIT licence) ;)

# Play with the code

Fork the project (or just download it) and after install the following libraries

````
haxelib install openfl
haxelib run openfl setup
haxelib install extension-share
haxelib install actuate
haxelib install akifox-transform
haxelib install akifox-asynchttp
haxelib install compiletime
````

Plus, you have to install the PLIK library and TongueTwist from git
````
haxelib git plik https://github.com/yupswing/plik.git
haxelib git akifox-tonguetwist https://github.com/yupswing/akifox-tonguetwist.git
````

and you are ready to go (we use OpenFL v2 Legacy for compatibility, maybe one day I will port to OpenFL3)

````
lime test neko -Dv2
````

---

## TODO (1.3)
- [ ] save offline score and submit when online
- [ ] ping when launch
- [ ] particles! (there should be some)
- [ ] NOT WORKING splash screen (picture) on ios [asked to the community]
- [ ] make the help text sarcastic!
- [ ] check all TODO in source
- [ ] more gameplay test

## DEPLOYMENT (1.2)
- [ ] WIN 1.2.0 (Dropbox)
- [ ] MAC 1.2.0 (Dropbox)
- [ ] LINUX 1.2.0 (Dropbox)
- [ ] ANDROID 1.2.0 (Google Play)
- [ ] IOS 1.2.0 (App Store)
