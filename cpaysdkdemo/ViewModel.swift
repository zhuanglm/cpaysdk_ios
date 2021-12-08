//
//  ViewModel.swift
//  cpaysdkdemo
//
//  Created by Raymond Zhuang on 2021-10-21.
//

import Foundation
import SwiftUI
import CPaySDK

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first {$0.isKeyWindow}
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension Dictionary {
    
    func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
     }
    
}

class ViewModel: ObservableObject {
    //private var mOrder: CPayOrder = CPayOrder()

    let paymentMethod = CPayMethodType.ALI_HK
    @Published var mOrderResult: String = ""
    
    func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func startTestView() {
        let cpayReq: CPayRequest = CPayBuilder()
            .amount("100")
            .reference("123456789")
            .build(type: paymentMethod)
        
        if let keyWindow = UIWindow.key {
            cpayReq.start(keyWindow.rootViewController!) { retVal in
                print("return: \(retVal.result)\n")
            }
        }
    
    }
    
//    private func setupSDK(token: String, mode: Int) {
//        CPayManager.setupTokenKey(token)
//        CPayManager.setupMode(CPayMode.init(rawValue: mode) ?? CPayMode.UAT)
//    }
    
    func requestOrder(token: String, mode: Int, reference: String, amount: Int, subject: String, body: String, currency: String, vendor: CPayMethodType, allowDuplicate: Bool, extra: Dictionary<String, String>) {
        //self.setupSDK(token: token, mode: mode)
//        mOrder.amount = String(amount)
//        mOrder.referenceId = reference
//        mOrder.subject = subject
//        mOrder.body = body
//        mOrder.currency = currency
//        mOrder.vendor = vendor.rawValue
//        mOrder.allowDuplicate = allowDuplicate
//        mOrder.ipnUrl = "ipn.php"
//        mOrder.callbackUrl = "citcon.com"
//        mOrder.extra = extra.toJsonString()
//        if let keyWindow = UIWindow.key {
//            mOrder.controller = keyWindow.rootViewController!
//        }                    // required for upop payment
//        mOrder.scheme = "cpaydemo.citconpay.com"  // (required) your app scheme for alipay payment, set in the Info.plist
//
//        CPayManager.request(mOrder) { result in
//            self.mOrderResult = result?.message ?? "" + String(result?.resultStatus ?? 0)
//        }
        
        let cpayReq: CPayRequest = CPayBuilder()
            .token(token)
            .envMode(CPayENVMode.init(rawValue: mode) ?? CPayENVMode.UAT)
            .amount(String(amount))
            .reference(reference)
            .subject(subject)
            .body(body)
            .currency(currency)
            .ipnUrl("ipn.php")
            .callback("citcon.com")
            .setAllowDuplicate(allowDuplicate)
            .extra(extra.toJsonString() ?? "")
            .build(type: vendor)
        
        if let keyWindow = UIWindow.key {
            cpayReq.start(keyWindow.rootViewController!) { retVal in
                print("return: \(retVal.result)\n")
            }
        }
    }
    
//    @objc func onOrderComplete(_ notification: NSNotification) {
//        let result = notification.object as! CPayCheckResult
//        //print("TransId: \(result.referenceId)\n Amount: \(result.amount)\n code: \(result.code)\n status: \(result.status)")
//
//        self.mOrderResult = String(format: "status: %@  reference: %@ transaction: %@", result.status, result.referenceId, result.transactionId)
//    }
    
//    func registerNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(onOrderComplete), name: NSNotification.Name(kOrderPaymentFinishedNotification), object: nil)
//    }
//
//    func unregisterNotification() {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kOrderPaymentFinishedNotification), object: nil)
//    }
    
}
