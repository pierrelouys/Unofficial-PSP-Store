Unofficial PSP Store is an app store of sorts for PSP homebrews. Based on OneLua.

This is what they call a human pillar (人柱) release. The app hasn't been thoroughly tested, so expect crashes.


## Reporting bugs

You can report issues on the PSP Homebrew discord: https://discord.gg/bePrj9W

Make sure to mention your PSP model and the firmware that you are using. 

If you are unsure about either, just look into the `sys_info.ini` file within the app folder.

## Connecting to Wifi

The PSP can only connect to WPA 1, WEP or unsecured connections. 

Your router might have a setting to use WPA 1 with legacy devices, or support for unsecured guest connections.

If you have an Android phone, you can use it to set up a guest hotspot for your PSP: https://www.youtube.com/watch?v=fBTX2dCXq8Y

## Speed

Expect an average of 30 KB/s. Even under the best circumstances, I never got more than 70 KB/s during testing.

So downloading a 20 MB files will take ((20*1024)/30)/60 = about 11 minutes. Downloading anything much bigger will be impractical.

## Adding custom content

The app can be directed to any zip file by changing `content.lua`, found in the assets folder.

Upload your file to an HTTP (not HTTPS!) host, and add the URL under `dl_url`. 

OneLua does not seem to support all zip standards. 

The app has been tested to work with archives compressed by the deflate method, with 32 KB dictionary size and a word size of 32.

## Alternatives

If this app doesn't suit your needs, try the PSP Homebrew Store by mrneo240: http://psp-dev.org/hb/

## Credits

3d PSP model used if the preview image fails to load:
- Jonathan Sosa
-- https://www.artstation.com/artwork/e0VJmG

Hamster wheel animation:
- Phewcumber
-- https://www.deviantart.com/phewcumber/art/Dwarf-Hamster-736519570
