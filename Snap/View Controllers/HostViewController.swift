
import UIKit

@objc protocol HostViewControllerDelegate {
    
    func hostViewControllerDidCancel(controller: HostViewController)
}

class HostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    var delegate: HostViewControllerDelegate?
    
    var server: TVCServer
    
    func setup() {
        server.maxClients = 4 // TV + 4 players
        server.startAcceptingConnections("Some Session ID") // TODO: set sessionID
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        server = TVCServer()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        server = TVCServer()
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.placeholder = "Some Display Name" // session.displayName
        self.tableView.reloadData() // TODO: may not be necessary
        
        self.headingLabel.font = UIFont.tvc_snapFont(24.0)
        self.nameLabel.font = UIFont.tvc_snapFont(16.0)
        self.statusLabel.font = UIFont.tvc_snapFont(16.0)
        self.nameTextField.font = UIFont.tvc_snapFont(20.0)
        
        self.startButton.tvc_applySnapStyle()
        
        let gestureRecognizer = UITapGestureRecognizer(target: nameTextField, action: "resignFirstResponder")
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    @IBAction func startAction(sender: UIButton) {
    }
    
    @IBAction func exitAction(sender: UIButton) {
        delegate?.hostViewControllerDidCancel(self)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    deinit {
        print("dealloc \(self)")
    }
}
