//
//  SinCallManager.swift
//  Free Calls
//
//  Created by Yash Bedi on 25/04/19.
//  Copyright © 2019 Yash Bedi. All rights reserved.
//

import Foundation
import CallKit

class SinCallManager : NSObject{
    
    var client: SINClient
    
    var audioController: SINAudioController {
        return client.audioController()
    }
    //var outGoingCall : SINCall?
    //var sinCall = [SINCall]()
    
    var currentCall : SINCall?
    
    var isComingFromCX : Bool
    
    private let callController = CXCallController()
    
    var currentCallStatus: SINCallState {
        return currentCall?.state ?? SINCallState.ended
    }
    
    init(client : SINClient) {
        self.client = client
        isComingFromCX = false
        super.init()
    }
    
    /*func preparingIncomingCall(call : SINCall){
        self.currentCall = call
    }*/
    
    /*func getOngoingCall() -> SINCall?{//returnCallWithUUID(uuid:String) -> SINCall{
        if currentCall != nil{
            return currentCall
        }else{
            return nil
        }
    }*/
    /*func returnCallWithHandle(handle:String) -> SINCall{
        return sinCall[0]
    }*/
    
    
    func startTheCall(withUserId:String){
        currentCall = client.call().callUser(withId: withUserId)
        
        guard let uuid = UUID(uuidString: currentCall?.callId ?? "" ) else {
            return
        }
        
        let handle = CXHandle(type: .generic, value: withUserId)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        
        let cxTransaction = CXTransaction(action: startCallAction)
        
        registerTransaction(onCxCallVC: cxTransaction)
    }
    
    func endingThe(call:SINCall){
        let endCallAction = CXEndCallAction(call: call.uuid)
        let cxTransaction = CXTransaction(action: endCallAction)
        registerTransaction(onCxCallVC: cxTransaction)
    }
    
    
    func setHold(call: SINCall, onHold: Bool) {
        let setHoldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let cxTransaction = CXTransaction(action: setHoldCallAction)
        registerTransaction(onCxCallVC: cxTransaction)
    }
    
    func setMute(call: SINCall, mute: Bool) {
        let setMuteCallAction = CXSetMutedCallAction(call: call.uuid, muted: mute)
        let cxTransaction = CXTransaction(action: setMuteCallAction)
        registerTransaction(onCxCallVC: cxTransaction)
    }
    
    fileprivate func registerTransaction(onCxCallVC transaction: CXTransaction){
        callController.request(transaction){ error in
            if let error = error {
                print("Error requesting transaction: \(error.localizedDescription)")
            } else {
                print("Requested transaction successfully:")
            }
        }
    }
    
    
}
