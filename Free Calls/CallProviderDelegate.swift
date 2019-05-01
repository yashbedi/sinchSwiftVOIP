//
//  CallProviderDelegate.swift
//  Free Calls
//
//  Created by Yash Bedi on 25/04/19.
//  Copyright © 2019 Yash Bedi. All rights reserved.
//

import Foundation
import CallKit


class CallProviderDelegate : NSObject{
    
    let cxProvider : CXProvider
    var client : SINClient
    let sinCallManager : SinCallManager
    
    init(callManager : SinCallManager) {
        
        self.sinCallManager = callManager
        
        self.cxProvider = CXProvider(configuration: type(of: self).configForCAllKit)
        
        self.client = callManager.client
        
        super.init()
        
        cxProvider.setDelegate(self, queue: nil)
    }
 
    static var configForCAllKit : CXProviderConfiguration {
        let config = CXProviderConfiguration(localizedName: APPLICATION_NAME)
        config.iconTemplateImageData = UIImage(named:"voipBlack")!.pngData()
        config.ringtoneSound = "incoming.wav"
        config.supportsVideo = false
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.generic]
        return config
    }
    
    
    func inComingCall(call : SINCall){
        let handle = call.remoteUserId!
        let uuid = UUID(uuidString: call.callId!)
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: CXHandle.HandleType.generic , value: handle)
        
        cxProvider.reportNewIncomingCall(with: uuid!, update: callUpdate) { error in
            print("Error : ",error?.localizedDescription)
            if error == nil{
                self.sinCallManager.currentCall = call
            }
        }
    }
}



extension CallProviderDelegate : CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = sinCallManager.currentCall else {
            action.fail()
            return
        }
        call.answer()
        
        DispatchQueue.global().sync {
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.mixWithOthers)
            _ = try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            
            _ = try? AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.voiceChat)
            
            do {
                _ = try AVAudioSession.sharedInstance().setActive(true)
            } catch (let error){
                print("audio session error: \(error)")
            }
        }

        action.fulfill()
        
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        client.call().provider(provider, didActivate: audioSession)
        //client.audioController().unmute()
        //callManager.reloadTable?()
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = sinCallManager.currentCall else {
            action.fail()
            return
        }
        call.hangup()
        self.sinCallManager.endingThe(call: call)
        action.fulfill()
    }
    
    
    /*func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
        print(action.callUUID)
        if sinCallManager.currentCallStatus != .ended {
            action.fulfill()
            
        }
    }*/
    
    
    func reportOutgoingStarted(uuid: UUID) {
        self.cxProvider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }
    
    func reportOutoingConnected(uuid: UUID) {
        self.cxProvider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
    
    
}
