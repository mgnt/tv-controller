
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
