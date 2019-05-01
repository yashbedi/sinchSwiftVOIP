//
//  Helper.h
//  Free Calls
//
//  Created by Yash Bedi on 25/04/19.
//  Copyright © 2019 Yash Bedi. All rights reserved.
//

import Foundation
import UIKit

let APPLICATION_KEY = "7e369ef0-8589-4277-a5fe-86cab42836ae"
let APPLICATION_SECRET = "VCeBUxc+3kaC9KQAqNENCg=="
let APPLICATION_NAME = "yb_FreeCalls"


public enum SINCH_CALL_STATES : String {
    case Incoming = "SIN_INCOMING_CALL"
    case Cancelled = "SIN_CANCEL_CALL"
}

extension SINCall {
    
    var uuid: UUID {
        return UUID(uuidString: self.callId)!
    }
}
/*public struct UserCallInfo {
    let userId : String
    //let timeStamp : String
    let sinchCallType : String
}*/



















extension UIViewController {
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: (self.view.frame.size.width * 0.1), y: self.view.frame.size.height-150, width: (self.view.frame.size.width * 0.8), height: 35))
        toastLabel.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.black
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.layer.borderWidth = 0.8
        toastLabel.layer.borderColor = UIColor.black.cgColor
        toastLabel.clipsToBounds  =  true
        UIApplication.topViewController()?.view.addSubview(toastLabel)
        //self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
