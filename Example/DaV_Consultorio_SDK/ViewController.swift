//
//  ViewController.swift
//  DaV_Consultorio
//
//  Created by fabiooh on 02/11/2020.
//  Copyright (c) 2020 fabiooh. All rights reserved.
//

import UIKit
import DaV_Consultorio_SDK

class ViewController: UIViewController {

    @IBOutlet weak var btOpenDaV: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        btOpenDaV.addTarget(self, action: #selector(openDavView), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openDavView(_sender: Any) {
        
        let davVC = DavViewController()
                    
        davVC.DAV_URL_ACCESS = "https://demonstracao.dav.med.br/a/mc2hn10bkn"
        davVC.davColorPrimary = UIColor.white
        davVC.davBackgroundActionsRoom = UIColor(red: 25/255.0 , green: 45/255.0, blue: 175/255.0, alpha: 1.0)
        davVC.davBackgroundVideoHeaderParticipant = UIColor.darkGray
        davVC.davTextColorVideoHeaderParticipant = UIColor.lightGray
        davVC.davTextColorButtonActionsRoom = UIColor.white
        davVC.davBackgroundButtonEndCallActionsRoom = UIColor(red: 255/255.0 , green: 0, blue: 13/255.0, alpha: 1.0)
        davVC.davBackgroundButtonActionsRoom = UIColor(red: 255/255.0 , green: 0, blue: 13/255.0, alpha: 1.0)
        davVC.davBackgroundBallonOtherColor = UIColor(red: 255/255.0 , green: 0, blue: 13/255.0, alpha: 1.0)
        davVC.davTextColorBallonOther = UIColor(red: 255/255.0 , green: 0, blue: 13/255.0, alpha: 1.0)
        davVC.davBackgroundBallonMineColor = UIColor(red: 255/255.0 , green: 0, blue: 13/255.0, alpha: 1.0)
        davVC.davTextColorballonMine = UIColor(red: 255/255.0 , green: 0, blue: 13/255.0, alpha: 1.0)
        
        self.present(davVC, animated: true, completion: nil)
    }

  
}

