//
//  ViewController.swift
//  Free Calls
//
//  Created by Yash Bedi on 23/04/19.
//  Copyright © 2019 Yash Bedi. All rights reserved.
//

import UIKit


class ViewController: BaseViewController {
    
    
    @IBOutlet weak var userIdTextField: UITextField!
    
    
    var client : SINClient? {
        return AppDelegate.shared.client
    }
    
    var name = ""
    
    //public var cxProvider : CXProvider!
    //    static var configForCAllKit : CXProviderConfiguration {
    //        let config = CXProviderConfiguration(localizedName: APPLICATION_NAME)
    //        config.iconTemplateImageData = UIImagePNGRepresentation(UIImage(named:"voipBlack")!)
    //        config.ringtoneSound = "incoming.wav"
    //        config.supportsVideo = false
    //        config.maximumCallsPerCallGroup = 1
    //        config.supportedHandleTypes = [.generic]
    //        return config
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(openVcWhenCallComes(notification:)), name: NSNotification.Name.init("inComingCall"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(sendCallStatusToSystem(_:)), name: NSNotification.Name.init("openCxCallVC"), object: nil)
    }
    
    @IBAction func intialiseButtonClicked(_ sender: Any) {
        name = userIdTextField.text!
        if name.compare("") == ComparisonResult.orderedSame{
            self.showAlert("", message: "Enter name to intialise your client")
        }else{
            self.client?.stop()
            self.client?.terminateGracefully()
            self.client?.stopListeningOnActiveConnection()
            
            AppDelegate.shared.client = nil
            AppDelegate.shared.sinCallManager = nil
            
            AppDelegate.shared.initSinchClientWithUserID(userID: name)
            AppDelegate.shared.initDelegates()
            
            UserDefaults.standard.set(name, forKey: "sinchClientId")
            userIdTextField.text = ""
            self.view.endEditing(true)
        }
    }
    
    @IBAction func pushButtonClicked(_ sender: Any) {
        
        if userIdTextField.text?.compare("") == ComparisonResult.orderedSame{
            showAlert("", message: "Please Enter User Id")
        }else{
            guard
                self.client != nil else {
                    self.showAlert("Sinch Client not", message: "Intitialised.!")
                    return
            }
            let remoteClientName : String = userIdTextField.text!
            if (self.client?.isStarted())!{
                AppDelegate.shared.sinCallManager?.currentCall = AppDelegate.shared.sinCallManager?.client.call().callUser(withId: remoteClientName)
                //AppDelegate.shared.sinCallManager?.startTheCall(withUserId: remoteClientName)
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
                vc.isInComingCall = false
                vc.userId = remoteClientName
                //vc.call = call
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.showAlert("Please wait Inititalising...", message: "Sinch Client")
                
                AppDelegate.shared.initSinchClientWithUserID(userID: name)
                return
            }
        }
    }
    
    @objc func openVcWhenCallComes(notification : Notification){
        print(notification)
        guard
            let call = notification.object as? SINCall else {return}
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        vc.isInComingCall = true
        vc.userId = call.remoteUserId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //    private func initForCallKit(){
    //        cxProvider = CXProvider(configuration: type(of: self).configForCAllKit)
    //        cxProvider.setDelegate(self, queue: nil)
    //    }
    
    //    @objc func sendCallStatusToSystem(_ notif : Notification){
    //        print("-- > notification data : ",notif)
    //        initForCallKit()
    //        if let handle = notif.userInfo![AnyHashable("userId")] as? String {
    //            let update = CXCallUpdate()
    //            update.remoteHandle = CXHandle(type: .generic, value: handle)
    //            let uuid = UUID(uuidString: "")
    //            cxProvider.reportNewIncomingCall(with: uuid!, update: update, completion: { error in
    //                if error != nil{
    //                    print("Error Presenting CALLkitVC : ",error?.localizedDescription)
    //                }else{
    //                    print("Yayy Success.. Presenting CALLkitVC")
    //                }
    //            })
    //        }
    //    }
    
}

/*extension ViewController : CXProviderDelegate {
 func providerDidReset(_ provider: CXProvider) {
 
 }
 
 func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
 action.fulfill()
 self.call?.delegate = self
 self.audioController.stopPlayingSoundFile()
 call?.answer()
 
 //self.answerCall(self.call!)
 }
 
 func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
 action.fulfill()
 self.makeTheCallObjectNil()
 }
 }
 */

extension ViewController{
    func showAlert(_ title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .destructive,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /*
     var superVieww = UIView()
     var childVieww = UIView()
     var imageVieww = UIImageView()
     let size = 200
     
     // MARK : CODE FOR TESTING..
     
     func circleTheViews(){
     superVieww.frame.size = CGSize(width: size, height: size)
     superVieww.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
     superVieww.backgroundColor = UIColor.darkGray
     
     self.view.addSubview(superVieww)
     
     childVieww.frame.size = CGSize(width: size - 20, height: size - 20)
     childVieww.center = CGPoint(x: self.superVieww.bounds.midX, y: self.superVieww.bounds.midY)
     childVieww.backgroundColor = UIColor.black
     
     superVieww.addSubview(childVieww)
     
     imageVieww.frame.size = CGSize(width: size - 40, height: size - 40)
     imageVieww.center = CGPoint(x: self.childVieww.bounds.midX, y: self.childVieww.bounds.midY)
     imageVieww.backgroundColor = UIColor.green
     imageVieww.contentMode = .scaleAspectFill
     imageVieww.image = UIImage(named:"profile.jpg")
     
     childVieww.addSubview(imageVieww)
     }
     
     override func viewDidLayoutSubviews() {
     superVieww.layer.cornerRadius = superVieww.frame.width / 2
     superVieww.layer.masksToBounds = true
     
     childVieww.layer.cornerRadius = childVieww.frame.width / 2
     childVieww.layer.masksToBounds = true
     
     imageVieww.layer.cornerRadius = imageVieww.frame.width / 2
     imageVieww.layer.masksToBounds = true
     
     }
     */
}

