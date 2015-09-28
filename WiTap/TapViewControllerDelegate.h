//
//  TapViewControllerDelegate.h
//  WiTap
//
//  Created by E on 9/26/15.
//
//

#ifndef TapViewControllerDelegate_h
#define TapViewControllerDelegate_h

@class TapViewController;

@protocol TapViewControllerDelegate <NSObject>

@optional

- (void)tapViewController:(TapViewController *)controller localTouchDownOnItem:(NSUInteger)tapItemIndex;
- (void)tapViewController:(TapViewController *)controller localTouchUpOnItem:(NSUInteger)tapItemIndex;
// Called when the user touches down or up on one of the tap items.

- (void)tapViewControllerDidClose:(TapViewController *)controller;
// Called when the user taps on the close button.

@end

#endif /* TapViewControllerDelegate_h */
