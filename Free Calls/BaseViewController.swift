//
//  BaseViewController.swift
//  Free Calls
//
//  Created by Yash Bedi on 25/04/19.
//  Copyright © 2019 Yash Bedi. All rights reserved.
//

import UIKit


class BaseViewController : UIViewController {
    
    public var audioController : SINAudioController {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return (appDelegate.client?.audioController())!
    }
    
    //public var call: SINCall?

    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
}


extension BaseViewController {
    
    /*public func makeTheCallObjectNil(){
        self.audioController.stopPlayingSoundFile()
        //call?.hangup()
        //self.call = nil
    }*/
    
    /*public func answerCall(_ sinCall : SINCall){
        self.audioController.stopPlayingSoundFile()
        //call?.answer()
    }*/
    
    func path(forSound soundName: String) -> String? {
        var stringUrl = ""
        if let audioPath = Bundle.main.path(forResource: soundName, ofType: "wav") {
            //print("===: ",audioPath)
            stringUrl = audioPath
        }
        return stringUrl
    }
}
