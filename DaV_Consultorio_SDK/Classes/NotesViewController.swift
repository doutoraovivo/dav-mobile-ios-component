//
//  NotesViewController.swift
//  Doutor Ao Vivo Demo
//
//  Created by Fabio Ohtsuki on 19/03/20.
//  Copyright © 2020 Prime IT Solutions. All rights reserved.
//

import Foundation
import UIKit

protocol notesViewControllerDelegate {
    func closeNotesView()
    func saveNotesToServer()
}

public class NotesViewController: UIViewController {
    
    var myDelegate:notesViewControllerDelegate!
    var notesToolBar: UIToolbar?
    var txfChatMsg:UITextView?
    
    public var listHeight:CGFloat?
    public var publisherRole:String = ""
    public var davBackgroundVideoHeaderParticipant:UIColor? //#6D7BCCFB
    public var davTextColorVideoHeaderParticipant:UIColor? //#6D7BCCFB
    
    override public func viewDidLoad() {
        let screenBounds = UIScreen.main.bounds
        self.view.frame = CGRect(x: 0, y: 0, width: CGFloat(screenBounds.width), height: listHeight!)
        //toolbar superior
        notesToolBar = UIToolbar()
        notesToolBar!.barStyle = UIBarStyle.default
        notesToolBar!.isTranslucent = true
        self.view.addSubview(notesToolBar!)
        notesToolBar!.translatesAutoresizingMaskIntoConstraints = false
        notesToolBar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        notesToolBar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        notesToolBar!.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        notesToolBar!.setItems([UIBarButtonItem(image: UIImage(named: "back", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(closeNotes))], animated: true)
        notesToolBar!.tintColor = davTextColorVideoHeaderParticipant
        notesToolBar!.setBackgroundImage(self.onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        //Text field
        txfChatMsg = UITextView()
        txfChatMsg!.layer.cornerRadius = 10.0
        txfChatMsg!.layer.borderWidth = 1
        txfChatMsg!.layer.borderColor = UIColor.lightGray.cgColor
        txfChatMsg?.keyboardType = UIKeyboardType.default
        txfChatMsg!.backgroundColor = .white
        txfChatMsg!.textColor = .darkGray
        if (self.publisherRole == "MMD") {
            txfChatMsg!.isEditable = true
        } else {
            txfChatMsg!.isEditable = false
        }
        self.view.addSubview(txfChatMsg!)
        txfChatMsg!.translatesAutoresizingMaskIntoConstraints = false
        txfChatMsg!.topAnchor.constraint(equalTo: notesToolBar!.bottomAnchor, constant: 20.0).isActive = true
        txfChatMsg!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        txfChatMsg!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0).isActive = true
        txfChatMsg!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20.0).isActive = true
    }
    
    @objc func closeNotes(sender: UIButton!) {
        self.myDelegate.saveNotesToServer()
        self.myDelegate.closeNotesView()
    }
    
    // MARK: - Alpha Background
    public func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(x:0,y: 0, width: 1, height:1))
        let image = UIImage(cgImage: context!.makeImage()!)
        return image
    }
}


