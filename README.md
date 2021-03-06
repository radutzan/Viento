# Viento: Direct Manipulation Prototype for Apple TV
This is the prototype that accompanies my Medium post, [An interface exploration for the Apple TV](https://medium.com/@radutzan/an-interface-exploration-for-the-apple-tv-fcefc2d19ef2). Don't judge the code, it's just an interaction prototype.

Try out these demos by downloading the source and compiling it to your iOS device. Make sure you've enabled AirPlay Mirroring to your Apple TV _before_ you run the app, or the window might not show up on your TV. Yes, it should work even if you connect Mirroring _after_ launching the app, but it doesn't, and I won't debug it, because it's just a prototype.

If you don't have an Apple TV to AirPlay to, there's software you can install on your Mac to turn it into an AirPlay receiver. I think it's called AirServer. You could try that, I guess. Or you could just run it in the Simulator, but where's the fun in that.

Apparently, running a window over AirPlay Mirroring is limited to 720p, but that's okay, because who cares? It's just a prototype. I've designed and tested the whole thing using that resolution, so YMMV if you get it running on 1080p.

Prototypes. So, so liberating.

Enjoy!

##FAQ
### Why is it called Viento?  
Viento means wind, which is how your finger will move through the glass once you try this out. It will move like the wind.

No, I was just looking for a word with V and T in it so my class prefix could be VT, you know, like TV but backwards. It kind of sounds poetic though, doesn't it? Viento.

This is what I imagine I would be answering in an interview about this. Which obviously will never happen.

### Why is the touch area so small?
I'm trying to simulate the size of the touch surface a real, physical remote, like the one I described on the post, would have. It helps evaluate whether the gestures are effortless enough to perform on a surface of that size; if it works on a 4.7" screen, it doesn't mean it will on a tiny screenless remote, so I decided to account for that.

### Is anything broken?
Well, it's just a prototype, so nothing really works :) But in terms of the demos, the Horizontal Browsing one is pretty much just wired for a quick demo, if you play with it for too long, you will find some weird glitches.

### Who are you?
I'm a designer who writes code for iOS. [I have a couple of apps.](http://ondalabs.com/) I'm 23, from Santiago, Chile.