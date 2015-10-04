
#import "MainViewController.h"
#import "Snap-Swift.h"

@interface MainViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *sImageView;
@property (nonatomic, weak) IBOutlet UIImageView *nImageView;
@property (nonatomic, weak) IBOutlet UIImageView *aImageView;
@property (nonatomic, weak) IBOutlet UIImageView *pImageView;
@property (nonatomic, weak) IBOutlet UIImageView *jokerImageView;

@property (nonatomic, weak) IBOutlet UIButton *hostGameButton;
@property (nonatomic, weak) IBOutlet UIButton *joinGameButton;
@property (nonatomic, weak) IBOutlet UIButton *singlePlayerGameButton;
@end

@implementation MainViewController {
    BOOL _buttonsEnabled; // TODO: use this to prevent buttons from being tapped while animating
}

@synthesize sImageView = _sImageView;
@synthesize nImageView = _nImageView;
@synthesize aImageView = _aImageView;
@synthesize pImageView = _pImageView;
@synthesize jokerImageView = _jokerImageView;

@synthesize hostGameButton = _hostGameButton;
@synthesize joinGameButton = _joinGameButton;
@synthesize singlePlayerGameButton = _singlePlayerGameButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.hostGameButton tvc_applySnapStyle];
    [self.joinGameButton tvc_applySnapStyle];
    [self.singlePlayerGameButton tvc_applySnapStyle];
}

#pragma mark - Intro Animation

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareForIntroAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performIntroAnimation];
}

- (void)prepareForIntroAnimation
{
    self.sImageView.hidden = YES;
    self.nImageView.hidden = YES;
    self.aImageView.hidden = YES;
    self.pImageView.hidden = YES;
    self.jokerImageView.hidden = YES;
    
    self.hostGameButton.alpha = 0.0f;
    self.joinGameButton.alpha = 0.0f;
    self.singlePlayerGameButton.alpha = 0.0f;
    
    _buttonsEnabled = NO;
}

- (void)performIntroAnimation
{
    self.sImageView.hidden = NO;
    self.nImageView.hidden = NO;
    self.aImageView.hidden = NO;
    self.pImageView.hidden = NO;
    self.jokerImageView.hidden = NO;
    
    CGPoint point = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height * 2.0f);
    
    self.sImageView.center = point;
    self.nImageView.center = point;
    self.aImageView.center = point;
    self.pImageView.center = point;
    self.jokerImageView.center = point;
    
    [UIView animateWithDuration:0.65f
                          delay:0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.sImageView.center = CGPointMake(80.0f, 108.0f);
         self.sImageView.transform = CGAffineTransformMakeRotation(-0.22f);
         
         self.nImageView.center = CGPointMake(160.0f, 93.0f);
         self.nImageView.transform = CGAffineTransformMakeRotation(-0.1f);
         
         self.aImageView.center = CGPointMake(240.0f, 88.0f);
         
         self.pImageView.center = CGPointMake(320.0f, 93.0f);
         self.pImageView.transform = CGAffineTransformMakeRotation(0.1f);
         
         self.jokerImageView.center = CGPointMake(400.0f, 108.0f);
         self.jokerImageView.transform = CGAffineTransformMakeRotation(0.22f);
     }
                     completion:nil];
    
    [UIView animateWithDuration:0.5f
                          delay:1.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.hostGameButton.alpha = 1.0f;
         self.joinGameButton.alpha = 1.0f;
         self.singlePlayerGameButton.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         _buttonsEnabled = YES;
     }];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)hostGameAction:(id)sender
{
    if (_buttonsEnabled)
    {
        HostViewController *controller = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
        
        [self presentViewController:controller animated:NO completion:nil];
    }
}

- (IBAction)joinGameAction:(id)sender
{
}

- (IBAction)singlePlayerGameAction:(id)sender
{
}

@end
