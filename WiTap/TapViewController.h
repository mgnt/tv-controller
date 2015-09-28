@import UIKit;

#import "TapViewControllerDelegate.h"

@interface TapViewController : UIViewController

@property (nonatomic, weak,   readwrite) id<TapViewControllerDelegate> delegate;

// The view controller maintains kTapViewControllerTapItemCount tap views,
// each with a local and a remote state.  The local state is whether
// the user is currently tapping on the view; the view controller
// tells clients about this via delegate callbacks.  The remote state
// is whether a remote user is currently tapping on the view; the client
// must tell the view controller about this via the various 'remote touch'
// methods below.

enum {
    kTapViewControllerTapItemCount = 9
};

- (void)remoteTouchDownOnItem:(NSUInteger)tapItemIndex;
- (void)remoteTouchUpOnItem:(NSUInteger)tapItemIndex;
- (void)resetTouches;

@end
