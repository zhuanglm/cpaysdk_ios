//
//  NextViewController.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-02.
//

import UIKit
import SwiftUI

extension UIWindow {
    var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }

    static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
    
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first {$0.isKeyWindow}
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

protocol ReturnValDelegate {
    func sendVal(_ result: CPayResult)
}

class PortalViewController: UIViewController {
    var payRequest: CPayRequest?
    var returnDelegate: ReturnValDelegate?
    var paymentMethod: CPayMethodType
    var nextView: PortalView?
    
    init(method: CPayMethodType) {
        paymentMethod = CPayMethodType.NONE
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        nextView = PortalView(request: payRequest)
        let nextViewController = UIHostingController(rootView: nextView)
        let subView = nextViewController.view
        
        subView?.backgroundColor = .clear
        
        nextViewController.view.frame = view.bounds
        addChild(nextViewController)
        nextViewController.didMove(toParent: self)
        view.addSubview(nextViewController.view)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(returnDelegate != nil && nextView != nil) {
            returnDelegate?.sendVal(nextView?.result ?? CPayResult(""))
        }
    }

}
