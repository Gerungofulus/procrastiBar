//
//  PictureViewController.swift
//  procastiBar
//
//  Created by Pascal Blunk on 07.09.15.
//  Copyright (c) 2015 Codingcave.de. All rights reserved.
//

import AppKit

class PictureViewController: NSViewController {

    var img:NSImage!
    var imageView:NSImageView!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 670))
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 500))
        
        imageView = NSImageView()
        
        imageView.image = img
        imageView.imageAlignment = NSImageAlignment.alignCenter
        imageView.imageScaling = NSImageScaling.scaleProportionallyDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[imageView(640)]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[imageView(480)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView":imageView]))

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    override func viewWillAppear(){
        super.viewWillAppear()
        self.imageView.image = img
    }
    
    
    
}
