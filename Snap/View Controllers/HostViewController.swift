
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
