//
//  CPayRequest.swift
//  
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import Foundation
import CPay

public class CPayRequest {
    private var mOrder: CPayOrder = CPayOrder()
    let mViewController = NextViewController()
    
    public init() {
    
    }
    
    public func startView(_ viewController: UIViewController) {
        viewController.present(mViewController, animated: false) {
            
        }
    }
}
