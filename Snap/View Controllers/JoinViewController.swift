
import UIKit

@objc protocol JoinViewControllerDelegate {
    
    func joinViewControllerDidCancel(controller: JoinViewController)
}

class JoinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var delegate: JoinViewControllerDelegate?
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UILabel!
    
    @IBOutlet var waitView: UILabel! // strong by default
    @IBOutlet weak var waitLabel: UILabel!
    
    var client: TVCClient
    
    deinit {
        print("deinit \(self)")
        waitView = nil // TODO: test
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        client = TVCClient()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        client.startSearchingForServers("Some Session ID") // ?
    }
    
    required init?(coder aDecoder: NSCoder) {
        client = TVCClient()
        super.init(coder: aDecoder)
        
        client.startSearchingForServers("Some Session ID") // ?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.placeholder = "Some client display name" // client.session.displayName
        
        self.headingLabel.font = UIFont.tvc_snapFont(24.0)
        self.nameLabel.font = UIFont.tvc_snapFont(16.0)
        self.statusLabel.font = UIFont.tvc_snapFont(16.0)
        self.waitLabel.font = UIFont.tvc_snapFont(18.0)
        self.nameTextField.font = UIFont.tvc_snapFont(20.0)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self.nameTextField, action: "resignFirstResponder")
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    @IBAction func exitAction(sender: UIButton) {
        delegate?.joinViewControllerDidCancel(self)
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
}
