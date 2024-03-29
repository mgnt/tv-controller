
import Foundation
import UIKit

// The Bonjour service type consists of an IANA service name (see RFC 6335)
// prefixed by an underscore (as per RFC 2782).
//
// <http://www.ietf.org/rfc/rfc6335.txt>
//
// <http://www.ietf.org/rfc/rfc2782.txt>
//
// See Section 5.1 of RFC 6335 for the specifics requirements.
//
// - MUST be at least 1 character and no more than 15 characters long
//
// To avoid conflicts, you must register your service type with IANA before
// shipping.
//
// To help network administrators identify your service, you should choose a
// service name that's reasonably human readable.

let kSnapBonjourType = "_snap._tcp." // TODO: make this settable by app


/// TVCServer has no UI and will provide a delegate protocol for client connection events
class TVCServer: NSObject, NSNetServiceDelegate, NSStreamDelegate {
    
    var maxClients: Int
    var connectedClients: Array<String> // mutable
    var server: NSNetService
    var isServerStarted = false
    var registeredName: String?
    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    
    // TODO: use a delegate pattern instead of referencing a view controller directly
    var picker: UIViewController? // PickerViewController
    
//    var session: MCSession // ?
    
    //MCNearbyServiceAdvertiser
    
    override init() {
        maxClients = 4 // TV + up to four players, for now
        connectedClients = Array()
//        session = MCSession(peer: MCPeerID(displayName: "Some Display Name")) // TODO
        
        // Create our server. We only want the service to be registered on
        // local networks so we pass in the "local." domain.
        self.server = NSNetService(domain: "local.", type: kSnapBonjourType, name: UIDevice.currentDevice().name, port: 0)
        self.server.includesPeerToPeer = true
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackgroundNotification:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForegroundNotification:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.server.delegate = self
        
//        session.delegate = self // ?
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// Broadcast availability of the service named by sessionID.
    func startAcceptingConnections(sessionID: String) {
        
        // Advertise our server (start broadcasting).
        self.server.publishWithOptions(NSNetServiceOptions.ListenForConnections)
        self.isServerStarted = true // TODO: what's this used for?
        
        // TODO: use sessionID (or remove the sessionID parameter)
        // TODO: remove session
        
        // TODO:
        // Set up for a new game, which presents a Bonjour browser that displays other
        // available games.
    }
    
    func applicationDidEnterBackgroundNotification(notification: NSNotification) {
        
        // If there's a game playing, shut it down.  Whether this is the right thing to do
        // depends on your app.  In some cases it might be more sensible to leave the connection
        // in place for a short while to see if the user comes back to the app.  This issue is
        // discussed in more depth in Technote 2277 "Networking and Multitasking".
        //
        // <https://developer.apple.com/library/ios/#technotes/tn2277/_index.html>
        
        if (inputStream != nil) {
            // TODO: setup for new game (shut down previous game)
//            [self setupForNewGame];
        }
        
        // Quiesce the server and service browser, if any.
        
        server.stop()
        isServerStarted = false
        registeredName = nil // Note that registeredName can vary depending on whether there are name conflicts
        if (picker != nil) {
            // TODO: use a delegat pattern instead of using a view controller directly
//            picker.stop()
        }
    }
    
    func applicationWillEnterForegroundNotification(notification: NSNotification) {
        
        // Quicken the server.  Once this is done it will quicken the picker, if there's one up.
        
        assert( isServerStarted == false )
        
        server.publishWithOptions(NSNetServiceOptions.ListenForConnections)
        isServerStarted = true
        if (registeredName != nil) {
//            self.startPicker()
        }
    }
    
    // TODO: use delegate
    // 1. Reset game state e.g. touchViewController.resetTouches()
    func setupForNewGame()
    {
        // If there's a connection, shut it down.
//        closeStreams()
        
        // If our server is deregistered, reregister it.
        if isServerStarted == false {
            server.publishWithOptions(.ListenForConnections)
            isServerStarted = true
        }
        
        // And show the service picker.
//        presentPicker()
    }
    
    // MARK: - Picker management
    // TODO: use delegate
    
    func startPicker() {
        assert(registeredName != nil)
        
        // Tell the picker about our registration. It uses this to
        // a) filter out our game from the results, and
        // b) display our game name in its table view header.
//        picker.localService = self.server
        
        // Start it up.
//        picker.start()
    }
    
    func presentPicker() {
        if self.picker != nil {
            // If the picker is already on-screen then we're here because of a connection failure.
            // In that case, we just cancel the picker's connection UI and the user can choose another service.
//            picker.cancelConnect()
        } else {
            // Create the service picker and put it up on screen. We only start the picker
            // if our server has completed its registration (the picker needs to know our
            // service name so that it can exclude us from the list). If that's not the
            // case then the picker remains stopped until serverDidStart: runs.
            
            // In the TVC architecture, the tvOS device always advertises and the
            // iOS device always browses, so we can start the server sooner: we won't have
            // a service name because we're only browsing.
            
//            picker = touchViewController.storyboard.instantiateViewController(identifier: "picker")
//            assert(picker is PickerViewController)
//            picker.type = kSnapBonjourType
//            picker.delegate = self
            if self.registeredName != nil {
                startPicker()
            }
            
//            touchViewController.presentViewController(picker, animated: false, completion: nil)
        }
    }
    
    func dismissPicker() {
        assert(picker != nil)
        
//        touchViewController.dismissViewController(animated: false, completion: nil)
//        picker.stop()
        picker = nil
    }
    
    // TODO: move to TVCClient
    // Called by the delegate when the user has chosen a service for us to connect to.
    // The delegate is already displaying its connection-in-progress UI.
    func connectToService(service: NSNetService) {
        var success = false
        var inStream: NSInputStream?
        var outStream: NSOutputStream?
        
        // Create and open streams for the service.
        //
        // getInputStream:outputStream: just creates the streams, it doesn't hit the
        // network, and thus it shouldn't fail under normal circumstances (in fact, its
        // CFNetService equivalent, CFStreamCreatePairWithSocketToNetService, returns no status
        // at all). So, I didn't spend much time worrying about the error case here. If
        // we do get an error, you end up staying in the picker. OTOH, actual connection errors
        // get handled via the NSNetStreamEventOccurred event.
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    
    // Incoming invitation request.  Call the invitationHandler block with YES
    // and a valid session to connect the inviting peer to the session.
//    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void)
//    {
//        print("TVCServer: connection request from peer \(peerID)")
//    }
//    
//    // Advertising did not start due to an error.
//    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
//        print("TVCServer: advertising did not start due to error \(error)")
//    }
//    
//    // MARK: - MCSessionDelegate
//    
//    // Remote peer changed state.
//    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
//        print("TVCServer: peer \(peerID) changed state \(state)")
//    }
//    
//    // Received data from remote peer.
//    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
//        
//    }
//    
//    // Received a byte stream from remote peer.
//    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
//        
//    }
//    
//    // Start receiving a resource from remote peer.
//    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
//        
//    }
//    
//    // Finished receiving a resource from remote peer and saved the content
//    // in a temporary location - the app is responsible for moving the file
//    // to a permanent location within its sandbox.
//    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
//        
//    }
//    
//    // optional
//    // Made first contact with peer and have identity information about the
//    // remote peer (certificate may be nil).
//    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
//        
//    }
}
