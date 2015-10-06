
import MultipeerConnectivity

class TVCClient: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    var availableServers: Array<String> // array of peerIDs
    
    var session: MCSession // ?
    
    //MCNearbyServiceBrowser ?
    
    override init() {
        availableServers = Array()
        
        // client mode? available?
        // MCPeerID: An internal number used to identify the different devices in the session.
        // Peers will get different IDs each time the game is run.
        session = MCSession(peer: MCPeerID(displayName: "Some Client Display Name")) // TODO: customize name
        
        super.init()
        
        session.delegate = self // ?
    }
    
    /// Start browsing with client session mode, set delegate to self, and set available to true
    func startSearchingForServers(sessionID: String) {
        // TODO
        
        // TODO: use sessionID
        // start browsing...
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    
    // Found a nearby advertising peer.
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("TVCClient: browser \(browser) found peer \(peerID) discoveryInfo \(info)")
    }
    
    // A nearby peer has stopped advertising.
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("TVCClient: browser \(browser) lostPeer \(peerID)")
    }
    
    // Browsing did not start due to an error.
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("TVCClient: browser \(browser) error \(error)")
    }
    
    // MARK: - MCSessionDelegate
    
    // Remote peer changed state.
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("TVCClient: peer \(peerID) changed state \(state)")
    }
    
    // Received data from remote peer.
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
    }
    
    // Received a byte stream from remote peer.
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    // Start receiving a resource from remote peer.
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    // optional
    // Made first contact with peer and have identity information about the
    // remote peer (certificate may be nil).
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        
    }
}
