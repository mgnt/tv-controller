# TV Controller
Use your iPhone as an Apple TV controller.

The new 2015 Apple TV includes a Siri Remote, but if you want to support multiplayer games, the most convenient controller is one that your players already carry with them in their pockets.

This library aims to enable connecting an iPhone as a controller. Conceptually, it's as if you were to pair your iPhone with the new Apple TV. You'll be able to use it as a controller in your apps, communicating between the iOS device and your tvOS app.

According to Apple, the means of connectivity must be over the network or BTLE, which is probably how the Crossy Road folks did it.

## Other options

* [TvOS_Remote](https://github.com/vivianaranha/TvOS_Remote)
  * Enables sending `NSDictionary` objects. Other types such as `BOOL` and `int` can be sent as `NSNumber` objects using the boxing syntax `@( <expression> )`
