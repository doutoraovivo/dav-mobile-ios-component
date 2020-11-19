//
//  OpenTokViewController.swift
//  Doutor Ao Vivo Demo
//
//  Created by Prime IT Solutions on 16/01/20.
//  Copyright © 2020 Prime IT Solutions. All rights reserved.
//
import Foundation
import UIKit
import OpenTok
import Sentry

// Replace with your OpenTok API key
var kApiKey:String = ""

//Mensagem
public struct ChatMessage {
    var chatMsgDate:String
    var chatMsgText:String
    var chatMsgParticipant:String
    var chatMsgParticipantName:String
}

//Arquivos
public struct FileShare {
    var fileShareDate:String
    var fileShareEncoded:String
    var fileSharePath:String
    var fileShareName:String
    var fileShareParticipant:String
}

public class DavViewController: UIViewController, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate, chatViewControllerDelegate, archiveViewControllerDelegate, notesViewControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate {
        
    //variáveis gerais
    var alertMsg:String = ""
    var timer = Timer()
    public var DAV_URL_ACCESS:String=""
    var X_API_ID:String=Bundle.main.bundleIdentifier!
    var accessRoomKey:String=""
    var appointmentId:String=""
    var authRoomParticipant:String=""
    var roomParticipants:Array<Any>?
    var roomChatMsg:Array<Any>?
    var roomFiles:Array<Any>?
    var appointmentJson:Any?
    var kSessionId:String = ""
    var kToken:String = ""
    var publisherRole:String = ""
    var publisherId:String=""
    var sessionInit:String?
    var statusAppointment:String?
    
    static var defaultBundle:Bundle?
    
    //cores personalizadas
    public var davColorPrimary:UIColor? = UIColor(red: 0.10, green: 0.46, blue: 0.82, alpha: 1.00) // #1976d2
    public var davBackgroundActionsRoom:UIColor? = UIColor(red: 0.43, green: 0.48, blue: 0.80, alpha: 1.00) // #6D7BCCFB
    public var davBackgroundVideoHeaderParticipant:UIColor? = UIColor(red: 0.43, green: 0.48, blue: 0.80, alpha: 1.00) // #6D7BCCFB
    public var davTextColorVideoHeaderParticipant:UIColor? = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00) // #FFFFFF
    public var davTextColorButtonActionsRoom:UIColor? = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00) // #FFFFFF
    public var davBackgroundButtonEndCallActionsRoom:UIColor? = UIColor(red: 1.00, green: 0.02, blue: 0.04, alpha: 1.00) // #FF050A
    public var davBackgroundButtonActionsRoom:UIColor? = UIColor(red: 0.10, green: 0.46, blue: 0.82, alpha: 1.00) // #1976d2
    public var davBackgroundBallonOtherColor:UIColor? = UIColor(red: 0.48, green: 0.80, blue: 0.98, alpha: 1.00) // #7bccfb
    public var davTextColorBallonOther:UIColor? = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00) // #FFFFFF
    public var davBackgroundBallonMineColor:UIColor? = UIColor(red: 0.10, green: 0.46, blue: 0.82, alpha: 1.00) // #1976d2
    public var davTextColorballonMine:UIColor? = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00) // #FFFFFF
    
    //domínios e API keys
    var domain:String = ""
    let domainDev:String = "https://mobile.dev.doutoraovivo.com.br"
    let domainHom:String = "https://mobile.hom.doutoraovivo.com.br"
    let domainProd:String = "https://mobile.doutoraovivo.com.br"
    var domainMedia:String = ""
    let domainMediaDev:String = "https://media.dev.doutoraovivo.com.br"
    let domainMediaHom:String = "https://media.hom.doutoraovivo.com.br"
    let domainMediaProd:String = "https://media.doutoraovivo.com.br"
    let apiKeyDev:String = "46302052"
    let apiKeyHom:String = "46495482"
    let apiKeyProd:String = "46401552"
    let urlSendFile:String = "/appointment/file?id="
    let urlDeleteFile:String = "/appointment/file?id="
    let urlSaveNote:String = "/appointment/notes?id="
    let urlSaveMessage:String = "/appointment/message?id="
    let urlRecordStart:String = "/appointment/record/start?id="
    let urlRecordStop:String = "/appointment/record/stop?id="
    let urlAcomplish:String = "/appointment/accomplish?id="
    
    //criação da session
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    var subscriber2: OTSubscriber?
    var subscriber3: OTSubscriber?
    public var publisherView: UIView?
    public var subscriberView: UIView?
    public var subscriberView2: UIView?
    public var subscriberView3: UIView?
    var waitingView: UIView?
    var menuView: UIView?
    var chatView: UIView?
    var fileListView: UIView?
    var notesView: UIView?
    var chatController: ChatViewController?
    var archiveController: ArchiveViewController?
    var notesController: NotesViewController?
    var navBar: UIToolbar?
    var tbButtons: UIToolbar?
    var publisherToolBar: UIToolbar?
    var subscriberToolBar: UIToolbar?
    var subscriberToolBar2: UIToolbar?
    var subscriberToolBar3: UIToolbar?
    var publisherName:String=""
    var subscriberName:String=""
    var subscriberName2:String=""
    var subscriberName3:String=""
    var subscriberRole:String = ""
    var subscriberRole2:String = ""
    var subscriberRole3:String = ""
    public var waitingMessage = ""
    
    //variáveis de configuração
    public var showButtonVideo:Bool=true
    public var showButtonMicPub:Bool=true
    public var showButtonMicSub:Bool=true
    public var showButtonMicSub2:Bool=true
    public var showButtonMicSub3:Bool=true
    public var showButtonRecord:Bool=true
    public var showButtonMenu:Bool=true
    public var showButtonSnapshot:Bool=true
    public var showButtonFiles:Bool=true
    public var showButtonClose:Bool=true
    public var showButtonMsg:Bool=true
    public var showButtonNotes:Bool=true
    public var showButtonFlip:Bool=true
    
    //objetos criados e  runtime
    var vSpinner : UIView?
    var items = [UIBarButtonItem]()
    var itemsPub = [UIBarButtonItem]()
    var itemsSub = [UIBarButtonItem]()
    var itemsSub2 = [UIBarButtonItem]()
    var itemsSub3 = [UIBarButtonItem]()
    var timerLabel:UIBarButtonItem?
    var buttonMic:UIBarButtonItem?
    var buttonCam:UIBarButtonItem?
    var buttonMicSub:UIBarButtonItem?
    var buttonMicSub2:UIBarButtonItem?
    var buttonMicSub3:UIBarButtonItem?
    var buttonPrintSub:UIBarButtonItem?
    var buttonPrintSub2:UIBarButtonItem?
    var buttonPrintSub3:UIBarButtonItem?
    var buttonShare:UIBarButtonItem?
    var buttonBack:UIBarButtonItem?
    var buttonClose:UIBarButtonItem?
    var buttonMsg:UIBarButtonItem?
    var buttonRecord:UIBarButtonItem?
    var buttonMenu:UIBarButtonItem?
    var buttonFlip:UIButton?
    var buttonArchive:UIButton?
    var buttonPrint:UIButton?
    var buttonNotes:UIButton?
    var tapPubView:UITapGestureRecognizer?
    var tapSubView:UITapGestureRecognizer?
    var tapSub2View:UITapGestureRecognizer?
    var tapSub3View:UITapGestureRecognizer?
    
    //posições das views
    var pubViewPos:Int?
    var subViewPos:Int?
    var subViewPos2:Int?
    var subViewPos3:Int?
    //0: main
    //1: right
    //2: middle
    //3: left
    
    var chatMessages : [ChatMessage] = [ChatMessage]()
    var fileShareList : [FileShare] = [FileShare]()
    var notesSaved:String=""
    var recordId:String=""

    private func connectionError() {
                
        let alert = UIAlertController(title: "Erro de Conexão", message: "Não foi possível se conectar aos servidores. Gostaria de tentar novamente?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Não", style: .default, handler: { action in
            self.closeSala()
            self.closeView()
        }))
        
        alert.addAction(UIAlertAction(title: "Sim", style: .cancel, handler: { action in
            self.connectToAnOpenTokSession()
        }))

        self.present(alert, animated: true)
    }
    
    public func sessionDidBeginReconnecting(_ session: OTSession) {
    }
    
    public static var getBundle: Bundle {
        if (DavViewController.defaultBundle == nil) {
            let bundle = Bundle(for: DavViewController.self)
            DavViewController.defaultBundle = Bundle(url: bundle.url(forResource: "Assets", withExtension: "bundle")!)
        }
        return DavViewController.defaultBundle!
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        print("bundle: \(DavViewController.getBundle)")
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable");

        SentrySDK.start { options in
            options.dsn = "https://6d7482976fa84c84b4193203f9fd1564@o412232.ingest.sentry.io/5294139"
            options.debug = true // Enabled debug when first installing is always helpful
            options.environment = Bundle.main.bundleIdentifier
            options.enableAutoSessionTracking = true
        }

        let crumb = Breadcrumb()
        crumb.level = SentryLevel.info
        crumb.category = "url"
        crumb.message = self.DAV_URL_ACCESS
        
        SentrySDK.addBreadcrumb(crumb: crumb)
        
        //observer for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        //Navitem
        self.navigationItem.leftItemsSupplementBackButton = true
        self.view.backgroundColor = davColorPrimary
        //toolbar de comandos
        tbButtons = UIToolbar()
        tbButtons!.barStyle = UIBarStyle.default
        tbButtons!.isTranslucent = true
        tbButtons!.setBackgroundImage(onePixelImageWithColor(color: davBackgroundActionsRoom!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        view.addSubview(tbButtons!)
        tbButtons!.tintColor = davTextColorButtonActionsRoom
        tbButtons!.translatesAutoresizingMaskIntoConstraints = false
        tbButtons!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbButtons!.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbButtons!.bottomAnchor.constraint(equalTo:  bottomLayoutGuide.topAnchor).isActive = true
        buttonBack = UIBarButtonItem(image: UIImage(named: "back", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(closeView))
        items.append(buttonBack!)
        tbButtons!.setItems(items, animated: true)
        //connectToAnOpenTokSession()
        if (X_API_ID.count == 0) { X_API_ID = "0" } //excluir esta linha após a implementação do x-api-id
        if DAV_URL_ACCESS.contains(".dev.") {
            domain = domainDev
            domainMedia = domainMediaDev
            kApiKey = apiKeyDev
        } else if DAV_URL_ACCESS.contains(".hom.") {
            domain = domainHom
            domainMedia = domainMediaHom
            kApiKey = apiKeyHom
        } else {
            domain = domainProd
            domainMedia = domainMediaProd
            kApiKey = apiKeyProd
        }
        self.iniciaSala()
    }
    
    // MARK: - Basic Functions
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            self.closeView()
        }
    }
        
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        resizeView(0, size)
        resizeView(1, size)
        resizeView(2, size)
        resizeView(3, size)
        resizeChat(size)
        resizeFileList(size)
        resizeNotes(size)
        resizeMenu(size)
    }
    
    @objc func rotated() {
        if (chatView != nil) {
            if (chatView!.isHidden == false) {
                self.chatController!.resizeScrollView()
                self.chatController!.scrollToBottom(animated: true)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                //self.view.insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                let newsize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - keyboardSize.height + tbButtons!.frame.height)
                resizeChat(newsize)
                resizeMenu(newsize)
            }
    }

    @objc func keyboardWillHide(_ notification:Notification) {

        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
                //view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                //let newsize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                resizeChat(UIScreen.main.bounds.size)
                resizeMenu(UIScreen.main.bounds.size)
            }
    }

    @IBAction func showAlert(_ sender: Any){
        var alertTitle:String="Consultório"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }
        let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func showAlertClose(_ sender: Any){
        var alertTitle:String="Doutor Ao Vivo"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }
        let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in self.closeView() }))
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func showAlertAuto(_ sender: Any, dismissTime: Int){
        var alertTitle:String="Doutor Ao Vivo"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }
        var secondsToDismiss:Int=dismissTime
        if (dismissTime == 0) {
            secondsToDismiss = 3
        }
        let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        present(alertController, animated: true, completion: nil)
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + DispatchTimeInterval.seconds(secondsToDismiss)
        DispatchQueue.main.asyncAfter(deadline: when){
          // your code with delay
          alertController .dismiss(animated: true, completion: nil)
        }
    }
    
    func showSpinner(onView : UIView) {
        let spinnerHeight = Int(onView.bounds.height) - 44
        let spinnerView = UIView.init(frame: CGRect(x: 0, y: 0, width: Int(onView.bounds.width), height: spinnerHeight))
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
    
    func iniciaSala() {
        if (X_API_ID.count > 0){
            if (DAV_URL_ACCESS.count > 0) {
                let urlElem = DAV_URL_ACCESS.components(separatedBy: "/") as Array<Any>
                self.accessRoomKey = urlElem.last as! String
                if (accessRoomKey.count > 0) {
                    self.accessRoom()
                } else {
                    alertMsg = "URL inválida"
                    showAlertClose(self)
                }
            } else {
                alertMsg = "Informe o endereço do Access Room"
                showAlertClose(self)
            }
        } else {
            alertMsg = "Informe a API Key"
            showAlertClose(self)
        }
    }
    
    // MARK: - Connection Functions
    
    func accessRoom() {
        self.showSpinner(onView: self.view)
        var request = URLRequest(url: URL(string: domain + "/appointment/accessroom?access=" + accessRoomKey)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else
            {
                self.removeSpinner()
                self.alertMsg="Erro ao conectar. Tente novamente"
                self.showAlertClose(self)
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    if (json["appointmentId"] != nil) {
                        self.appointmentId = json["appointmentId"] as! String
                        self.authRoomParticipant = json["x-auth-room-participant"] as! String
                        if (self.appointmentId.count > 0 && self.authRoomParticipant.count > 0) {
                            self.checkIn()
                        } else {
                            self.removeSpinner()
                            self.alertMsg="Erro ao carregar dados da consulta"
                            self.showAlertClose(self)
                        }
                    } else {
                        self.removeSpinner()
                        if (json["code"] != nil && json["message"] != nil) {
                            let errorCode = json["code"] as! NSNumber
                            let errorMsg:String = json["message"] as! String
                            if (errorCode.stringValue == "422") {
                                self.alertMsg=errorMsg + "\nVerifique o link digitado, ou o atendimento foi finalizado."
                            } else {
                                self.alertMsg="Erro " + errorCode.stringValue + ": " + errorMsg
                            }
                        } else {
                            self.alertMsg="Erro ao carregar dados da consulta"
                        }
                        self.showAlertClose(self)
                    }
                } catch {
                    self.removeSpinner()
                    self.alertMsg="Erro ao carregar dados da consulta"
                    self.showAlertClose(self)
                }
            }
        })
        task.resume()
    }
    
    func checkIn() {
        var request = URLRequest(url: URL(string: domain + "/appointment/checkin?id=" + appointmentId)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                self.removeSpinner()
                self.alertMsg="Erro ao fazer Check-in"
                self.showAlertClose(self)
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    self.appointmentJson = json
                    if (json["participants"] != nil && json["session"] != nil) {
                        self.roomParticipants = json["participants"] as? Array<Any>
                        self.kSessionId = json["session"] as! String
                        self.statusAppointment = json["status_appointment"] as? String
                        self.sessionInit = json["date_start_attendance"] as? String
                        for participant in self.roomParticipants! {
                            let participantObj  = participant as? Dictionary<String, AnyObject>
                            if (participantObj!["token"] != nil) {
                                self.kToken = participantObj!["token"] as! String
                                self.publisherName = participantObj!["name"] as! String
                                self.publisherId = participantObj!["id"] as! String
                                let roleObj = participantObj!["role"] as? Dictionary<String, AnyObject>
                                if (roleObj!["code"] != nil) {
                                    self.publisherRole = roleObj!["code"] as! String
                                }
                            }
                        }
                        if (self.kToken.count > 0) {
                            //chat messages
                            if (json["messages"] != nil) {
                                self.roomChatMsg = json["messages"] as? Array<Any>
                                self.fecthMessages()
                            }
                            //files list
                            if (json["files"] != nil) {
                                self.roomFiles = json["files"] as? Array<Any>
                                self.fetchFiles()
                            }
                            //notes
                            if (json["notes"] != nil) {
                                self.notesSaved = json["notes"] as! String
                            }
                            //conecta com a session
                            self.connectToAnOpenTokSession()
                        } else {
                            self.removeSpinner()
                            self.alertMsg="Erro ao autenticar consulta. Token inválido"
                            self.showAlertClose(self)
                        }
                    } else {
                        self.removeSpinner()
                        if (json["code"] != nil && json["message"] != nil) {
                            let errorCode = json["code"] as! NSNumber
                            let errorMsg:String = json["message"] as! String
                            if (errorCode.stringValue == "422") {
                                self.alertMsg=errorMsg + "\nVerifique o link digitado, ou o atendimento foi finalizado."
                            } else {
                                self.alertMsg="Erro " + errorCode.stringValue + ": " + errorMsg
                            }
                        } else {
                            self.alertMsg="Erro ao obter resposta do servidor"
                        }
                        self.showAlertClose(self)
                    }
                } catch {
                    self.removeSpinner()
                    self.alertMsg="Erro ao carregar dados da consulta"
                    self.showAlertClose(self)
                }
            }
        })
        task.resume()
    }

    func connectToAnOpenTokSession() {
        print("connectToAnOpenTokSession")
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: kToken, error: &error)
        if error != nil {
            
            DispatchQueue.main.async {
                print("Connecting to An OpenTok Session \(error!)")
                self.removeSpinner()
                self.alertMsg = error!.description
                self.showAlertClose(self)
            }
        }
    }
    
    func fecthMessages() {
        for chatMsg in self.roomChatMsg! {
            let chatMsgObj = chatMsg as? Dictionary<String, AnyObject>
            var cellDate:String=""
            if (chatMsgObj!["date"] != nil) {
                cellDate=chatMsgObj!["date"] as! String
            }
            var cellMessage:String=""
            if (chatMsgObj!["message"] != nil) {
                cellMessage=chatMsgObj!["message"] as! String
            }
            var cellParticipant:String=""
            if (chatMsgObj!["participant"] != nil) {
                cellParticipant=chatMsgObj!["participant"] as! String
            }
            var cellParticipantName:String=""
            if (chatMsgObj!["participantName"] != nil) {
                cellParticipantName=chatMsgObj!["participantName"] as! String
            }
            self.chatMessages.append(ChatMessage(chatMsgDate: cellDate, chatMsgText: cellMessage, chatMsgParticipant: cellParticipant, chatMsgParticipantName: cellParticipantName))
        }
    }
    
    func fetchFiles() {
        for roomFile in self.roomFiles! {
            let roomFileObj = roomFile as? Dictionary<String, AnyObject>
            var fileDate:String=""
            if (roomFileObj!["date"] != nil) {
                fileDate=roomFileObj!["date"] as! String
            }
            var fileEncoded:String=""
            if (roomFileObj!["encoded"] != nil) {
                fileEncoded=roomFileObj!["encoded"] as! String
            }
            var filePath:String=""
            if (roomFileObj!["filePath"] != nil) {
                filePath=roomFileObj!["filePath"] as! String
            }
            var fileName:String=""
            if (roomFileObj!["nameOriginal"] != nil) {
                fileName=roomFileObj!["nameOriginal"] as! String
            }
            var fileParticipant:String=""
            if (roomFileObj!["participant"] != nil) {
                fileParticipant=roomFileObj!["participant"] as! String
            }
            self.fileShareList.append(FileShare(fileShareDate: fileDate, fileShareEncoded: fileEncoded, fileSharePath: filePath, fileShareName: fileName, fileShareParticipant: fileParticipant))
        }
    }

    
    func closePublisher(_pubView: inout UIView?, _pub: inout OTPublisher?) {
        var error: OTError?
        session!.unpublish(_pub!, error: &error)
        _pubView!.removeFromSuperview()
        _pub!.publishVideo = false
        _pub!.publishAudio = false
        
        //
        _pubView = nil;
        _pub = nil;
    }
    
    func closeSubscriber(_subView: inout UIView?, _sub: inout OTSubscriber?) {
        var error: OTError?
        session!.unsubscribe(_sub!, error: &error)
        _subView!.removeFromSuperview()
        _sub!.subscribeToVideo = false
        _sub!.subscribeToAudio = false
        
        //
        _subView = nil
        _sub = nil
    }
    
    func closeSala() {
//        var error: OTError? // TODO Passando o trator
        if (publisher != nil) {
            closePublisher(_pubView: &publisherView, _pub: &publisher)
//            session!.unpublish(publisher!, error: &error)
//            publisherView?.removeFromSuperview()
//            publisherView = nil
//            publisher = nil
//            publisher?.publishVideo = false
//            publisher?.publishAudio = false
        }
        if (subscriber != nil) {
            closeSubscriber(_subView: &subscriberView, _sub: &subscriber)
//            session!.unsubscribe(subscriber!, error: &error)
//            subscriberView?.removeFromSuperview()
//            subscriberView = nil
//            subscriber = nil
//            subscriber?.subscribeToVideo = false
//            subscriber?.subscribeToAudio = false
        }
        if (subscriber2 != nil) {
            closeSubscriber(_subView: &subscriberView2, _sub: &subscriber2)
//            session!.unsubscribe(subscriber2!, error: &error)
//            subscriberView2?.removeFromSuperview()
//            subscriberView2 = nil
//            subscriber2 = nil
//            subscriber2?.subscribeToVideo = false
//            subscriber2?.subscribeToAudio = false
        }
        if (subscriber3 != nil) {
            closeSubscriber(_subView: &subscriberView3, _sub: &subscriber3)
//            session!.unsubscribe(subscriber3!, error: &error)
//            subscriberView3?.removeFromSuperview()
//            subscriberView3 = nil
//            subscriber3 = nil
//            subscriber3?.subscribeToVideo = false
//            subscriber3?.subscribeToAudio = false
        }
    }
    
    @objc func closeView(){
        if (self.session != nil){
            var error: OTError?
            self.session!.disconnect(&error)
        }
        self.dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func closeAttendance(){
        self.showSpinner(onView: self.view)
        let urlStr:String = domain + urlAcomplish + appointmentId
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                self.removeSpinner()
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    print("Resposta da API de gravação: \(json)")
                    self.removeSpinner()
                } catch {
                    self.removeSpinner()
                }
            }
        })
        task.resume()
    }
    
    // MARK: - Room Functions
    
    func getDateInit() {
        var request = URLRequest(url: URL(string: domain + "/appointment/checkin?id=" + appointmentId)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    if (json["participants"] != nil && json["session"] != nil) {
                        self.sessionInit = json["date_start_attendance"] as? String
                    }
                } catch {
                }
            }
        })
        task.resume()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:(#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        let Dateformatter = DateFormatter()
        Dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var dateInit = Date()
        if (sessionInit != nil ) {
            dateInit = Dateformatter.date(from: sessionInit!)!
            //dateInit = dateInit.addingTimeInterval(-3600)
        } else {
            //print("data de início não registrada ainda.")
            return
        }
        let calendar = Calendar.current
        let dateDiff = calendar.dateComponents([Calendar.Component.second], from: dateInit, to: Date())
        let diffTotal = dateDiff.second!
        let hours = Int(diffTotal) / 3600
        let minutes = Int(diffTotal) / 60 % 60
        let seconds = Int(diffTotal) % 60
        if (hours > 0) {
            timerLabel?.title = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            timerLabel?.title = String(format:"%02i:%02i", minutes, seconds)
        }
    }
    
    @objc func sendChatMessage(txtMsg: String) {
        var error: OTError? = nil
        let chatMsgData : [String : Any] = ["user":publisherName,"message":txtMsg]
        do {
            let chatMsgJson = try JSONSerialization.data(withJSONObject: chatMsgData, options: .prettyPrinted)
            let signalString = String(data: chatMsgJson, encoding: String.Encoding.utf8)
            session?.signal(withType: "msg", string: signalString, connection: nil, error: &error)
            if error != nil {
                if let error = error {
                    print("Signal error: \(error)")
                }
            } else {
                print("Signal sent: \(txtMsg)")
            }
        } catch let jsonError {
            print(jsonError)
        }
    }
    
    func saveMessageToServer() {
        let txtMsg:String = chatController!.txfChatMsg!.text!
        let objMsg: [String:Any] = [
            "message":"\(txtMsg)",
            "participantName":"\(publisherName)"
        ]
        self.view.endEditing(true)
        chatController!.txfChatMsg!.text = ""
        let jsonMsg = try? JSONSerialization.data(withJSONObject: objMsg)
        var request = URLRequest(url: URL(string: domain + urlSaveMessage + appointmentId)!)
        request.httpMethod = "PUT"
        request.httpBody = jsonMsg
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    self.sendChatMessage(txtMsg: txtMsg)
                    print(json)
                } catch {
                }
            }
        })
        task.resume()
    }
    
    func selectFileToSend() {
        
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.content","public.image"], in: .import)
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .overCurrentContext
        
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func sendFileToServer(fileBase64: String, name: String) {
        self.showSpinner(onView: self.view)
        let objMsg: [String:Any] = [
            "name":"\(name)",
            "file":"\(fileBase64)"
        ]
        let jsonMsg = try? JSONSerialization.data(withJSONObject: objMsg)
        var request = URLRequest(url: URL(string: domain + urlSendFile + appointmentId)!)
        request.httpMethod = "PUT"
        request.httpBody = jsonMsg
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                self.removeSpinner()
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    var fileDate:String = ""
                    if (json["date"] != nil) {
                        fileDate = json["date"] as! String
                    }
                    var filePath:String = ""
                    if (json["filePath"] != nil) {
                        filePath = json["filePath"] as! String
                    }
                    var fileName:String = ""
                    if (json["nameOriginal"] != nil) {
                        fileName = json["nameOriginal"] as! String
                    }
                    var fileEncoded:String = ""
                    if (json["encoded"] != nil) {
                        fileEncoded = json["encoded"] as! String
                    }
                    self.removeSpinner()
                    self.sendFileSignal(date: fileDate, filePath: filePath, nameOriginal: fileName, encoded: fileEncoded)
                    print("Resposta da API de envio de arquivo: \(json)")
                } catch {
                    self.removeSpinner()
                }
            }
        })
        task.resume()
    }
    
    @objc func sendFileSignal(date: String, filePath: String, nameOriginal: String, encoded: String) {
        var error: OTError? = nil
        let chatMsgData : [String : Any] = ["date":date,"participant":publisherId,"filePath":filePath,"nameOriginal":nameOriginal,"encoded":encoded]
        do {
            let chatMsgJson = try JSONSerialization.data(withJSONObject: chatMsgData, options: .prettyPrinted)
            let signalString = String(data: chatMsgJson, encoding: String.Encoding.utf8)
            session?.signal(withType: "file", string: signalString, connection: nil, error: &error)
            if error != nil {
                if let error = error {
                    print("Signal error: \(error)")
                }
            } else {
                print("Signal sent: \(chatMsgData)")
            }
        } catch let jsonError {
            print(jsonError)
        }
    }
    func selectFileAction(fileSharePath: String, fileShareName: String, filePublisherId: String) {
        var alertTitle:String="Doutor Ao Vivo"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }
        let alertController = UIAlertController(title: alertTitle, message: "O que deseja fazer?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Download", style: UIAlertAction.Style.default, handler: { action in
            self.downloadFileFromServer(fileSharePath: fileSharePath, fileShareName: fileShareName)
        }))
        if (self.publisherId == filePublisherId) {
            alertController.addAction(UIAlertAction(title: "Excluir", style: UIAlertAction.Style.default, handler: { action in
                self.deleteFileFromServer(filePath: fileSharePath, name: fileShareName)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func downloadFileFromServer(fileSharePath: String, fileShareName: String) {
        self.showSpinner(onView: self.view)
        let myURLstring = self.domainMedia + "/" + fileSharePath
        
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent(fileShareName)
        
        let fileURL = URL(string: myURLstring)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    do {
                        if FileManager.default.fileExists(atPath: destinationFileUrl.path) {
                            try FileManager.default.removeItem(at: destinationFileUrl)
                        }
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        print("Saved file in \(destinationFileUrl) ")
                        DispatchQueue.main.async {
                            self.alertMsg = "Arquivo salvo em: \(destinationFileUrl)"
                            self.showDownloadedFile(destinationFileUrl: destinationFileUrl)
                            self.removeSpinner()
                        }
                    } catch (let writeError) {
                        self.removeSpinner()
                        self.alertMsg = "Arquivo salvo em: \(tempLocalUrl)"
                        self.showAlert(self)
                        print("Error creating a file from \(tempLocalUrl) to \(destinationFileUrl) : \(writeError)")
                    }
                } else {
                    self.removeSpinner()
                    self.alertMsg = "Erro ao fazer download do arquivo."
                    self.showAlert(self)
                    print("Erro ao fazer download do arquivo.")
                }
            } else {
                self.removeSpinner()
                self.alertMsg = "Erro ao fazer download do arquivo."
                self.showAlert(self)
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any)
            }
        }
        task.resume()
    }

    let preview = UIViewController();

    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        preview.modalPresentationStyle = .overCurrentContext;
        self.view.addSubview(preview.view);
        return preview;
     }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        preview.dismiss(animated: true, completion: nil)
        preview.view.removeFromSuperview();
    }
    
    func showDownloadedFile(destinationFileUrl: URL) {
        let dc = UIDocumentInteractionController(url: destinationFileUrl)
        dc.delegate = self
        dc.presentPreview(animated: true)
    }
    
    func deleteFileFromServer(filePath: String, name: String) {
        self.showSpinner(onView: self.view)
        let objMsg: [String:Any] = [
            "delete":true,
            "filePath":"\(filePath)"
        ]
        let jsonMsg = try? JSONSerialization.data(withJSONObject: objMsg)
        var request = URLRequest(url: URL(string: domain + urlDeleteFile + appointmentId + "&filePath=" + filePath)!)
        request.httpMethod = "DELETE"
        request.httpBody = jsonMsg
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                self.removeSpinner()
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    var resMessage:String = ""
                    if (json["message"] != nil) {
                        resMessage = json["message"] as! String
                    }
                    var resCode:Int = 0
                    if (json["code"] != nil) {
                        resCode = json["code"] as! Int
                    }
                    self.removeSpinner()
                    self.alertMsg = resMessage
                    self.showAlert(self)
                    if (resCode == 200) {
                        self.reloadFileList()
                    }
                    print("Resposta da API de excluir arquivo: \(json)")
                } catch {
                    self.removeSpinner()
                }
            }
        })
        task.resume()
    }
    
    func reloadFileList() {
        var request = URLRequest(url: URL(string: domain + "/appointment/checkin?id=" + appointmentId)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                self.removeSpinner()
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    self.appointmentJson = json
                    //files list
                    if (json["files"] != nil) {
                        self.fileShareList.removeAll()
                        self.roomFiles = json["files"] as? Array<Any>
                        self.fetchFiles()
                        if (self.fileListView != nil) {
                            self.archiveController!.filesList.removeAll()
                            self.archiveController!.filesTableView.reloadData()
                            self.archiveController!.filesList = self.fileShareList
                            self.archiveController!.filesTableView.reloadData()
                        }
                    }
                    self.removeSpinner()
                } catch {
                    self.removeSpinner()
                }
            }
        })
        task.resume()
    }
    
    func saveNotesToServer() {
        var txtMsg:String = notesController!.txfChatMsg!.text!
        if (txtMsg != self.notesSaved) {
            if (self.publisherRole == "MMD") {
                self.notesSaved = txtMsg
                if (txtMsg == "") {
                    txtMsg = " "
                    notesController!.txfChatMsg!.text = " "
                }
                self.showSpinner(onView: self.view)
                let objMsg: [String:Any] = [
                    "notes":"\(txtMsg)"
                ]
                let jsonMsg = try? JSONSerialization.data(withJSONObject: objMsg)
                var request = URLRequest(url: URL(string: domain + urlSaveNote + appointmentId)!)
                request.httpMethod = "PUT"
                request.httpBody = jsonMsg
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
                request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: { data, response, error in
                    guard let data = data, error == nil else {
                        self.removeSpinner()
                        return
                    }
                    DispatchQueue.main.async {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                            print("Resposta da API de envio de notas: \(json)")
                            self.removeSpinner()
                        } catch {
                            self.removeSpinner()
                        }
                    }
                })
                task.resume()
            }
        }
    }
    
    func recordVideo(record: Bool) {
        self.showSpinner(onView: self.view)
        var urlStr:String = domain + (record ? urlRecordStart : urlRecordStop) + appointmentId
        if (record) {
            self.recordId = ""
        } else {
            urlStr = urlStr + "&archiveId=\(self.recordId)"
        }
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authRoomParticipant, forHTTPHeaderField: "x-auth-room-participant")
        request.addValue(X_API_ID, forHTTPHeaderField: "x-api-id")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                self.removeSpinner()
                return
            }
            DispatchQueue.main.async {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                    if (record == true) {
                        if (json["id"] != nil) {
                            self.recordId = json["id"] as! String
                        }
                    } else {
                        self.recordId = ""
                    }
                    print("Resposta da API de gravação: \(json)")
                    self.removeSpinner()
                } catch {
                    self.removeSpinner()
                }
            }
        })
        task.resume()
    }
    
    func screenshot() -> UIImage? {
        var imageSize = CGSize.zero

        imageSize = UIScreen.main.bounds.size

        UIGraphicsBeginImageContextWithOptions(imageSize, _: false, _: 0)
        let window = UIApplication.shared.keyWindow

        if window?.responds(to: #selector(UIView.drawHierarchy(in:afterScreenUpdates:))) ?? false {
            window?.drawHierarchy(in: window?.bounds ?? CGRect.zero, afterScreenUpdates: false)
        } else {
            if let context = UIGraphicsGetCurrentContext() {
                window?.layer.render(in: context)
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func viewScreenshot(viewScreen:UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(viewScreen.frame.size, false, 0);
        viewScreen.drawHierarchy(in: viewScreen.bounds, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func convertImageToBase64(_ image: UIImage) -> String {
        return UIImagePNGRepresentation(image)?.base64EncodedString(options: .lineLength64Characters) ?? ""
    }
    
    func sendScreenshotView(viewScreen:UIView) {
        var file:String=""
        file = "data:image/png;base64," + convertImageToBase64(viewScreenshot(viewScreen: viewScreen)!)
        let indexFile:Int=fileShareList.count + 1
        let fileName:String="foto-" + String(indexFile) + "-" + String(NSDate().timeIntervalSince1970) + ".png"
        self.sendFileToServer(fileBase64: file, name: fileName)
    }
    
    // MARK: - Add Objects Functions
    
    func addToolBarSpace() {
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
    }
    
    func addTimerLabel() {
        let timerValue:String = "00:00"
        timerLabel = UIBarButtonItem(title: timerValue, style: .plain, target: nil, action: nil)
        items.append(timerLabel!)
    }
    
    func addMicButton() {
        //botão Microfone
        buttonMic = UIBarButtonItem(image: UIImage(named: "mic-on", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(toggleMic))
        if (showButtonMicPub == true){
            addToolBarSpace()
            items.append(buttonMic!)
        }
    }
    
    func addVideoButton() {
        //botão Video
        buttonCam = UIBarButtonItem(image: UIImage(named: "video-on", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(toggleCam))
        if (showButtonVideo == true){
            addToolBarSpace()
            items.append(buttonCam!)
        }
    }
    
    func addRecordButton() {
        buttonRecord = UIBarButtonItem(image: UIImage(named: "record", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(toggleRecord))
        if (showButtonRecord == true) {
            addToolBarSpace()
            items.append(buttonRecord!)
        }
    }
    
    func addFlipButton() {
        buttonFlip = UIButton()
        buttonFlip!.frame = CGRect(x:0, y: 0, width: (menuView?.frame.size.width)!, height: 50)
        buttonFlip!.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonFlip!.addTarget(self, action: #selector(toggleFlip), for: .touchUpInside)
        self.menuView!.addSubview(buttonFlip!)
        let btImg = UIImageView(image: UIImage(named: "flip", in: DavViewController.getBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
        btImg.contentMode = UIView.ContentMode.scaleAspectFill
        btImg.layer.masksToBounds = true
        buttonFlip!.addSubview(btImg)
        btImg.translatesAutoresizingMaskIntoConstraints = false
        btImg.leadingAnchor.constraint(equalTo: buttonFlip!.leadingAnchor, constant: 10).isActive = true
        btImg.topAnchor.constraint(equalTo: buttonFlip!.topAnchor, constant: 10).isActive = true
        btImg.bottomAnchor.constraint(equalTo: buttonFlip!.bottomAnchor, constant: 10).isActive = true
        btImg.widthAnchor.constraint(equalTo: btImg.heightAnchor).isActive = true
        let btLab = UILabel()
        btLab.text = "Trocar câmera"
        btLab.font = UIFont.systemFont(ofSize: 16.0)
        btLab.textAlignment = NSTextAlignment.left
        btLab.textColor = davBackgroundActionsRoom
        if (showButtonFlip == true) {
            buttonFlip!.addSubview(btLab)
            btLab.translatesAutoresizingMaskIntoConstraints = false
            btLab.leadingAnchor.constraint(equalTo: btImg.trailingAnchor, constant: 20).isActive = true
            btLab.trailingAnchor.constraint(equalTo: buttonFlip!.trailingAnchor, constant: 10).isActive = true
            btLab.topAnchor.constraint(equalTo: buttonFlip!.topAnchor, constant: 10).isActive = true
            btLab.bottomAnchor.constraint(equalTo: buttonFlip!.bottomAnchor, constant: 10).isActive = true
            buttonFlip!.tintColor = davBackgroundActionsRoom
            buttonFlip!.backgroundColor = davTextColorButtonActionsRoom
        }
    }
    
    func addArchiveButton() {
        var posY:Int = 0
        if (self.showButtonFlip == true) {
            posY = posY + 50
        }
        buttonArchive = UIButton()
        buttonArchive!.frame = CGRect(x:0, y: posY, width: Int((menuView?.frame.size.width)!), height: 50)
        buttonArchive!.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonArchive!.addTarget(self, action: #selector(toggleArchive), for: .touchUpInside)
        self.menuView!.addSubview(buttonArchive!)
        let btImg = UIImageView(image: UIImage(named: "files", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate))
        btImg.contentMode = .scaleAspectFill
        buttonArchive!.addSubview(btImg)
        btImg.translatesAutoresizingMaskIntoConstraints = false
        btImg.leadingAnchor.constraint(equalTo: buttonArchive!.leadingAnchor, constant: 10).isActive = true
        btImg.topAnchor.constraint(equalTo: buttonArchive!.topAnchor, constant: 10).isActive = true
        btImg.bottomAnchor.constraint(equalTo: buttonArchive!.bottomAnchor, constant: 10).isActive = true
        btImg.widthAnchor.constraint(equalTo: btImg.heightAnchor).isActive = true
        let btLab = UILabel()
        btLab.text = "Arquivos"
        btLab.font = UIFont.systemFont(ofSize: 16.0)
        btLab.textAlignment = NSTextAlignment.left
        btLab.textColor = davBackgroundActionsRoom
        if (showButtonFiles == true) {
            buttonArchive!.addSubview(btLab)
            btLab.translatesAutoresizingMaskIntoConstraints = false
            btLab.leadingAnchor.constraint(equalTo: btImg.trailingAnchor, constant: 20).isActive = true
            btLab.trailingAnchor.constraint(equalTo: buttonArchive!.trailingAnchor, constant: 10).isActive = true
            btLab.topAnchor.constraint(equalTo: buttonArchive!.topAnchor, constant: 10).isActive = true
            btLab.bottomAnchor.constraint(equalTo: buttonArchive!.bottomAnchor, constant: 10).isActive = true
            buttonArchive!.tintColor = davBackgroundActionsRoom
            buttonArchive!.backgroundColor = davTextColorButtonActionsRoom
        }
    }
    
    func addNotesButton() {
        var posY:Int = 0
        if (self.showButtonFlip == true) {
            posY = posY + 50
        }
        if (self.showButtonFiles == true) {
            posY = posY + 50
        }
        buttonNotes = UIButton()
        buttonNotes!.frame = CGRect(x:0, y: posY, width: Int((menuView?.frame.size.width)!), height: 50)
        buttonNotes!.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonNotes!.addTarget(self, action: #selector(toggleNotes), for: .touchUpInside)
        self.menuView!.addSubview(buttonNotes!)
        let btImg = UIImageView(image: UIImage(named: "notes", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate))
        btImg.contentMode = .scaleAspectFill
        buttonNotes!.addSubview(btImg)
        btImg.translatesAutoresizingMaskIntoConstraints = false
        btImg.leadingAnchor.constraint(equalTo: buttonNotes!.leadingAnchor, constant: 10).isActive = true
        btImg.topAnchor.constraint(equalTo: buttonNotes!.topAnchor, constant: 10).isActive = true
        btImg.bottomAnchor.constraint(equalTo: buttonNotes!.bottomAnchor, constant: 10).isActive = true
        btImg.widthAnchor.constraint(equalTo: btImg.heightAnchor).isActive = true
        let btLab = UILabel()
        btLab.text = "Notas"
        btLab.font = UIFont.systemFont(ofSize: 16.0)
        btLab.textAlignment = NSTextAlignment.left
        btLab.textColor = davBackgroundActionsRoom
        if (showButtonNotes == true) {
            buttonNotes!.addSubview(btLab)
            btLab.translatesAutoresizingMaskIntoConstraints = false
            btLab.leadingAnchor.constraint(equalTo: btImg.trailingAnchor, constant: 20).isActive = true
            btLab.trailingAnchor.constraint(equalTo: buttonNotes!.trailingAnchor, constant: 10).isActive = true
            btLab.topAnchor.constraint(equalTo: buttonNotes!.topAnchor, constant: 10).isActive = true
            btLab.bottomAnchor.constraint(equalTo: buttonNotes!.bottomAnchor, constant: 10).isActive = true
            buttonNotes!.tintColor = davBackgroundActionsRoom
            buttonNotes!.backgroundColor = davTextColorButtonActionsRoom
        }
    }
    
    func addPrintButton() {
        var posY:Int = 0
        if (self.showButtonFlip == true) {
            posY = posY + 50
        }
        if (self.showButtonFiles == true) {
            posY = posY + 50
        }
        if (self.showButtonNotes == true) {
            posY = posY + 50
        }
        buttonPrint = UIButton()
        buttonPrint!.frame = CGRect(x:0, y: posY, width: Int((menuView?.frame.size.width)!), height: 50)
        buttonPrint!.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonPrint!.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        buttonPrint!.addTarget(self, action: #selector(togglePrint), for: .touchUpInside)
        self.menuView!.addSubview(buttonPrint!)
        let btImg = UIImageView(image: UIImage(named: "print", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate))
        btImg.contentMode = .scaleAspectFill
        buttonPrint!.addSubview(btImg)
        btImg.translatesAutoresizingMaskIntoConstraints = false
        btImg.leadingAnchor.constraint(equalTo: buttonPrint!.leadingAnchor, constant: 10).isActive = true
        btImg.topAnchor.constraint(equalTo: buttonPrint!.topAnchor, constant: 10).isActive = true
        btImg.bottomAnchor.constraint(equalTo: buttonPrint!.bottomAnchor, constant: 10).isActive = true
        btImg.widthAnchor.constraint(equalTo: btImg.heightAnchor).isActive = true
        let btLab = UILabel()
        btLab.text = "Snapshot"
        btLab.font = UIFont.systemFont(ofSize: 16.0)
        btLab.textAlignment = NSTextAlignment.left
        btLab.textColor = davBackgroundActionsRoom
        if (showButtonSnapshot == true) {
            buttonPrint!.addSubview(btLab)
            btLab.translatesAutoresizingMaskIntoConstraints = false
            btLab.leadingAnchor.constraint(equalTo: btImg.trailingAnchor, constant: 20).isActive = true
            btLab.trailingAnchor.constraint(equalTo: buttonPrint!.trailingAnchor, constant: 10).isActive = true
            btLab.topAnchor.constraint(equalTo: buttonPrint!.topAnchor, constant: 10).isActive = true
            btLab.bottomAnchor.constraint(equalTo: buttonPrint!.bottomAnchor, constant: 10).isActive = true
            buttonPrint!.tintColor = davBackgroundActionsRoom
            buttonPrint!.backgroundColor = davTextColorButtonActionsRoom
        }
    }
    
    func addShareButton() {
        
    }
    
    func addCloseButton() {
        buttonClose = UIBarButtonItem(image: UIImage(named: "close", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(toggleClose))
        buttonClose?.tintColor = davBackgroundButtonEndCallActionsRoom
        if (showButtonClose == true) {
            addToolBarSpace()
            items.append(buttonClose!)
        }
    }
    
    func addMsgButton() {
        buttonMsg = UIBarButtonItem(image: UIImage(named: "message", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(toggleMsg))
        if (showButtonMsg == true) {
            addToolBarSpace()
            items.append(buttonMsg!)
        }
    }
    
    func addMenuButton() {
        buttonMenu = UIBarButtonItem(image: UIImage(named: "menu", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
        style: .plain, target: self, action: #selector(toggleMenu))
        if (showButtonMenu == true) {
            addToolBarSpace()
            items.append(buttonMenu!)
        }
    }
    
    func addWaitingView() {
        let screenBounds = UIScreen.main.bounds
        let waitingFrame = CGRect(x: 0, y: CGFloat(self.topLayoutGuide.length), width: CGFloat(screenBounds.width), height: CGFloat(screenBounds.height) - CGFloat(tbButtons!.frame.height) - CGFloat(self.topLayoutGuide.length))
        waitingView = UIView()
        waitingView!.frame = waitingFrame
        self.view.addSubview(waitingView!)
        waitingView!.isHidden = true
        let message = UILabel()
        if (self.waitingMessage == "") {
            self.waitingMessage = "Aguarde até o médico entrar na sala."
        }
        message.text = self.waitingMessage
        message.translatesAutoresizingMaskIntoConstraints = false
        message.lineBreakMode = .byWordWrapping
        message.numberOfLines = 0
        message.textAlignment = .center
        waitingView!.addSubview(message)
        message.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        message.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        message.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        ai.startAnimating()
        ai.center = waitingView!.center
        DispatchQueue.main.async {
//            self.waitingView!.addSubview(ai)
        }
    }
    
    func addChatView() {
        let screenBounds = UIScreen.main.bounds
        let chatFrame = CGRect(x: 0, y: CGFloat(self.topLayoutGuide.length), width: CGFloat(screenBounds.width), height: CGFloat(screenBounds.height) - CGFloat(tbButtons!.frame.height) - CGFloat(self.topLayoutGuide.length))
        chatView = UIView()
        chatView!.frame = chatFrame
        self.view.addSubview(chatView!)
        chatView!.isHidden = true
        chatView!.backgroundColor = UIColor.white
        chatController = ChatViewController()
        chatController?.myDelegate = self
        chatController!.chatHeight = chatFrame.height
        chatController!.davBackgroundVideoHeaderParticipant = self.davBackgroundVideoHeaderParticipant
        chatController!.davTextColorVideoHeaderParticipant = self.davTextColorVideoHeaderParticipant
        chatController!.chatMessages = self.chatMessages
        chatController!.publisherId = self.publisherId
        chatController!.davTextColorballonMine = self.davTextColorballonMine
        chatController!.davTextColorBallonOther = self.davTextColorBallonOther
        chatController!.davBackgroundBallonMineColor = self.davBackgroundBallonMineColor
        chatController!.davBackgroundBallonOtherColor = self.davBackgroundBallonOtherColor
        chatView?.addSubview(chatController!.view)
    }
    
    func addFileListView() {
        let screenBounds = UIScreen.main.bounds
        let fileListFrame = CGRect(x: 0, y: CGFloat(self.topLayoutGuide.length), width: CGFloat(screenBounds.width), height: CGFloat(screenBounds.height) - CGFloat(tbButtons!.frame.height) - CGFloat(self.topLayoutGuide.length))
        fileListView = UIView()
        fileListView!.frame = fileListFrame
        self.view.addSubview(fileListView!)
        fileListView!.isHidden = true
        fileListView!.backgroundColor = UIColor.white
        archiveController = ArchiveViewController()
        archiveController?.myDelegate = self
        archiveController!.listHeight = fileListFrame.height
        archiveController!.domainMedia = self.domainMedia
        archiveController!.publisherId = self.publisherId
        archiveController!.publisherName = self.publisherName
        archiveController!.davBackgroundVideoHeaderParticipant = self.davBackgroundVideoHeaderParticipant
        archiveController!.davTextColorVideoHeaderParticipant = self.davTextColorVideoHeaderParticipant
        archiveController!.filesList = self.fileShareList
        fileListView?.addSubview(archiveController!.view)
    }
    
    func addNotesView() {
        let screenBounds = UIScreen.main.bounds
        let chatFrame = CGRect(x: 0, y: CGFloat(self.topLayoutGuide.length), width: CGFloat(screenBounds.width), height: CGFloat(screenBounds.height) - CGFloat(tbButtons!.frame.height) - CGFloat(self.topLayoutGuide.length))
        notesView = UIView()
        notesView!.frame = chatFrame
        self.view.addSubview(notesView!)
        notesView!.isHidden = true
        notesView!.backgroundColor = UIColor.white
        notesController = NotesViewController()
        notesController?.myDelegate = self
        notesController!.listHeight = chatFrame.height
        notesController!.davBackgroundVideoHeaderParticipant = self.davBackgroundVideoHeaderParticipant
        notesController!.davTextColorVideoHeaderParticipant = self.davTextColorVideoHeaderParticipant
        notesController!.publisherRole = self.publisherRole
        notesView?.addSubview(notesController!.view)
        notesController!.txfChatMsg!.text = self.notesSaved
    }
    
    func addMenuView() {
        let screenBounds = UIScreen.main.bounds
        let menuFrame = CGRect(x: (CGFloat(screenBounds.width) * 0.40), y: CGFloat(self.topLayoutGuide.length), width: (CGFloat(screenBounds.width) * 0.60), height: CGFloat(screenBounds.height) - CGFloat(tbButtons!.frame.height) - CGFloat(self.topLayoutGuide.length))
        menuView = UIView()
        menuView!.frame = menuFrame
        self.view.addSubview(menuView!)
        menuView!.isHidden = true
        menuView!.backgroundColor = UIColor.white
        //menu buttons
        addFlipButton()
        addArchiveButton()
        if (publisherRole == "MMD") {
            addNotesButton()
            addPrintButton()
        }
    }
    
    func addToolBarButtons() {
        items.removeAll()
        addTimerLabel()
        addMicButton()
        addVideoButton()
        if (publisherRole == "MMD") {
            addRecordButton()
        }
        addMsgButton()
        addCloseButton()
        addMenuButton()
        tbButtons!.setItems(items, animated: true)
    }
    
    // MARK: - Size Functions
    
    func defineViewPos() -> Int {
        var returnPos:Int?
        for i in 0...3 {
            if (pubViewPos != i) {
                if (subViewPos != i) {
                    if (subViewPos2 != i) {
                        if (subViewPos3 != i) {
                            returnPos=i
                            break
                        }
                    }
                }
            }
        }
        if (returnPos == nil) { returnPos = 0 }
        return returnPos!
    }
    
    func defineView(_ screenSize: CGSize, _ viewPos: Int) -> CGRect {
        let isPortrait:Bool = screenSize.width < screenSize.height;
        
        let availableWidth:Int = Int(screenSize.width);
        let availableHeight:Int = Int(screenSize.height - tbButtons!.frame.height - self.bottomLayoutGuide.length - self.topLayoutGuide.length);
        let padding:Int = Int(tbButtons!.frame.height / (isPortrait ? 4 : 6));
        let proportion:Int = 2
        let maxViews:Int = 4;
        
        var posX:Int
        var posY:Int
        var viewWidth:Int
        var viewHeight:Int
        
        if (viewPos == 0) {
            posY = Int(self.topLayoutGuide.length)
            posX = 0
            viewWidth = availableWidth;
            viewHeight = availableHeight;
        } else {
            if (isPortrait) {
                
                viewWidth = (availableWidth / proportion);
                viewWidth = viewWidth - padding;

                viewHeight = (availableHeight / maxViews);
                viewHeight = viewHeight - padding;
                
                posX = (availableWidth / proportion)
                posY = (availableHeight - (viewHeight * viewPos));

            } else {

                viewWidth = (availableWidth / maxViews);
                viewWidth = viewWidth - padding;

                viewHeight = (availableHeight / proportion);
                viewHeight = viewHeight - padding;
                
                posX = (maxViews - viewPos) * viewWidth;
                posY = (availableHeight / proportion)

            }
        }
        
        return CGRect(x: posX, y: posY, width: viewWidth, height: viewHeight)
    }

    func setView(_ targetView: UIView, _ screenSize: CGSize, _ viewPos: Int) {
        var posX:CGFloat?
        var posY:CGFloat?
        var viewWidth:CGFloat?
        var viewHeight:CGFloat?
        targetView.translatesAutoresizingMaskIntoConstraints = true
        targetView.removeConstraints(targetView.constraints)
        if (viewPos == 0) {
            posY = 0.0
            posX = 0.0
            viewWidth = 0
            viewHeight = 0
            targetView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            targetView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        } else {
            if (CGFloat(screenSize.width) < 220.0) {
                viewWidth = CGFloat(screenSize.width - 20.0)
            } else {
                viewWidth = CGFloat((screenSize.width - 80.0) / 3)
            }
            viewHeight = CGFloat((viewWidth!) * 3 / 4)
            targetView.frame.size.width = viewWidth!
            targetView.frame.size.height = viewHeight!
            posY = 20
            if (viewPos == 1) {
                posX = 20.0
            } else if (viewPos == 2) {
                if (CGFloat(screenSize.width) >= 420.0) {
                    posX = 20.0 + (viewWidth! + 20.0)
                } else {
                    posX = 20.0
                    posY = 20.0 + (viewHeight! + 20.0)
                }
            } else if (viewPos == 3) {
                if (CGFloat(screenSize.width) >= 620.0) {
                    posX = 20 + ((viewWidth! + 20.0) * 2)
                } else if (CGFloat(screenSize.width) >= 420.0) {
                    posX = 20.0
                    posY = 20.0 + (viewHeight! + 20.0)
                } else {
                    posX = 20
                    posY = 20.0 + ((viewHeight! + 20.0) * 2)
                }
            } else {
                posX = 20.0
            }
        }
        targetView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: posX!).isActive = true
        targetView.bottomAnchor.constraint(equalTo: tbButtons!.topAnchor, constant: posY!).isActive = true
    }
    
    func resizeView(_ callerView: Int, _ screenSize: CGSize) {
        
        if (callerView == 0) {
            if(publisher != nil) {
                publisherView?.frame = defineView(screenSize, pubViewPos!)
//                self.setView(publisherView!, screenSize, pubViewPos!)
                if (pubViewPos == 0) {
                    view.sendSubview(toBack: publisherView!)
                } else {
                    view.bringSubview(toFront: publisherView!)
                }
            }
        } else if (callerView == 1) {
            if(subscriber != nil) {
                subscriberView?.frame = defineView(screenSize, subViewPos!)
//                self.setView(subscriberView!, screenSize, subViewPos!)
                if (subViewPos == 0) {
                    view.sendSubview(toBack: subscriberView!)
                } else {
                    view.bringSubview(toFront: subscriberView!)
                }
            }
        } else if (callerView == 2) {
            if(subscriber2 != nil) {
                subscriberView2?.frame = defineView(screenSize, subViewPos2!)
//                self.setView(subscriberView2!, screenSize, subViewPos2!)
                if (subViewPos2 == 0) {
                    view.sendSubview(toBack: subscriberView2!)
                } else {
                    view.bringSubview(toFront: subscriberView2!)
                }
            }
        } else if (callerView == 3) {
            if(subscriber3 != nil) {
                subscriberView3?.frame = defineView(screenSize, subViewPos3!)
//                self.setView(subscriberView3!, screenSize, subViewPos3!)
                if (subViewPos3 == 0) {
                    view.sendSubview(toBack: subscriberView3!)
                } else {
                    view.bringSubview(toFront: subscriberView3!)
                }
            }
        }
        if (chatView != nil) {
            if (chatView!.isHidden == false) {
                view.bringSubview(toFront: chatView!)
            }
        }
        if (fileListView != nil) {
            if (fileListView!.isHidden == false) {
                view.bringSubview(toFront: fileListView!)
            }
        }
        if (notesView != nil) {
            if (notesView!.isHidden == false) {
                view.bringSubview(toFront: notesView!)
            }
        }
        if (menuView != nil) {
            if (menuView!.isHidden == false) {
                view.bringSubview(toFront: menuView!)
            }
        }
    }
    
    func resizeChat(_ screenSize: CGSize) {
        if (chatView != nil) {
            chatView!.frame = CGRect(x: 0, y: Int(self.topLayoutGuide.length), width: Int(screenSize.width), height: Int(screenSize.height) - Int(tbButtons!.frame.height) - Int(self.topLayoutGuide.length))
            let txfWidth = Int(chatView!.frame.width) - 80
            chatController!.txfChatMsg!.frame.size = CGSize(width: txfWidth, height: 30)
            if (chatView!.isHidden == false) {
                view.bringSubview(toFront: chatView!)
            }
        }
    }
    
    func resizeNotes(_ screenSize: CGSize) {
        if (notesView != nil) {
            notesView!.frame = CGRect(x: 0, y: Int(self.topLayoutGuide.length), width: Int(screenSize.width), height: Int(screenSize.height) - Int(tbButtons!.frame.height) - Int(self.topLayoutGuide.length))
            let txfWidth = Int(notesView!.frame.width) - 40
            notesController!.txfChatMsg!.frame.size = CGSize(width: txfWidth, height: 30)
            if (notesView!.isHidden == false) {
                view.bringSubview(toFront: notesView!)
            }
        }
    }
    
    func resizeFileList(_ screenSize: CGSize) {
        if (fileListView != nil) {
            fileListView!.frame = CGRect(x: 0, y: Int(self.topLayoutGuide.length), width: Int(screenSize.width), height: Int(screenSize.height) - Int(tbButtons!.frame.height) - Int(self.topLayoutGuide.length))
            if (fileListView!.isHidden == false) {
                view.bringSubview(toFront: fileListView!)
            }
        }
    }
    
    func resizeMenu(_ screenSize: CGSize) {
        if (menuView != nil) {
            menuView!.frame = CGRect(x: (CGFloat(screenSize.width) * 0.25), y: CGFloat(self.topLayoutGuide.length), width: (CGFloat(screenSize.width) * 0.75), height: CGFloat(screenSize.height) - CGFloat(tbButtons!.frame.height) - CGFloat(self.topLayoutGuide.length))
            if (menuView!.isHidden == false) {
                view.bringSubview(toFront: menuView!)
            }
        }
    }
    
    // MARK: - Button's Toggles
    
    @objc func toggleMic(sender: UIButton!) {
        if (publisher != nil && publisherView != nil) {
            if publisher?.publishAudio == false {
                publisher!.publishAudio=true
                buttonMic!.image = UIImage(named: "mic-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
            } else {
                publisher!.publishAudio=false
                buttonMic!.image = UIImage(named: "mic-off", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    @objc func toggleCam(sender: UIButton!) {
        if (publisher != nil && publisherView != nil) {
            if publisher?.publishVideo == false {
                publisher!.publishVideo = true
                buttonCam!.image = UIImage(named: "video-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
            } else {
                publisher!.publishVideo = false
                buttonCam!.image = UIImage(named: "video-off", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    @objc func toggleMicSub(sender: UIButton!) {
        if (subscriber != nil) {
            if subscriber?.subscribeToAudio == false {
                subscriber!.subscribeToAudio=true
                buttonMicSub!.image = UIImage(named: "volume-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
            } else {
                subscriber!.subscribeToAudio=false
                buttonMicSub!.image = UIImage(named: "volume-off", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    @objc func toggleMicSub2(sender: UIButton!) {
        if subscriber2?.subscribeToAudio == false {
            subscriber2!.subscribeToAudio=true
            buttonMicSub2!.image = UIImage(named: "volume-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        } else {
            subscriber2!.subscribeToAudio=false
            buttonMicSub2!.image = UIImage(named: "volume-off", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc func toggleMicSub3(sender: UIButton!) {
        if subscriber3?.subscribeToAudio == false {
            subscriber3!.subscribeToAudio=true
            buttonMicSub3!.image = UIImage(named: "volume-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        } else {
            subscriber3!.subscribeToAudio=false
            buttonMicSub3!.image = UIImage(named: "volume-off", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        }
    }
    
    @objc func togglePrintSub(sender: UIButton!) {
        if (subscriberView != nil) {
            sendScreenshotView(viewScreen: subscriberView!)
        }
    }
    
    @objc func togglePrintSub2(sender: UIButton!) {
        if (subscriberView2 != nil) {
            sendScreenshotView(viewScreen: subscriberView2!)
        }
    }
    
    @objc func togglePrintSub3(sender: UIButton!) {
        if (subscriberView3 != nil) {
            sendScreenshotView(viewScreen: subscriberView3!)
        }
    }
    
    @objc func toggleCamPub(sender: UITapGestureRecognizer!) {
        let screenBounds = UIScreen.main.bounds;
        
        if (pubViewPos != nil) {
            if (pubViewPos != 0) {
                if (subscriberView != nil) {
                    if (subViewPos == 0) {
                        subViewPos! = pubViewPos!
                        resizeView(1, screenBounds.size)
                    }
                }
                if (subscriberView2 != nil) {
                    if (subViewPos2 == 0) {
                        subViewPos2! = pubViewPos!
                        resizeView(2, screenBounds.size)
                    }
                }
                if (subscriberView3 != nil) {
                    if (subViewPos3 == 0) {
                        subViewPos3! = pubViewPos!
                        resizeView(3, screenBounds.size)
                    }
                }
                pubViewPos! = 0
                resizeView(0, screenBounds.size)
            }
        }
    }
    
    @objc func toggleCamSub(sender: UITapGestureRecognizer!) {
        let screenBounds = UIScreen.main.bounds;
        
        if (subViewPos != nil) {
            if (subViewPos != 0) {
                if (publisherView != nil) {
                    if (pubViewPos == 0) {
                        pubViewPos! = subViewPos!
                        resizeView(0, screenBounds.size)
                    }
                }
                if (subscriberView2 != nil) {
                    if (subViewPos2 == 0) {
                        subViewPos2! = subViewPos!
                        resizeView(2, screenBounds.size)
                    }
                }
                if (subscriberView3 != nil) {
                    if (subViewPos3 == 0) {
                        subViewPos3! = subViewPos!
                        resizeView(3, screenBounds.size)
                    }
                }
                subViewPos! = 0
                resizeView(1, screenBounds.size)
            }
        }
    }

    @objc func toggleCamSub2(sender: UITapGestureRecognizer!) {
        let screenBounds = UIScreen.main.bounds;

        if (subViewPos2 != nil) {
            if (subViewPos2 != 0) {
                if (publisherView != nil) {
                    if (pubViewPos == 0) {
                        pubViewPos! = subViewPos2!
                        resizeView(0, screenBounds.size)
                    }
                }
                if (subscriberView != nil) {
                    if (subViewPos == 0) {
                        subViewPos! = subViewPos2!
                        resizeView(1, screenBounds.size)
                    }
                }
                if (subscriberView3 != nil) {
                    if (subViewPos3 == 0) {
                        subViewPos3! = subViewPos2!
                        resizeView(3, screenBounds.size)
                    }
                }
                subViewPos2! = 0
                resizeView(2, screenBounds.size)
            }
        }
    }
    
    @objc func toggleCamSub3(sender: UITapGestureRecognizer!) {
        let screenBounds = UIScreen.main.bounds;

        if (subViewPos3 != nil) {
            if (subViewPos3 != 0) {
                if (publisherView != nil) {
                    if (pubViewPos == 0) {
                        pubViewPos! = subViewPos3!
                        resizeView(0, screenBounds.size)
                    }
                }
                if (subscriberView2 != nil) {
                    if (subViewPos2 == 0) {
                        subViewPos2! = subViewPos3!
                        resizeView(2, screenBounds.size)
                    }
                }
                if (subscriberView != nil) {
                    if (subViewPos == 0) {
                        subViewPos! = subViewPos3!
                        resizeView(1, screenBounds.size)
                    }
                }
                subViewPos3! = 0
                resizeView(3, screenBounds.size)
            }
        }
    }
    
    @objc func toggleRecord(sender: UIButton!) {
        if (recordId == "") {
            self.recordVideo(record: true)
        } else {
            self.recordVideo(record: false)
        }
    }
    
    @objc func toggleFlip(sender: UIButton!) {
        if(publisher!.cameraPosition == .back) {
            publisher!.cameraPosition = .front
        } else {
            publisher!.cameraPosition = .back
        }
        if (menuView != nil) {
            menuView!.isHidden = true
        }
    }
    
    @objc func togglePrint(sender: UIButton!) {
        if (menuView != nil) {
            menuView!.isHidden = true
        }
        //send screen shot to server
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            var file:String=""
            file = "data:image/png;base64," + self.convertImageToBase64(self.screenshot()!)
            let indexFile:Int=self.fileShareList.count + 1
            let fileName:String="foto-" + String(indexFile) + "-" + String(NSDate().timeIntervalSince1970) + ".png"
            self.sendFileToServer(fileBase64: file, name: fileName)
        }
    }
    
    @objc func toggleNotes(sender: UIButton!) {
        if (menuView != nil) {
            menuView!.isHidden = true
        }
        if (notesView != nil) {
            notesView!.isHidden = false
            view.bringSubview(toFront: notesView!)
        }
    }
    
    func closeNotesView() {
        if (notesView != nil) {
            notesView!.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    @objc func toggleShare(sender: UIButton!) {
        
    }
    
    @objc func toggleArchive(sender: UIButton!) {
        if (menuView != nil) {
            menuView!.isHidden = true
        }
        if (fileListView != nil) {
            fileListView!.isHidden = false
            view.bringSubview(toFront: fileListView!)
        }
    }
    
    func closeFileList() {
        if (fileListView != nil) {
            fileListView!.isHidden = true
        }
    }
    
    @objc func toggleClose(sender: UIButton!) {
        var alertTitle:String="Doutor Ao Vivo"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }
        let alertController = UIAlertController(title: alertTitle, message: "Deseja encerrar o atendimento?", preferredStyle: UIAlertController.Style.alert)
        if (publisherRole == "MMD") {
            alertController.addAction(UIAlertAction(title: "Encerrar", style: UIAlertAction.Style.default, handler: { action in
                self.closeSala()
                self.closeAttendance()
                self.closeView()
            }))
        }
        alertController.addAction(UIAlertAction(title: "Apenas sair", style: UIAlertAction.Style.default, handler: { action in
            self.closeSala()
            self.closeView()
        }))
        alertController.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func toggleMsg(sender: UIButton!) {
        if (chatView != nil) {
            if (chatView!.isHidden == true) {
                chatView!.isHidden = false
                view.bringSubview(toFront: chatView!)
                self.chatController!.resizeScrollView()
                self.chatController!.scrollToBottom(animated: true)
            } else {
                chatView!.isHidden = true
                self.view.endEditing(true)
            }
        }
    }
    
    func closeMsg() {
        if (chatView != nil) {
            chatView!.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    @objc func toggleMenu(sender: UIButton!) {
        if (menuView != nil) {
            if (menuView!.isHidden == true) {
                menuView!.isHidden = false
                view.bringSubview(toFront: menuView!)
            } else {
                menuView!.isHidden = true
            }
        }
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
    
    // MARK: - OTSessionDelegate callbacks
    public func sessionDidConnect(_ session: OTSession) {
        print("The client connected to the OpenTok session.")
        
        let settings = OTPublisherSettings()
        self.publisherName = self.publisherName.components(separatedBy: " ").first!
        settings.name = self.publisherName
        //print(session.connection?.data as Any)
        
        publisher = OTPublisher(delegate: self, settings:settings)
        guard (publisher != nil) else {
            return
        }
        
        var error: OTError?
        session.publish(publisher!, error: &error)
        guard error == nil else {
            print(error!)
            self.removeSpinner()
            self.alertMsg="Erro \(error!)"
            self.showAlert(self)
            return
        }
        
        publisherView = publisher?.view
        guard (publisherView != nil) else {
            return
        }
        //torna a tela do publisher como secundária
        if (pubViewPos == nil) {
            if (subViewPos == nil && subViewPos2 == nil && subViewPos3 == nil) {
                pubViewPos = 1
            } else {
                pubViewPos = self.defineViewPos()
            }
        }
        // cria o tap gesture
        tapPubView = UITapGestureRecognizer(target: self, action: #selector(toggleCamPub))
        publisherView!.isUserInteractionEnabled = true
        publisherView!.addGestureRecognizer(tapPubView!)
        //cria a publisherView
        let screenBounds = UIScreen.main.bounds
        view.addSubview(publisherView!)
        resizeView(0, screenBounds.size)
        //cria os botões
        addToolBarButtons()
        //toolbar da view
        publisherToolBar = UIToolbar()

        publisherToolBar!.barStyle = UIBarStyle.default
        publisherToolBar!.isTranslucent = true
        publisherToolBar!.setBackgroundImage(onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
        publisherToolBar!.tintColor = davTextColorVideoHeaderParticipant

        publisherView?.addSubview(publisherToolBar!)

//        publisherToolBar!.frame = CGRect(x: 0, y: 0, width: publisherView!.frame.width, height: publisherToolBar!.frame.height)
        publisherToolBar!.translatesAutoresizingMaskIntoConstraints = false
        publisherToolBar!.leadingAnchor.constraint(equalTo: publisherView!.leadingAnchor).isActive = true
        publisherToolBar!.trailingAnchor.constraint(equalTo: publisherView!.trailingAnchor).isActive = true
        publisherToolBar!.topAnchor.constraint(equalTo: publisherView!.topAnchor).isActive = true
        //Adiciona os itens da Toolbar
        itemsPub.append(UIBarButtonItem(title: publisherName, style: .plain, target: nil, action: nil))
        
        publisherToolBar!.setItems(itemsPub, animated: true)

        self.addMenuView()
        self.addChatView()
        if (publisherRole == "MMD") {
            self.addNotesView()
        } else {
            self.addWaitingView()
            if (waitingView != nil) {
                waitingView!.isHidden = false
                view.bringSubview(toFront: publisherView!)
            }
        }
        self.addFileListView()
        self.removeSpinner()
        self.runTimer()
    }

    public func sessionDidDisconnect(_ session: OTSession) {
        print("The client disconnected from the OpenTok session.")
        var alertTitle:String="Doutor Ao Vivo"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }
        alertMsg = "O atendimento foi finalizado"
        subscriberView?.removeFromSuperview()
        itemsSub.removeAll()
        subViewPos = nil
        subscriber = nil
        subscriberView = nil
        subscriberName = ""
        let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Sair da Sala", style: UIAlertAction.Style.default, handler: { action in
            self.closeSala()
            self.closeView()
        }))
        present(alertController, animated: true, completion: nil)
    }

    public func session(_ session: OTSession, didFailWithError error: OTError) {
        print("The client failed to connect to the OpenTok session: \(error).")
        self.connectionError()
    }
    
    public func session(_ session: OTSession, streamCreated stream: OTStream) {
        let screenBounds = UIScreen.main.bounds;
        var actual = 0;

        //stream data
        if let data = (stream.connection.data)!.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data) as! Dictionary<String, AnyObject>
                if (json["participant"] != nil) {
                    if let participantObj  = json["participant"] as? Dictionary<String, AnyObject> {
                        if let subscriberId = participantObj["id"] {
                            if (subscriberId as! String == self.publisherId) {
                                self.closeSala()
                                self.alertMsg = "Erro fatal. Verifique sua conexão e tente mais tarde."
                                self.showAlertClose(self)
                                return
                            }
                        } else {
                            return
                        }
                    } else {
                        return
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        if(subscriber != nil) {
            if (subscriber2 != nil) {
                if (subscriber3 != nil) {
                    //já existem outros 2
                    return
                } else {
                    print("A stream (3) was created in the session.")
                    actual = 3;
                    subscriber3 = OTSubscriber(stream: stream, delegate: self)
                    guard (subscriber3 != nil) else {
                        return
                    }
                    var error: OTError?
                    session.subscribe(subscriber3!, error: &error)
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    subscriberView3 = subscriber3!.view
                    guard (subscriberView3 != nil) else {
                        return
                    }
                    //torna o subscriberview como maior
                    if (subViewPos3 == nil) { subViewPos3 = self.defineViewPos() }
                    //cria o subscriberview
                    view.addSubview(subscriberView3!)
                    resizeView(actual, screenBounds.size)
                    //pega o nome do Subscriber
                    subscriberName3 = ((subscriber3!.stream?.name)!.components(separatedBy: " ").first)!
                    //identifica o role
                    if (self.roomParticipants != nil) {
                        for participant in self.roomParticipants! {
                            let participantObj  = participant as? Dictionary<String, AnyObject>
                            if (participantObj!["token"] == nil) {
                                let participantName = participantObj!["name"] as! String
                                if (participantName == subscriberName3) {
                                    let roleObj = participantObj!["role"] as? Dictionary<String, AnyObject>
                                    if (roleObj!["code"] != nil) {
                                        self.subscriberRole3 = roleObj!["code"] as! String
                                    }
                                }
                            }
                        }
                    }
                    //Define o toolbar
                    subscriberToolBar3 = UIToolbar()
                    subscriberToolBar3!.barStyle = UIBarStyle.default
                    subscriberToolBar3!.isTranslucent = true
                    subscriberToolBar3!.setBackgroundImage(onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
                    subscriberToolBar3!.tintColor = davTextColorVideoHeaderParticipant
                    subscriberView3!.addSubview(subscriberToolBar3!)
                    subscriberToolBar3!.translatesAutoresizingMaskIntoConstraints = false
                    subscriberToolBar3!.leadingAnchor.constraint(equalTo: subscriberView3!.leadingAnchor).isActive = true
                    subscriberToolBar3!.trailingAnchor.constraint(equalTo: subscriberView3!.trailingAnchor).isActive = true
                    subscriberToolBar3!.topAnchor.constraint(equalTo: subscriberView3!.topAnchor).isActive = true
                    //Adiciona os itens da Toolbar
                    itemsSub3.append(UIBarButtonItem(title: subscriberName3, style: .plain, target: nil, action: nil))
                    itemsSub3.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
                    if (publisherRole=="MMD"){
                        if (showButtonSnapshot == true) {
                            buttonPrintSub3 = UIBarButtonItem(image: UIImage(named: "print", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
                            style: .plain, target: self, action: #selector(togglePrintSub3))
                            itemsSub3.append(buttonPrintSub3!)
                        }
                    }
                    if (showButtonMicSub3 == true) {
                        buttonMicSub3 = UIBarButtonItem(image: UIImage(named: "volume-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
                        style: .plain, target: self, action: #selector(toggleMicSub3))
                        itemsSub3.append(buttonMicSub3!)
                    }
                    subscriberToolBar3!.setItems(itemsSub3, animated: true)
                    if (stream.videoType == .screen) {
                        self.alertMsg = subscriberName3 + " está apresentando a tela"
                        toggleCamSub3(sender: nil);
                    } else {
                        self.alertMsg = subscriberName3 + " entrou na sala"
                    }
                    self.showAlertAuto(self, dismissTime: 3)
                }
            } else {
                print("A stream (2) was created in the session.")
                actual = 2;
                subscriber2 = OTSubscriber(stream: stream, delegate: self)
                guard (subscriber2 != nil) else {
                    return
                }
                var error: OTError?
                session.subscribe(subscriber2!, error: &error)
                guard error == nil else {
                    print(error!)
                    return
                }
                subscriberView2 = subscriber2!.view
                guard (subscriberView2 != nil) else {
                    return
                }
                //torna o subscriberview como maior
                if (subViewPos2 == nil) { subViewPos2 = self.defineViewPos() }
                
                // cria o tap gesture
                tapSub2View = UITapGestureRecognizer(target: self, action: #selector(toggleCamSub2))
                subscriberView2!.isUserInteractionEnabled = true
                subscriberView2!.addGestureRecognizer(tapSub2View!)
                
                //cria o subscriberview
                view.addSubview(subscriberView2!)
                resizeView(actual, screenBounds.size)
                //pega o nome do Subscriber
                subscriberName2 = ((subscriber2!.stream?.name)!.components(separatedBy: " ").first)!
                //identifica o role
                if (self.roomParticipants != nil) {
                    for participant in self.roomParticipants! {
                        let participantObj  = participant as? Dictionary<String, AnyObject>
                        if (participantObj!["token"] == nil) {
                            let participantName = participantObj!["name"] as! String
                            if (participantName == subscriberName2) {
                                let roleObj = participantObj!["role"] as? Dictionary<String, AnyObject>
                                if (roleObj!["code"] != nil) {
                                    self.subscriberRole2 = roleObj!["code"] as! String
                                }
                            }
                        }
                    }
                }
                //Define o toolbar
                subscriberToolBar2 = UIToolbar()
                subscriberToolBar2!.barStyle = UIBarStyle.default
                subscriberToolBar2!.isTranslucent = true
                subscriberToolBar2!.setBackgroundImage(onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
                subscriberToolBar2!.tintColor = davTextColorVideoHeaderParticipant
                subscriberView2!.addSubview(subscriberToolBar2!)
                subscriberToolBar2!.translatesAutoresizingMaskIntoConstraints = false
                subscriberToolBar2!.leadingAnchor.constraint(equalTo: subscriberView2!.leadingAnchor).isActive = true
                subscriberToolBar2!.trailingAnchor.constraint(equalTo: subscriberView2!.trailingAnchor).isActive = true
                subscriberToolBar2!.topAnchor.constraint(equalTo: subscriberView2!.topAnchor).isActive = true
                //Adiciona os itens da Toolbar
                itemsSub2.append(UIBarButtonItem(title: subscriberName2, style: .plain, target: nil, action: nil))
                itemsSub2.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
                if (publisherRole=="MMD"){
                    if (showButtonSnapshot == true) {
                        buttonPrintSub2 = UIBarButtonItem(image: UIImage(named: "print", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
                        style: .plain, target: self, action: #selector(togglePrintSub2))
                        itemsSub2.append(buttonPrintSub2!)
                    }
                }
                if (showButtonMicSub2 == true) {
                    buttonMicSub2 = UIBarButtonItem(image: UIImage(named: "volume-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
                    style: .plain, target: self, action: #selector(toggleMicSub2))
                    itemsSub2.append(buttonMicSub2!)
                }
                subscriberToolBar2!.setItems(itemsSub2, animated: true)
                if (stream.videoType == .screen) {
                    self.alertMsg = subscriberName2 + " está apresentando a tela"
                    toggleCamSub2(sender: nil);
                } else {
                    self.alertMsg = subscriberName2 + " entrou na sala"
                }
                self.showAlertAuto(self, dismissTime: 3)
            }
        } else {
            actual = 1;
            print("A stream (1) was created in the session.")
            subscriber = OTSubscriber(stream: stream, delegate: self)
            guard (subscriber != nil) else {
                return
            }
            var error: OTError?
            session.subscribe(subscriber!, error: &error)
            guard error == nil else {
                print(error!)
                return
            }
            subscriberView = subscriber!.view
            guard (subscriberView != nil) else {
                return
            }
            //torna o subscriberview como maior
            if (subViewPos == nil) { subViewPos = self.defineViewPos() }
            
            // cria o tap gesture
            tapSubView = UITapGestureRecognizer(target: self, action: #selector(toggleCamSub))
            subscriberView!.isUserInteractionEnabled = true
            subscriberView!.addGestureRecognizer(tapSubView!)
            
            //cria o subscriberview
            view.addSubview(subscriberView!)
            resizeView(actual, screenBounds.size)
            //pega o nome do Subscriber
            subscriberName = ((subscriber!.stream?.name)!.components(separatedBy: " ").first)!
            //identifica o role
            if (self.roomParticipants != nil) {
                for participant in self.roomParticipants! {
                    let participantObj  = participant as? Dictionary<String, AnyObject>
                    if (participantObj!["token"] == nil) {
                        let participantName = participantObj!["name"] as! String
                        if (participantName == subscriberName) {
                            let roleObj = participantObj!["role"] as? Dictionary<String, AnyObject>
                            if (roleObj!["code"] != nil) {
                                self.subscriberRole = roleObj!["code"] as! String
                            }
                        }
                    }
                }
            }
            //Define o toolbar
            subscriberToolBar = UIToolbar()
            subscriberToolBar!.barStyle = UIBarStyle.default
            subscriberToolBar!.isTranslucent = true
            subscriberToolBar!.setBackgroundImage(onePixelImageWithColor(color: davBackgroundVideoHeaderParticipant!), forToolbarPosition: .any, barMetrics: UIBarMetrics.default)
            subscriberToolBar!.tintColor = davTextColorVideoHeaderParticipant
            subscriberView!.addSubview(subscriberToolBar!)
            subscriberToolBar!.translatesAutoresizingMaskIntoConstraints = false
            subscriberToolBar!.leadingAnchor.constraint(equalTo: subscriberView!.leadingAnchor).isActive = true
            subscriberToolBar!.trailingAnchor.constraint(equalTo: subscriberView!.trailingAnchor).isActive = true
            subscriberToolBar!.topAnchor.constraint(equalTo: subscriberView!.topAnchor).isActive = true
            // Adiciona os itens da Toolbar
            itemsSub.append(UIBarButtonItem(title: subscriberName, style: .plain, target: nil, action: nil))
            itemsSub.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil))
            if (publisherRole=="MMD"){
                if (showButtonSnapshot == true) {
                    buttonPrintSub = UIBarButtonItem(image: UIImage(named: "print", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
                    style: .plain, target: self, action: #selector(togglePrintSub))
                    itemsSub.append(buttonPrintSub!)
                }
            }
            if (showButtonMicSub == true) {
                buttonMicSub = UIBarButtonItem(image: UIImage(named: "volume-on", in: DavViewController.getBundle, compatibleWith: nil)!.withRenderingMode(.alwaysTemplate),
                style: .plain, target: self, action: #selector(toggleMicSub))
                itemsSub.append(buttonMicSub!)
            }
            subscriberToolBar!.setItems(itemsSub, animated: true)
            if (stream.videoType == .screen) {
                self.alertMsg = subscriberName + " está apresentando a tela"
                toggleCamSub(sender: nil);
            } else {
                self.alertMsg = subscriberName + " entrou na sala"
            }
            self.showAlertAuto(self, dismissTime: 3)
        }
        if (waitingView != nil) {
            waitingView!.isHidden = true
        }
        //verifica horário
        if (sessionInit == nil) {
            getDateInit()
        }
    }
    
    public func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        var participantName:String;
        
        var alertTitle:String="Doutor Ao Vivo"
        if (publisherName.count > 0) {
            alertTitle = publisherName
        }

        /// Caso seja a mesma conexão, alterna para o último
        if (stream.connection.connectionId == subscriber?.stream?.connection.connectionId) {
            toggleCamSub(sender: nil);
        }

        if (stream.connection.connectionId == subscriber2?.stream?.connection.connectionId) {
            toggleCamSub2(sender: nil);
        }
        if (stream.connection.connectionId == subscriber3?.stream?.connection.connectionId) {
            toggleCamSub3(sender: nil);
        }
        
        /// Correção Temporária quando uma view deixa um espaço entre views
        if (pubViewPos! > 1) {
            toggleCamPub(sender: nil)
            toggleCamSub(sender: nil)
        } else {
            toggleCamSub(sender: nil)
        }

        if (subscriber?.session == nil && subscriberView != nil) {
            subscriberView?.removeFromSuperview()
            participantName = subscriberName
            itemsSub.removeAll()
            subViewPos = nil
            subscriber = nil
            subscriberView = nil
            subscriberName = ""
            
            if (stream.videoType == .camera) {
                if (subscriberRole == "MMD") {
                    let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Sair da Sala", style: UIAlertAction.Style.default, handler: { action in
                        self.closeSala()
                        self.closeView()
                    }))
                    alertController.addAction(UIAlertAction(title: "Aguardar", style: UIAlertAction.Style.default, handler: { action in
                        alertController.dismiss(animated: true)
                    }))
                    present(alertController, animated: true, completion: nil)
                }
                self.alertMsg = participantName + " saiu da sala"
            } else {
                self.alertMsg = participantName + " parou de apresentar a tela"
            }
            self.showAlertAuto(self, dismissTime: 3)
        }
        if (subscriber2?.session == nil && subscriberView2 != nil) {
            subscriberView2?.removeFromSuperview()
            participantName = subscriberName2
            itemsSub2.removeAll()
            subViewPos2 = nil
            subscriber2 = nil
            subscriberView2 = nil
            subscriberName2 = ""
            if (stream.videoType == .camera) {
                if (subscriberRole2 == "MMD") {
                    let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Sair da Sala", style: UIAlertAction.Style.default, handler: { action in
                        self.closeSala()
                        self.closeView()
                    }))
                    alertController.addAction(UIAlertAction(title: "Aguardar", style: UIAlertAction.Style.default, handler: { action in
                        alertController.dismiss(animated: true)
                    }))
                    present(alertController, animated: true, completion: nil)
                }
                self.alertMsg = participantName + " saiu da sala"
            } else {
                self.alertMsg = participantName + " parou de apresentar a tela"
            }
            self.showAlertAuto(self, dismissTime: 3)
        }
        if (subscriber3?.session == nil && subscriberView3 != nil) {
            alertMsg = subscriberName3 + " saiu da sala"
            subscriberView3?.removeFromSuperview()
            participantName = subscriberName3
            itemsSub3.removeAll()
            subViewPos3 = nil
            subscriber3 = nil
            subscriberView3 = nil
            subscriberName3 = ""
            if (stream.videoType == .camera) {
                if (subscriberRole3 == "MMD") {
                    let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Sair da Sala", style: UIAlertAction.Style.default, handler: { action in
                        self.closeSala()
                        self.closeView()
                    }))
                    alertController.addAction(UIAlertAction(title: "Aguardar", style: UIAlertAction.Style.default, handler: { action in
                        alertController.dismiss(animated: true)
                    }))
                    present(alertController, animated: true, completion: nil)
                }
                self.alertMsg = participantName + " saiu da sala"
            } else {
                self.alertMsg = participantName + " parou de apresentar a tela"
            }
        }
    }
    
    // MARK: - OTPublisherDelegate callbacks
    public func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("The publisher failed: \(error)")
    }
    
    // MARK: - OTSubscriberDelegate callbacks
    public func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        print("The subscriber did connect to the stream.")
        
    }

    public func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("The subscriber failed to connect to the stream.")
    }
    
    // MARK: - Session Signal Listner
    public func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with signalString: String?) {
        print("Received signal \(type ?? ""): \(signalString ?? "") from \(connection!.connectionId) / \(session.connection?.connectionId ?? "")")
        let signalData = Data((signalString ?? "").utf8)
        if (type == "msg") {
            self.receiveChatSignal(chatMsgData: signalData, connectionId: connection!.connectionId)
        }
        if (type == "file") {
            self.receiveFileSignal(filesData: signalData)
        }
    }
    
    public func receiveChatSignal(chatMsgData: Data, connectionId: String) {
        do {
            if let chatMsgObj = try JSONSerialization.jsonObject(with: chatMsgData, options: []) as? [String:Any] {

                let Dateformatter = DateFormatter()
                Dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let cellDate:String=Dateformatter.string(from: Date())
                var cellMessage:String=""
                if (chatMsgObj["message"] != nil) {
                    cellMessage=chatMsgObj["message"] as! String
                }
                var cellParticipant:String="0"
                if (connectionId == session?.connection?.connectionId) {
                    cellParticipant = publisherId
                }
                var cellParticipantName:String=""
                if (chatMsgObj["user"] != nil) {
                    cellParticipantName=chatMsgObj["user"] as! String
                }
                self.chatController!.chatMessages.append(ChatMessage(chatMsgDate: cellDate, chatMsgText: cellMessage, chatMsgParticipant: cellParticipant, chatMsgParticipantName: cellParticipantName))
                self.chatController!.addMessageToView(cellDate: cellDate, cellParticipant: cellParticipant, cellParticipantName: cellParticipantName, cellMessage: cellMessage)
                self.chatController!.resizeScrollView()
                self.chatController!.scrollToBottom(animated: true)
                
                if (chatView != nil && chatView!.isHidden) {
                    self.alertMsg = "\(cellParticipantName) te enviou uma mensagem"
                    self.showAlertAuto(self, dismissTime: 3)
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    public func receiveFileSignal(filesData: Data) {
        do {
            if let filesObj = try JSONSerialization.jsonObject(with: filesData, options: []) as? [String:Any] {
//                print("Resultado em JSON: \(filesObj)")
                var cellDate:String=""
                if (filesObj["date"] != nil) {
                    cellDate=filesObj["date"] as! String
                }
                var cellEncoded:String=""
                if (filesObj["encoded"] != nil) {
                    cellEncoded=filesObj["encoded"] as! String
                }
                var cellPath:String=""
                if (filesObj["filePath"] != nil) {
                    cellPath=filesObj["filePath"] as! String
                }
                var cellName:String=""
                if (filesObj["nameOriginal"] != nil) {
                    cellName=filesObj["nameOriginal"] as! String
                }
                var cellParticipant:String="0"
                if (filesObj["participant"] != nil) {
                    cellParticipant=filesObj["participant"] as! String
                }
//                print("Resultado antes de atualizar tabela: \(cellPath)")
                self.archiveController!.filesList.append(FileShare(fileShareDate: cellDate, fileShareEncoded: cellEncoded, fileSharePath: cellPath, fileShareName: cellName, fileShareParticipant: cellParticipant))
                self.archiveController!.filesTableView.reloadData()
                if (fileListView != nil) {
                    if (fileListView!.isHidden == true) {
                        self.alertMsg = "Novo arquivo recebido"
                        self.showAlertAuto(self, dismissTime: 3)
                    }
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
        
    // MARK: - UIDocumentPickerDelegate Methods
        
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if let fileData = try? Data.init(contentsOf: url as URL) {
                let fileExtension = url.pathExtension
                let fileName = url.lastPathComponent
                let fileStream:String = fileData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
                let fileBase64:String = "data:\(fileExtension );base64,\(fileStream)"
                self.sendFileToServer(fileBase64: fileBase64, name: fileName)
            }
        }
    }
        
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
}


