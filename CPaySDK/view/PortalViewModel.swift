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
    var orderResult: String = ""
    var isRequsted = false
    
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
                self.setupSDK(token: request.mToken, mode: request.mEnvMode.rawValue)
                self.isRequsted = true
                registerNotification()
                
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
                    order.controller = UIWindow.getVisibleViewControllerFrom(keyWindow.rootViewController)
                }
                
                order.scheme = "cpaydemo.citconpay.com"  // (required) your app scheme for alipay payment, set in the Info.plist
                
                CPayManager.request(order) { result in
                    self.orderResult = result?.message ?? "" + String(result?.resultStatus ?? 0)
                    self.isRequsted = false
                }
                
            default:
                print( "default start case")
        }
    }
    
    func inquire(_ request: CPayRequest) {
        if(self.paymentRequest != nil && self.paymentRequest?.mReference == request.mReference) {
            switch request.mPaymentMethodType {
                case CPayMethodType.UPOP:
                    //in case of union pay has not been installed
                    CPayManager.inquireResult(byRef: request.mReference, currency: request.mCurrency, method: "real", vendor: request.mPaymentMethodType.rawValue, completion: {result in
                        if(result?.transactionId != nil) {
                            self.returnResult(result: result!)
                        }
                        
                    })
                default:
                    print( "default inquire case")
            }
        }
    }
    
    private func setupSDK(token: String, mode: Int) {
        CPayManager.setupTokenKey(token)
        CPayManager.setupMode(CPayMode.init(rawValue: mode) ?? CPayMode.UAT)
    }
    
    private func returnResult(result: CPayCheckResult) {
        self.orderResult = String(format: "status: %@  reference: %@ transaction: %@", result.status, result.referenceId, result.transactionId)
        
        self.unregisterNotification()
        self.shouldDismissView = true
    }
    
    @objc func onOrderComplete(_ notification: NSNotification) {
        let result = notification.object as! CPayCheckResult
        
        self.returnResult(result: result)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onOrderComplete), name: NSNotification.Name(kOrderPaymentFinishedNotification), object: nil)
    }
    
    func unregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kOrderPaymentFinishedNotification), object: nil)
    }
}
