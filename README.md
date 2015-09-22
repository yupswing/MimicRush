
# The project

I developed this project to learn HAXE and OpenFL.

I've decided to release the project open-source since
I believe it could be useful for other people.

I am sorry if a lot of the code is uncommented and ugly,
but I am still pretty sure there is something to learn especially for newbies.

Enjoy mimic-rush

# Download for free
http://akifox.com/mimicrush/

# Details

The game use few major libraries and few of my own.
`akifox-transform` is used for all the transformation (diagonal text and buttons)
`akifox-asynchttp` is used to send and retrive score from the score server
`plik` is a bigger library that handle most of the cores: sound, music, screen transitions.

I've also stripped away the code that generate a token to talk with the score server
to avoid fake score submission, or score submission by 3rd part forks.
I hope you will understand, all the rest is completely open-source and ready to be
compiled. Do what you want with it ;)

# Play with the code

Fork the project (or just download it) and after install the following libraries

````
haxelib install openfl
haxelib run openfl setup
haxelib install extension-share
haxelib install actuate
haxelib install akifox-transform
haxelib install akifox-asynchttp
haxelib install firetongue
haxelib install compiletime
````

Plus, you have to install the PLIK library from git
````
haxelib git plik https://github.com/yupswing/plik.git haxelib
````

and you are ready to go (we use OpenFL v2 Legacy for compatibility, maybe one day I will port to OpenFL3)

````
lime test neko -Dv2
````

## TODO (1.3)
- [ ] particles! (there should be some)
- [ ] NOT WORKING splash screen (picture) on ios [asked to the community]
- [ ] make the help text sarcastic!
- [ ] check all TODO in source
- [ ] more gameplay test

## DEPLOYMENT
- [ ] WIN 1.2.0 (Dropbox)
- [ ] MAC 1.2.0 (Dropbox)
- [ ] LINUX 1.2.0 (Dropbox)
- [ ] ANDROID 1.2.0 (Google Play)
- [ ] IOS 1.2.0 (App Store)
