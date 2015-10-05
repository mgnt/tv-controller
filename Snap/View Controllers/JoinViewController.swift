
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
    
    deinit {
        print("deinit \(self)")
        waitView = nil // TODO: test
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
