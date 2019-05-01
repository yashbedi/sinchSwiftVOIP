//
//  AppDelegate.swift
//  Free Calls
//
//  Created by Yash Bedi on 23/04/19.
//  Copyright © 2019 Yash Bedi. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    class var shared : AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var push: SINManagedPush?
    var client: SINClient?
    
    var callProviderDelegate : CallProviderDelegate?
    var sinCallManager : SinCallManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let clientId = UserDefaults.standard.string(forKey: "sinchClientId"){
            initSinchClientWithUserID(userID: clientId)
        }else{
            //initSinchClientWithUserID(userID: "clientId")
        }
        
        initDelegates()
        
        push = Sinch.managedPush(with: SINAPSEnvironment.development)
        push?.delegate = self
        push?.setDesiredPushType(SINPushTypeVoIP)
        
        //if logged in
        push?.registerUserNotificationSettings()
        
        return true
    }
    
    func initDelegates(){
        if let client = client, sinCallManager == nil{
            sinCallManager = SinCallManager(client: client)
            callProviderDelegate = CallProviderDelegate(callManager: sinCallManager ?? SinCallManager(client: client))
        }else{
            print("We have a problem in app delegate!")
        }
    }
    
    func initSinchClientWithUserID (userID: String) {
        if client == nil {
            client = Sinch.client(withApplicationKey: APPLICATION_KEY, applicationSecret: APPLICATION_SECRET, environmentHost: "clientapi.sinch.com", userId: userID)
            client?.setSupportCalling(true)
            client?.setSupportMessaging(false)
            client?.enableManagedPushNotifications()
            client?.delegate = self
            client?.call().delegate = self
            client?.start()
            client?.startListeningOnActiveConnection()
        }
    }
}

extension AppDelegate : SINCallClientDelegate {
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        let notification = SINLocalNotification()
        notification.alertBody = "Incoming call from : \(call.remoteUserId!)"
        return notification
    }
    
    // this func is called when app is in foreground/or comes to foreground
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("Received a call from: \(call.remoteUserId ?? "")")
        
        sinCallManager?.currentCall = call
        
        NotificationCenter.default.post(name: NSNotification.Name.init("inComingCall"), object: call, userInfo: ["callObj":call])
    }
    
    // this func is called when app is in background
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        print("Received a call from: \(call.remoteUserId ?? "")")
        
        if UIApplication.shared.applicationState != .active {
            callProviderDelegate?.inComingCall(call: call)
            sinCallManager?.isComingFromCX = true
        }
    }
}

extension AppDelegate : SINManagedPushDelegate {
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        handleRemoteNotification(userInfo: payload)
    }
    
    func handleRemoteNotification(userInfo: [AnyHashable : Any]) {
        print(userInfo)
        let result = client?.relayRemotePushNotification(userInfo)
        
        guard let resultIsCall = result?.isCall(), let callCancelled = result?.call().isTimedOut else { return }
        
        if let aps = userInfo[AnyHashable("aps")] as? NSDictionary {
            if let alert = aps.value(forKey: "alert") as? NSDictionary{
                if let callState = alert.value(forKey: "loc-key") as? String{
                    if callState.compare(SINCH_CALL_STATES.Cancelled.rawValue) == ComparisonResult.orderedSame{
                        if let call = sinCallManager?.currentCall {
                            sinCallManager?.endingThe(call: call)
                        }
                        /*if UIApplication.shared.applicationState != UIApplicationState.active{
                         
                         // NotificationCenter.default.post(name: NSNotification.Name.init("openCxCallVC"), object: nil, userInfo: ["userId":result?.call().remoteUserId as! String])
                         }*/
                    }else{
                        // post a notification to dismiss cxcallcontroller
                    }
                }
            }
        }
    }
}

extension AppDelegate: SINClientDelegate   {
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully (version: \(Sinch.version())")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Error starting Sinch: \(error.localizedDescription)")
    }
    
    func client(_ client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: Date!) {
        if let message = message {
            //            print("**SINCH-LOG**: \(message)")
        }
    }
}



