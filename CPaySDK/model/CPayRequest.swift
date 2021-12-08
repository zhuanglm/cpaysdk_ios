//
//  CPayRequest.swift
//  
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import Foundation
import UIKit

protocol CPayRequestBuilder {
    func build(type: CPayMethodType) -> CPayRequest
}

public class CPayBuilder: CPayRequestBuilder {
        
    private var referenceId: String = ""
    private var amount: String = "0"
    private var  currency: String = ""
    private var  subject: String = ""
    private var  body: String = ""
    private var  ipnUrl: String = ""
    private var  callbackUrl: String = ""
    private var  allowDuplicate = true
    private var extra = ""
    private var token = ""
    private var mode = CPayENVMode.UAT
    
    public init() {
    }
    
    public func build(type: CPayMethodType) -> CPayRequest {
        let request = CPayRequest()
        
        request.mAmount = amount
        request.mReference = referenceId
        request.mPaymentMethodType = type
        request.mCurrency = currency
        request.mSubject = subject
        request.mBody = body
        request.mIpnUrl = ipnUrl
        request.mCallbackUrl = callbackUrl
        request.mAllowDuplicate = allowDuplicate
        request.mExtra = extra
        
        return request
    }
    
    public func token(_ token: String) -> CPayBuilder {
        self.token = token
        return self
    }
    
    public func envMode(_ mode: CPayENVMode) -> CPayBuilder {
        self.mode = mode
        return self
    }
    
    public func amount(_ amount: String) -> CPayBuilder {
        self.amount = amount
        return self
    }
    
    public func reference(_ ref: String) -> CPayBuilder {
        self.referenceId = ref
        return self
    }
    
    public func currency(_ currency: String) -> CPayBuilder {
        self.currency = currency
        return self
    }
    
    public func subject(_ subject: String) -> CPayBuilder {
        self.subject = subject
        return self
    }
    
    public func body(_ body: String) -> CPayBuilder {
        self.body = body
        return self
    }
    
    public func ipnUrl(_ ipn: String) -> CPayBuilder {
        self.ipnUrl = ipn
        return self
    }
    
    public func callback(_ callback: String) -> CPayBuilder {
        self.callbackUrl = callback
        return self
    }
    
    public func setAllowDuplicate(_ flag: Bool) -> CPayBuilder {
        self.allowDuplicate = flag
        return self
    }
    
    public func extra(_ extra: String) -> CPayBuilder {
        self.extra = extra
        return self
    }
}

public typealias ResultClosure = (CPayResult) -> Void

public class CPayRequest: ReturnValDelegate {
    var mToken: String = ""
    var mMode: CPayENVMode = CPayENVMode.UAT
        
    //UPI SDK
    var mPaymentMethodType: CPayMethodType = CPayMethodType.NONE
    var mAccessToken: String = ""
    var mChargeToken: String = ""
    var mReference: String = ""
    var mConsumerID: String = ""
    
    //CPaySDK CPayOrder
    var  mAmount: String = ""
    var  mCurrency: String = ""
    var  mSubject: String = ""
    var  mBody: String = ""
    var  mIpnUrl: String = ""
    var  mCallbackUrl: String = ""
    var  mAllowDuplicate = true
    var  mExtra = ""
    
    var resultClosure:ResultClosure?
    
    func paymentMethod(method: CPayMethodType) -> CPayRequest {
        self.mPaymentMethodType = method
        return self
    }
    
    func amount(_ amount: String) -> CPayRequest {
        mAmount = amount
        return self
    }
    
    func reference(_ ref: String) -> CPayRequest {
        mReference = ref
        return self
    }
    
    func sendVal(_ result: CPayResult) {
        //print("return: \(String(describing: result.result))\n")
        
        resultClosure!(result)
        
    }
    
    //private var mOrder: CPayOrder = CPayOrder()
    private var mViewController: NextViewController
    
    public init() {
        mPaymentMethodType = CPayMethodType.NONE
        mViewController = NextViewController(method: mPaymentMethodType)
    }
    
    public func start(_ viewController: UIViewController, resultClosure: ResultClosure? = nil) {
        mViewController.returnDelegate = self
        viewController.present(mViewController, animated: true) {
            self.resultClosure = resultClosure
        }
        
    }
}
