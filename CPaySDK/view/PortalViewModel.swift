//
//  PortalViewModel.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-08.
//

import Foundation
import Combine
import CPay


class PortalViewModel: ObservableObject {
    var paymentRequest: CPayRequest?
    var mOrderResult: String = ""
    
    let viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    func startRequst(_ request: CPayRequest) {
        self.paymentRequest = request
        
        switch request.mPaymentMethodType {
            case CPayMethodType.ALI_HK, CPayMethodType.ALI, CPayMethodType.DANA, CPayMethodType.KAKAO, CPayMethodType.WECHAT, CPayMethodType.UPOP:
                self.setupSDK(token: request.mToken, mode: request.mMode.rawValue)
                
                let order = CPayOrder()
                order.amount = String(request.mAmount)
                order.referenceId = request.mReference
                order.subject = request.mSubject
                order.body = request.mBody
                order.currency = request.mCurrency
                order.vendor = request.mPaymentMethodType.rawValue
                order.allowDuplicate = request.mAllowDuplicate
                order.ipnUrl = "ipn.php"
                order.callbackUrl = "citcon.com"
                order.extra = request.mExtra
                if let keyWindow = UIWindow.key {
                    order.controller = keyWindow.rootViewController!
                }
                order.scheme = "cpaydemo.citconpay.com"  // (required) your app scheme for alipay payment, set in the Info.plist
                
                CPayManager.request(order) { result in
                    self.mOrderResult = result?.message ?? "" + String(result?.resultStatus ?? 0)
                }
                
            default:
                print( "default case")
        }
    }
    
    private func setupSDK(token: String, mode: Int) {
        CPayManager.setupTokenKey(token)
        CPayManager.setupMode(CPayMode.init(rawValue: mode) ?? CPayMode.UAT)
    }
    
    @objc func onOrderComplete(_ notification: NSNotification) {
        let result = notification.object as! CPayCheckResult
        //print("TransId: \(result.transactionId ?? "")\n Amount: \(result.amount ?? "")\n ref: \(result.referenceId ?? "")\n status: \(result.status ?? "")")
        
        self.mOrderResult = String(format: "status: %@  reference: %@ transaction: %@", result.status, result.referenceId, result.transactionId)
        
        self.shouldDismissView = true
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onOrderComplete), name: NSNotification.Name(kOrderPaymentFinishedNotification), object: nil)
    }
    
    func unregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kOrderPaymentFinishedNotification), object: nil)
    }
}
