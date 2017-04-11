import AppKit

class ContentViewController : NSViewController {
    
    var textField : NSTextField!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func loadView() {
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 280))
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 70))
        
        textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.focusRingType = .None
        view.addSubview(textField)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(20)-[searchField]-(20)-|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["searchField":textField]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[searchField(==30)]", options: NSLayoutFormatOptions(0), metrics: nil, views: ["searchField":textField]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear() {
        
        
        super.viewWillAppear()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTextChange:", name: NSControlTextDidEndEditingNotification, object: textField)
        self.textField.becomeFirstResponder()
        
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        self.textField.becomeFirstResponder()
    }
    
    
    override func viewDidDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSControlTextDidEndEditingNotification, object: nil)
        self.textField.stringValue = ""
    }
    func onTextChange(note : NSNotification) {
        var text = textField.stringValue
        if(self.textField.stringValue != ""){
            if let url = NSURL(string:self.textField.stringValue){
                println("sending")
                NetworkHandler.sharedInstance.sendURL(url)
            }
            
            //NSLog("Search for %@", text)
            self.textField.stringValue = ""
        }
        
    }
    
    
}