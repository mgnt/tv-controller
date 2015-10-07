
import Foundation

class TVCServer: NSObject, NSNetServiceDelegate {
    
    var maxClients: Int
    var connectedClients: Array<String> // mutable
//    var session: MCSession // ?
    
    //MCNearbyServiceAdvertiser
    
    override init() {
        maxClients = 4 // TV + up to four players, for now
        connectedClients = Array()
//        session = MCSession(peer: MCPeerID(displayName: "Some Display Name")) // TODO
        
        super.init()
        
//        session.delegate = self // ?
    }
    
//    /// Broadcast availability of the service named by sessionID.
//    /// TODO
//    func startAcceptingConnections(sessionID: String) {
//        // TODO: customize name
//        // TODO: use sessionID
//        
////        session = MCSession(peer: MCPeerID(displayName: "Some Name")) // server mode? available?
////        session.delegate = self
//        
//        // TODO: start broadcasting
//    }
//    
//    // MARK: - MCNearbyServiceAdvertiserDelegate
//    
//    // Incoming invitation request.  Call the invitationHandler block with YES
//    // and a valid session to connect the inviting peer to the session.
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
