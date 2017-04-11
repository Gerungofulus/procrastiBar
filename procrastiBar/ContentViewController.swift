import AppKit

class ContentViewController : NSViewController {
    
    var textField : NSTextField!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 280))
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        
        textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.focusRingType = .none
        view.addSubview(textField)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(20)-[textField]-(20)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textField":textField]))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(20)-[textField(==30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["textField":textField]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ContentViewController.onEditEnd(_:)), name: NSNotification.Name.NSControlTextDidEndEditing, object: textField)
    }
    
    func onEditEnd(_ note : Notification) {
        let text = textField.stringValue
        if let url = URL(string: text){
            if let _ = NSImage(contentsOf: url){
                NetworkHandler.sharedInstance.sendURL(url)
            }
        }
    }
}
