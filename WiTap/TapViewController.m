#import "TapViewController.h"

#import "TapViewControllerDelegate.h"

#import "TapView.h"

@interface TapViewController () <TapViewDelegate>

@end

@implementation TapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setting up the view colours in IB is actually harder than setting them up in code.
    
    for (NSInteger tapViewTag = 1; tapViewTag < (kTapViewControllerTapItemCount + 1); tapViewTag++) {
        TapView *   tapView;

        tapView = (TapView *) [self.view viewWithTag:tapViewTag];
        assert([tapView isKindOfClass:[TapView class]]);
        tapView.backgroundColor = [UIColor colorWithHue:(CGFloat) tapViewTag / kTapViewControllerTapItemCount
            saturation:0.75 
            brightness:0.75 
            alpha:1.0
        ];
    }
}

- (IBAction)closeButtonAction:(id)sender
{
    id <TapViewControllerDelegate>  strongDelegate;
    
    #pragma unused(sender)
    strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(tapViewControllerDidClose:)]) {
        [strongDelegate tapViewControllerDidClose:self];
    }
}

#pragma mark * API exposed to our clients

- (void)remoteTouchDownOnItem:(NSUInteger)tapItemIndex
{
    assert(tapItemIndex < kTapViewControllerTapItemCount);
    if (self.isViewLoaded) {
        ((TapView *)[self.view viewWithTag:tapItemIndex + 1]).remoteTouch = YES;
    }
}

- (void)remoteTouchUpOnItem:(NSUInteger)tapItemIndex
{
    assert(tapItemIndex < kTapViewControllerTapItemCount);
    if (self.isViewLoaded) {
        ((TapView *)[self.view viewWithTag:tapItemIndex + 1]).remoteTouch = NO;
    }
}

- (void)resetTouches
{
    for (NSInteger tag = 1; tag <= kTapViewControllerTapItemCount; tag++) {
        TapView *   tapView;
        
        tapView = ((TapView *) [self.view viewWithTag:tag]);
        assert([tapView isKindOfClass:[TapView class]]);
        [tapView resetTouches];
    }
}

#pragma mark * Tap view delegate callbacks

- (void)tapViewLocalTouchDown:(TapView *)tapView
{
    id <TapViewControllerDelegate>  strongDelegate;
    
    strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(tapViewController:localTouchDownOnItem:)]) {
        assert(tapView.tag != 0);
        assert(tapView.tag <= kTapViewControllerTapItemCount);
        [strongDelegate tapViewController:self localTouchDownOnItem:(NSUInteger) ([tapView tag] - 1)];
    }
}

- (void)tapViewLocalTouchUp:(TapView *)tapView
{
    id <TapViewControllerDelegate>  strongDelegate;
    
    strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(tapViewController:localTouchUpOnItem:)]) {
        assert(tapView.tag != 0);
        assert(tapView.tag <= kTapViewControllerTapItemCount);
        [strongDelegate tapViewController:self localTouchUpOnItem:(NSUInteger) ([tapView tag] - 1)];
    }
}

@end
