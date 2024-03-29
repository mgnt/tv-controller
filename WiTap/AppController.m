/*
     File: AppController.m
 Abstract: UIApplication's delegate class, the central controller of the application.
  Version: 2.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AppController.h"

//#import "TapViewController.h"
#import "PickerViewController.h"

#import "WiTap-Swift.h"

// The Bonjour service type consists of an IANA service name (see RFC 6335)
// prefixed by an underscore (as per RFC 2782).
//
// <http://www.ietf.org/rfc/rfc6335.txt>
// 
// <http://www.ietf.org/rfc/rfc2782.txt>
// 
// See Section 5.1 of RFC 6335 for the specifics requirements.
// 
// To avoid conflicts, you must register your service type with IANA before
// shipping.
// 
// To help network administrators identify your service, you should choose a
// service name that's reasonably human readable.

static NSString * kWiTapBonjourType = @"_witap2._tcp.";

@interface AppController () <
UIApplicationDelegate,
//TapViewControllerDelegate,
TouchViewControllerDelegate,
PickerDelegate,
NSNetServiceDelegate,
NSStreamDelegate
>

//@property (nonatomic, strong, readwrite) TapViewController *    tapViewController;
@property (nonatomic, strong, readwrite) TouchViewController *    touchViewController;
@property (nonatomic, strong, readwrite) NSNetService *         server;
@property (nonatomic, assign, readwrite) BOOL                   isServerStarted;
@property (nonatomic, copy,   readwrite) NSString *             registeredName;
@property (nonatomic, strong, readwrite) NSInputStream *        inputStream;
@property (nonatomic, strong, readwrite) NSOutputStream *       outputStream;
@property (nonatomic, assign, readwrite) NSUInteger             streamOpenCount;
@property (nonatomic, strong, readwrite) PickerViewController * picker;

@end

#pragma mark -
@implementation AppController

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #pragma unused(application)
    #pragma unused(launchOptions)
    
    // Get the root view controller (set up by the storyboard)
    
    self.touchViewController = (TouchViewController *) self.window.rootViewController;
    assert([self.touchViewController isKindOfClass:[TouchViewController class]]);
    self.touchViewController.delegate = self;
    
    // Show our window
    
    self.window.rootViewController = self.touchViewController;
    [self.window makeKeyAndVisible];
    
    // Create and advertise our server.  We only want the service to be registered on 
    // local networks so we pass in the "local." domain.

    self.server = [[NSNetService alloc] initWithDomain:@"local." type:kWiTapBonjourType name:[UIDevice currentDevice].name port:0];
    self.server.includesPeerToPeer = YES;
    [self.server setDelegate:self];
    [self.server publishWithOptions:NSNetServiceListenForConnections];
    self.isServerStarted = YES;
    
    // Set up for a new game, which presents a Bonjour browser that displays other 
    // available games.

    [self setupForNewGame];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    #pragma unused(application)
    
    // If there's a game playing, shut it down.  Whether this is the right thing to do 
    // depends on your app.  In some cases it might be more sensible to leave the connection 
    // in place for a short while to see if the user comes back to the app.  This issue is 
    // discussed in more depth in Technote 2277 "Networking and Multitasking".
    //
    // <https://developer.apple.com/library/ios/#technotes/tn2277/_index.html>
    
    if (self.inputStream) {
        [self setupForNewGame];
    }
    
    // Quiesce the server and service browser, if any.
    
    [self.server stop];
    self.isServerStarted = NO;
    self.registeredName = nil;
    if (self.picker != nil) {
        [self.picker stop];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    #pragma unused(application)
    
    // Quicken the server.  Once this is done it will quicken the picker, if there's one up.
    
    assert( ! self.isServerStarted );
    [self.server publishWithOptions:NSNetServiceListenForConnections];
    self.isServerStarted = YES;
    if (self.registeredName != nil) {
        [self startPicker];
    }
}

- (void)setupForNewGame
{
    // Reset our tap view state to avoid old taps appearing in the new game.

    [self.touchViewController resetTouches];

    // If there's a connection, shut it down.

    [self closeStreams];
    
    // If our server is deregistered, reregister it.
    
    if ( ! self.isServerStarted ) {
        [self.server publishWithOptions:NSNetServiceListenForConnections];
        self.isServerStarted = YES;
    }
    
    // And show the service picker.
    
    [self presentPicker];
}

#pragma mark - Picker management

- (void)startPicker
{
    assert(self.registeredName != nil);
    
    // Tell the picker about our registration.  It uses this to a) filter out our game 
    // from the results, and b) display our game name in its table view header.
    
    self.picker.localService = self.server;
    
    // Start it up.
    
    [self.picker start];
}

- (void)presentPicker
{
    if (self.picker != nil) {
        // If the picker is already on screen then we're here because of a connection failure. 
        // In that case we just cancel the picker's connection UI and the user can choose another 
        // service.
        
        [self.picker cancelConnect];
    } else {
        // Create the service picker and put it up on screen.  We only start the picker 
        // if our server has completed its registration (the picker needs to know our 
        // service name so that it can exclude us from the list).  If that's not the 
        // case then the picker remains stopped until -serverDidStart: runs.
        
        self.picker = [self.touchViewController.storyboard instantiateViewControllerWithIdentifier:@"picker"];
        assert([self.picker isKindOfClass:[PickerViewController class]]);
        self.picker.type = kWiTapBonjourType;
        self.picker.delegate = self;
        if (self.registeredName != nil) {
            [self startPicker];
        }

        [self.touchViewController presentViewController:self.picker animated:NO completion:nil];
    }
}

- (void)dismissPicker
{
    assert(self.picker != nil);
    
    [self.touchViewController dismissViewControllerAnimated:NO completion:nil];
    [self.picker stop];
    self.picker = nil;
}

- (void)pickerViewController:(PickerViewController *)controller connectToService:(NSNetService *)service
    // Called by the picker when the user has chosen a service for us to connect to. 
    // The picker is already displaying its connection-in-progress UI.
{
    BOOL                success;
    NSInputStream *     inStream;
    NSOutputStream *    outStream;

    assert(controller == self.picker);
    #pragma unused(controller)
    assert(service != nil);
    
    assert(self.inputStream == nil);
    assert(self.outputStream == nil);

    // Create and open streams for the service.
    // 
    // -getInputStream:outputStream: just creates the streams, it doesn't hit the 
    // network, and thus it shouldn't fail under normal circumstances (in fact, its 
    // CFNetService equivalent, CFStreamCreatePairWithSocketToNetService, returns no status 
    // at all).  So, I didn't spend too much time worrying about the error case here.  If 
    // we do get an error, you end up staying in the picker.  OTOH, actual connection errors 
    // get handled via the NSStreamEventErrorOccurred event.
    
    success = [service getInputStream:&inStream outputStream:&outStream];
    if ( ! success ) {
        [self setupForNewGame];
    } else {
        self.inputStream  = inStream;
        self.outputStream = outStream;

        [self openStreams];
    }
}

- (void)pickerViewControllerDidCancelConnect:(PickerViewController *)controller
    // Called by the picker when the user taps the Cancel button in its 
    // connection-in-progress UI.  We respond by closing our in-progress connection.
{
    #pragma unused(controller)
    [self closeStreams];
}

#pragma mark - Connection management

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    #pragma unused(stream)
    
    switch(eventCode) {

        case NSStreamEventOpenCompleted: {
            self.streamOpenCount += 1;
            assert(self.streamOpenCount <= 2);
            
            // Once both streams are open we hide the picker and the game is on.
            
            if (self.streamOpenCount == 2) {
                [self dismissPicker];
                
                [self.server stop];
                self.isServerStarted = NO;
                self.registeredName = nil;
            }
        } break;
        
        case NSStreamEventHasSpaceAvailable: {
            assert(stream == self.outputStream);
            // do nothing
        } break;
        
        case NSStreamEventHasBytesAvailable: {
            assert(stream == self.inputStream);
            
            [self readBytesFromInputStream];
        } break;

        default:
            assert(NO);
            // fall through
        case NSStreamEventErrorOccurred:
            // fall through
        case NSStreamEventEndEncountered: {
            [self setupForNewGame];
        } break;
    }
}

static NSMutableData *mutableData = nil; // TODO: reset mutableData when a new game is started (reset state)

- (void)readBytesFromInputStream
{
    uint8_t buffer[1024]; // read up to 1024 bytes at a time
    NSInteger   bytesRead;
    
    NSLog(@"performing read...");
    
    // important: don't call this more than necessary; it can block the main thread.
    bytesRead = [self.inputStream read:buffer maxLength:sizeof(buffer)-1]; // allow 1 byte for null terminator
    buffer[bytesRead] = '\0'; // add null terminator (just in case - may not be used)
    
    if (bytesRead <= 0) { // && mutableData.length == 0
        // Do nothing; we'll handle EOF and error in the
        // NSStreamEventEndEncountered and NSStreamEventErrorOccurred case,
        // respectively.
    } else {
        // assume that we will receive partial messages
        if (mutableData == nil) {
            mutableData = [NSMutableData dataWithCapacity:1024]; // up to 1024 bytes for now
        }
        if (bytesRead >= 1) {
            // append the data we just received
            [mutableData appendBytes:buffer length:(NSUInteger)bytesRead]; // we know bytesRead > 0 because we checked earlier
        }
        [self processMutableData]; // (queue)
    }
}

- (void)processMutableData {
    
#define kTouchViewControllerTapItemCount 9
    
    const uint8_t *fullBuffer = mutableData.bytes;
    uint8_t b = (uint8_t)fullBuffer[0];
    
    // We received a remote tap update, forward it to the appropriate view
    if ( (b >= 'A') && (b < ('A' + kTouchViewControllerTapItemCount))) {
        NSUInteger item = b - 'A';
        NSLog(@"touch down on %lu", item);
        [self.touchViewController remoteTouchDownOnItem:item];
        
        // remove first byte
        [mutableData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
        
        if (mutableData.length > 0) {
            NSLog(@"Still more to process. Re-running...");
            [self processMutableData];
        }
    } else if ( (b >= 'a') && (b < ('a' + kTouchViewControllerTapItemCount))) {
        NSUInteger item = b - 'a';
        NSLog(@"touch up on %lu", item);
        
        [self.touchViewController remoteTouchUpOnItem:item];
        
        // remove first byte
        [mutableData replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
        
        if (mutableData.length > 0) {
            NSLog(@"Still more to process. Re-running...");
            [self processMutableData];
        }
    } else if ( b == 'Z' ) {
        // heartbeat request. see if we have at least 8 more bytes for the double
        
        if (mutableData.length >= 9) {
            
            CFTimeInterval timeInSeconds = 0;
            memcpy(&timeInSeconds, fullBuffer+1, sizeof timeInSeconds);
            
            NSLog(@"timeInSeconds = %lf", timeInSeconds);
            
            // send it back
            [self replyHeartbeat:timeInSeconds];
            
            // TODO: sanity check: make sure the double received is the same as the double sent
            
            // remove first 9 bytes
            [mutableData replaceBytesInRange:NSMakeRange(0, 9) withBytes:NULL length:0];
            
            if (mutableData.length > 0) {
                NSLog(@"Still more to process. Re-running...");
                [self processMutableData];
            }
        }
    } else if ( b == 'Y' ) {
        // heartbeat reply. see if we have at least 8 more bytes for the double
        
        if (mutableData.length >= 9) {
            
            CFTimeInterval timeInSeconds = 0;
            memcpy(&timeInSeconds, fullBuffer+1, sizeof timeInSeconds);
            
            NSLog(@"timeInSeconds = %lf", timeInSeconds);
            
            // successfully received heartbeat
            [self.touchViewController receiveHeartbeat:timeInSeconds];
            
            // TODO: sanity check: make sure the double received is the same as the double sent
            
            // remove first 9 bytes
            [mutableData replaceBytesInRange:NSMakeRange(0, 9) withBytes:NULL length:0];
            
            if (mutableData.length > 0) {
                NSLog(@"Still more to process. Re-running...");
                [self processMutableData];
            }
        }
        
        // TODO: let 'z' mean we're getting an arbitrary length string, and allow it to be up to 1024 characters long
        // up to the null terminator
        
    } else {
        // Ignore the bogus input.  This is important because it allows us
        // to telnet in to the app in order to test its behaviour.  telnet
        // sends all sorts of odd characters, so ignoring them is a good thing.
        NSLog(@"Note: Received bogus input");
    }
}

- (void)openStreams
{
    assert(self.inputStream != nil);            // streams must exist but aren't open
    assert(self.outputStream != nil);
    assert(self.streamOpenCount == 0);
    
    [self.inputStream  setDelegate:self];
    [self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream  open];
    
    [self.outputStream setDelegate:self];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

- (void)closeStreams
{
    assert( (self.inputStream != nil) == (self.outputStream != nil) );      // should either have both or neither
    if (self.inputStream != nil) {
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.inputStream close];
        self.inputStream = nil;
        
        [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream close];
        self.outputStream = nil;
    }
    self.streamOpenCount = 0;
}

// Send 1 byte
- (void)send:(uint8_t)message
{
    [self sendBuffer:&message maxLength:sizeof(message)];
}

// Send an arbitrary length buffer (array)
- (void)sendBuffer:(const uint8_t *)buffer maxLength:(NSUInteger)len {
    assert(self.streamOpenCount == 2); // crashes here if we have not yet connected to a peer
    
    // Only write to the stream if it has space available, otherwise we might block.
    // In a real app you have to handle this case properly but in this sample code it's
    // OK to ignore it; if the stream stops transferring data the user is going to have
    // to tap a lot before we fill up our stream buffer (-:
    
    if ( [self.outputStream hasSpaceAvailable] ) {
        NSInteger   bytesWritten;
        
        bytesWritten = [self.outputStream write:buffer maxLength:len];
        if (bytesWritten != (NSInteger)len) { // assume that len is not large
            NSLog(@"Error: Failed to write entire message");
            [self setupForNewGame];
        }
    }
}

- (void)touchViewController:(TouchViewController *)controller localTouchDownOnItem:(NSUInteger)tapItemIndex
{
    assert(controller == self.touchViewController);
    #pragma unused(controller)
    [self send:(uint8_t) (tapItemIndex + 'A')];
}

- (void)touchViewController:(TouchViewController *)controller localTouchUpOnItem:(NSUInteger)tapItemIndex
{
    assert(controller == self.touchViewController);
    #pragma unused(controller)
    [self send:(uint8_t) (tapItemIndex + 'a')];
}

- (void)touchViewControllerDidClose:(TouchViewController *)controller
{
    assert(controller == self.touchViewController);
    #pragma unused(controller)
    [self setupForNewGame];
}

- (void)requestHeartbeat:(CFTimeInterval)requestTime {
    // check that we've connected
    if (self.streamOpenCount == 2) {
        
        // TODO: send requestTime as bytes (most likely 8 bytes, a double)
        // uint8_t is 1 byte.
        //uint8_t * message = (uint8_t *) &requestTime;
        
        NSMutableData *data = [NSMutableData dataWithCapacity:9];
        char marker = 'Z';
        [data appendBytes:&marker length:sizeof(marker)];
        [data appendBytes:(uint8_t *) &requestTime length:sizeof(requestTime)];
        [self sendBuffer:data.bytes maxLength:data.length];
    }
}

- (void)replyHeartbeat:(CFTimeInterval)requestTime {
    // check that we've connected
    if (self.streamOpenCount == 2) {
        
        // TODO: send requestTime as bytes (most likely 8 bytes, a double)
        // uint8_t is 1 byte.
        //uint8_t * message = (uint8_t *) &requestTime;
        
        NSMutableData *data = [NSMutableData dataWithCapacity:9];
        char marker = 'Y';
        [data appendBytes:&marker length:sizeof(marker)];
        [data appendBytes:(uint8_t *) &requestTime length:sizeof(requestTime)];
        [self sendBuffer:data.bytes maxLength:data.length];
    }
}

#pragma mark - QServer delegate

- (void)netServiceDidPublish:(NSNetService *)sender
{
    assert(sender == self.server);
    #pragma unused(sender)

    self.registeredName = self.server.name;
    if (self.picker != nil) {
        // If our server wasn't started when we brought up the picker, we 
        // left the picker stopped (because without our service name it can't 
        // filter us out of its list).  In that case we have to start the picker 
        // now.
        
        [self startPicker];
    }
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    // Due to a bug <rdar://problem/15626440>, this method is called on some unspecified 
    // queue rather than the queue associated with the net service (which in this case 
    // is the main queue).  Work around this by bouncing to the main queue.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        assert(sender == self.server);
        #pragma unused(sender)
        assert(inputStream != nil);
        assert(outputStream != nil);

        assert( (self.inputStream != nil) == (self.outputStream != nil) );      // should either have both or neither
        
        if (self.inputStream != nil) {
            // We already have a game in place; reject this new one.
            [inputStream open];
            [inputStream close];
            [outputStream open];
            [outputStream close];
        } else {
            // Start up the new game.  Start by deregistering the server, to discourage 
            // other folks from connecting to us (and being disappointed when we reject 
            // the connection).

            [self.server stop];
            self.isServerStarted = NO;
            self.registeredName = nil;
            
            // Latch the input and output streams and kick off an open.
            
            self.inputStream  = inputStream;
            self.outputStream = outputStream;
            
            [self openStreams];
        }
    }];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
    // This is called when the server stops of its own accord.  The only reason 
    // that might happen is if the Bonjour registration fails when we reregister 
    // the server, and that's hard to trigger because we use auto-rename.  I've 
    // left an assert here so that, if this does happen, we can figure out why it 
    // happens and then decide how best to handle it.
{
    assert(sender == self.server);
    #pragma unused(sender)
    #pragma unused(errorDict)
    assert(NO);
}

@end
