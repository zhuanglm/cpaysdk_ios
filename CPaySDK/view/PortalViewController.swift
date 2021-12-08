//
//  NextViewController.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-02.
//

import UIKit
import SwiftUI

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
        //nextView = PortalView(method: paymentMethod)
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
        
        if(returnDelegate != nil) {
            //returnDelegate?.sendVal(message: "zlm loaded")
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(returnDelegate != nil && nextView != nil) {
            returnDelegate?.sendVal(nextView?.result ?? CPayResult(""))
        }
    }

}
