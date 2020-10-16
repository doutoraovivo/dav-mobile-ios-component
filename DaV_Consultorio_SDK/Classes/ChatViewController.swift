//
//  ChatViewController.swift
//  Doutor Ao Vivo Demo
//
//  Created by Fabio Ohtsuki on 11/03/20.
//  Copyright © 2020 Prime IT Solutions. All rights reserved.
//

import Foundation
import UIKit

protocol chatViewControllerDelegate {
    func closeMsg()
    func saveMessageToServer()
}

public class ChatViewController: UIViewController{
    
    var myDelegate:chatViewControllerDelegate!
    
    var chatToolBar: UIToolbar?
    var chatMsgToolBar: UIToolbar?
    var chatMsgScrollView: UIScrollView?
    var txfChatMsg:UITextField?
    var buttonSendMsg:UIBarButtonItem?
    
    public var chatHeight:CGFloat?
    
    public var davBackgroundVideoHeaderParticipant:UIColor? //#6D7BCCFB
    public var davTextColorVideoHeaderParticipant:UIColor? //#6D7BCCFB
    public var davBackgroundBallonOtherColor:UIColor? //#7bccfb
    public var davTextColorBallonOther:UIColor? //#ffffff
    public var davBackgroundBallonMineColor:UIColor? //#1976d2
    public var davTextColorballonMine:UIColor? //#ffffff
    
    public var chatMessages : [ChatMessage] = [ChatMessage]()
    public var chatMsgId = "msgId"
    public var publisherId = ""
    
    override public func viewDidLoad() {
        let screenBounds = UIScreen.main.bounds
        self.view.frame = CGRect(x: 0, y: 0, width: CGFloat(screenBounds.width), height: chatHeight!)
        //toolbar superior
        chatToolBar = UIToolbar()
        chatToolBar!.barStyle = UIBarStyle.default
        chatToolBar!.isTranslucent = true
        self.view.addSubview(chatToolBar!)
        chatToolBar!.translatesAutoresizingMaskIntoConstraints = false
        chatToolBar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        chatToolBar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        chatToolBar!.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        chatToolBar!.setItems([UIBarButtonItem(image: UIImage(named: "back", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(closeMsg))], animated: true)
        chatToolBar!.tintColor = davTextColorVideoHeaderParticipant
        chatToolBar!.setBackgroundImage(self.onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        //toolbar inferior
        chatMsgToolBar = UIToolbar()
        chatMsgToolBar!.barStyle = UIBarStyle.default
        chatMsgToolBar!.isTranslucent = true
        self.view.addSubview(chatMsgToolBar!)
        chatMsgToolBar!.translatesAutoresizingMaskIntoConstraints = false
        chatMsgToolBar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        chatMsgToolBar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        chatMsgToolBar!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        let flexibleBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let txfWidth = Int(self.view.frame.width) - 80
        txfChatMsg = UITextField(frame: CGRect(x: 0,y: 0,width: txfWidth, height: 30))
        txfChatMsg?.backgroundColor = UIColor.white
        txfChatMsg?.placeholder = "Digite sua mensagem aqui"
        txfChatMsg?.borderStyle = UITextField.BorderStyle.roundedRect
        txfChatMsg?.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        txfChatMsg?.autocorrectionType = UITextAutocorrectionType.no
        txfChatMsg?.keyboardType = UIKeyboardType.default
        txfChatMsg?.returnKeyType = UIReturnKeyType.done
        txfChatMsg?.addTarget(nil, action:Selector(("firstResponderAction:")), for:.editingDidEndOnExit)
        chatMsgToolBar!.setItems([flexibleBarButton, UIBarButtonItem(customView: txfChatMsg!), flexibleBarButton, UIBarButtonItem(image: UIImage(named: "send", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(saveMessageToServer))], animated: true)
        //Scroll View
        chatMsgScrollView = UIScrollView()
        chatMsgScrollView?.backgroundColor = UIColor.white
        self.view.addSubview(chatMsgScrollView!)
        chatMsgScrollView!.translatesAutoresizingMaskIntoConstraints = false
        chatMsgScrollView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        chatMsgScrollView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        chatMsgScrollView!.topAnchor.constraint(equalTo: chatToolBar!.bottomAnchor).isActive = true
        chatMsgScrollView!.bottomAnchor.constraint(equalTo: chatMsgToolBar!.topAnchor).isActive = true
        chatMsgScrollView!.showsHorizontalScrollIndicator = false
        if (chatMessages.count > 0) {
            for chatMsg in chatMessages {
                self.addMessageToView(cellDate: chatMsg.chatMsgDate, cellParticipant: chatMsg.chatMsgParticipant, cellParticipantName: chatMsg.chatMsgParticipantName, cellMessage: chatMsg.chatMsgText)
            }
        }
    }
    
    public func addMessageToView(cellDate:String, cellParticipant:String, cellParticipantName:String, cellMessage:String) {
        let Dateformatter = DateFormatter()
        Dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let msgDate = Dateformatter.date(from: cellDate)
        Dateformatter.dateFormat = "HH:mm"
        let msgDateString = Dateformatter.string(from: msgDate!)
        var textMessage:String?
        textMessage = msgDateString + " - " + cellParticipantName + "\r\n\r\n" + cellMessage
        var lastIndex:Int = -1
        if (chatMsgScrollView!.subviews.count > 0) {
            for i in 0..<chatMsgScrollView!.subviews.count {
                if chatMsgScrollView!.subviews[i] is UITextView {
                    lastIndex = i
                }
            }
        }
        var leadingX:CGFloat?
        var trailingX:CGFloat?
        var chatboxBackgroundColor:UIColor?
        var chatboxTextColor:UIColor?
        if (self.publisherId == cellParticipant) {
            leadingX = 10.0
            trailingX = -40.0
            chatboxBackgroundColor = self.davBackgroundBallonMineColor
            chatboxTextColor = self.davTextColorballonMine
        } else {
            leadingX = 40.0
            trailingX = -10.0
            chatboxBackgroundColor = self.davBackgroundBallonOtherColor
            chatboxTextColor = self.davTextColorBallonOther
        }
        let chatMsgTextView:UITextView=UITextView()
        chatMsgTextView.layer.masksToBounds = true
        chatMsgTextView.layer.cornerRadius = 20.0
        chatMsgTextView.layer.borderWidth = 0
        chatMsgTextView.textColor = chatboxTextColor
        chatMsgTextView.backgroundColor = chatboxBackgroundColor
        chatMsgTextView.font = UIFont.systemFont(ofSize: 20.0)
        chatMsgTextView.textAlignment = NSTextAlignment.left
        chatMsgTextView.dataDetectorTypes = UIDataDetectorTypes.all
        chatMsgTextView.isScrollEnabled = false
        chatMsgTextView.isEditable = false
        chatMsgTextView.text = textMessage
        
        chatMsgScrollView!.addSubview(chatMsgTextView)
        
        chatMsgTextView.translatesAutoresizingMaskIntoConstraints = false
        
        if (lastIndex >= 0) {
            chatMsgTextView.topAnchor.constraint(equalTo: chatMsgScrollView!.subviews[lastIndex].bottomAnchor, constant: 10.0).isActive = true
        } else {
            chatMsgTextView.topAnchor.constraint(equalTo: chatMsgScrollView!.topAnchor, constant: 10.0).isActive = true
        }
        chatMsgTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: leadingX!).isActive = true
        chatMsgTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: trailingX!).isActive = true
        
        chatMsgScrollView!.didAddSubview(chatMsgTextView)
        
    }
    
    func resizeScrollView() {
        var contentRect = CGRect()
        var lastY:CGFloat = 0
        for view in chatMsgScrollView!.subviews {
            if view is UITextView {
                if (view.frame.origin.y > lastY) {
                    lastY = view.frame.origin.y + view.frame.height
                } else {
                    let txtView = view as! UITextView
                    let stringHeight = txtView.text.height(constraintedWidth: chatMsgScrollView!.frame.width - 50, font: UIFont.systemFont(ofSize: 20.0))
                    lastY = lastY + stringHeight + 30
                }
            }
        }
        contentRect.size.height = lastY + 10.0
        contentRect.size.width = chatMsgScrollView!.frame.width
        chatMsgScrollView!.contentSize = contentRect.size;
    }
    
    func scrollToBottom(animated: Bool) {
        if chatMsgScrollView!.contentSize.height < chatMsgScrollView!.bounds.size.height {
            return
        }
        let bottomOffset = CGPoint(x: 0, y: chatMsgScrollView!.contentSize.height - chatMsgScrollView!.bounds.size.height)
        chatMsgScrollView!.setContentOffset(bottomOffset, animated: animated)
    }
    
    @objc func saveMessageToServer(sender: UIButton!) {
        self.myDelegate.saveMessageToServer()
    }
    
    @objc func closeMsg(sender: UIButton!) {
        self.myDelegate.closeMsg()
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

extension String {
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()

        return label.frame.height
     }
}


