//
//  ArchiveViewController.swift
//  Doutor Ao Vivo Demo
//
//  Created by Fabio Ohtsuki on 12/03/20.
//  Copyright © 2020 Prime IT Solutions. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

protocol archiveViewControllerDelegate {
    func closeFileList()
    func selectFileToSend()
    func selectFileAction(fileSharePath: String, fileShareName: String, filePublisherId: String)
}

public class ArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myDelegate:archiveViewControllerDelegate!
    
    public var listHeight:CGFloat?
    
    var filesTableView: UITableView = UITableView()
    var filesToolBar: UIToolbar?
    
    public var filesList : [FileShare] = [FileShare]()
    public var filesId = "fileId"
    
    public var davBackgroundVideoHeaderParticipant:UIColor? //#6D7BCCFB
    public var davTextColorVideoHeaderParticipant:UIColor? //#6D7BCCFB
    
    public var domainMedia:String = ""
    public var publisherId:String = ""
    public var publisherName:String = ""
    
    override public func viewDidAppear(_ animated: Bool) {
        let screenBounds = UIScreen.main.bounds
        self.view.frame = CGRect(x: 0, y: 0, width: CGFloat(screenBounds.width), height: listHeight!)
        //toolbar superior
        filesToolBar = UIToolbar()
        filesToolBar!.barStyle = UIBarStyle.default
        filesToolBar!.isTranslucent = true
        self.view.addSubview(filesToolBar!)
        filesToolBar!.translatesAutoresizingMaskIntoConstraints = false
        filesToolBar!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        filesToolBar!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        filesToolBar!.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        filesToolBar!.setItems([UIBarButtonItem(image: UIImage(named: "back", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(closeFiles)), UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), UIBarButtonItem(image: UIImage(named: "archive", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(sendFiles))], animated: true)
        filesToolBar!.tintColor = davTextColorVideoHeaderParticipant
        filesToolBar!.setBackgroundImage(self.onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        //Tableview Files
        filesTableView.delegate = self
        filesTableView.dataSource = self
        filesTableView.register(UITableViewCell.self, forCellReuseIdentifier: filesId)
        self.view.addSubview(filesTableView)
        filesTableView.translatesAutoresizingMaskIntoConstraints = false
        filesTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        filesTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        filesTableView.topAnchor.constraint(equalTo: filesToolBar!.bottomAnchor).isActive = true
        filesTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    @objc func closeFiles(sender: UIButton!) {
        self.myDelegate.closeFileList()
    }
    
    @objc func sendFiles(sender: UIButton!) {
        self.myDelegate.selectFileToSend()
    }
    
    @objc func selectAction(fileSharePath: String, fileShareName: String, filePublisherId: String) {
        self.myDelegate.selectFileAction(fileSharePath: fileSharePath, fileShareName: fileShareName, filePublisherId: filePublisherId)
    }
    
    // MARK: - Tableview - Files
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filesTableView.dequeueReusableCell(withIdentifier: filesId, for: indexPath) as UITableViewCell
        
        let currentLastItem = filesList[indexPath.row]
        
        for view in cell.contentView.subviews{
            view.removeFromSuperview()
        }
        
        var label:UILabel
        label = UILabel()
        label.sizeToFit()
        label.numberOfLines = 0
        label.frame = CGRect(x: 10.0, y: 0.0, width: self.view.frame.size.width - 10.0 , height: 30.0)
        label.text = currentLastItem.fileShareName
        label.tag = indexPath.row
        cell.contentView.addSubview(label)
        
        cell.contentView.sizeToFit()
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("You selected cell #\(filesList[indexPath.row])!")
        self.selectAction(fileSharePath: self.filesList[indexPath.row].fileSharePath, fileShareName: self.filesList[indexPath.row].fileShareName, filePublisherId: self.filesList[indexPath.row].fileShareParticipant)
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



