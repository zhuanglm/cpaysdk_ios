//
//  CPayRequest.swift
//  
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import Foundation
import CPay

protocol CPayRequestBuilder {
    func build(type: CitconPaymentMethodType) -> CPayRequest

}

public class CPayBuilder: CPayRequestBuilder {
    private var referenceId: String = ""
    private var amount: String = "0"
    
    public init() {
    }
    
    public func build(type: CitconPaymentMethodType) -> CPayRequest {
        return CPayRequest().paymentMethod(method: type)
            .amount(amount)
            .reference(referenceId)
    }
    
    public func amount(_ amount: String) -> CPayBuilder {
        self.amount = amount
        return self
    }
    
    public func reference(_ ref: String) -> CPayBuilder {
        self.referenceId = ref
        return self
    }
}

public typealias ResultClosure = (CPayResult) -> Void

public class CPayRequest: ReturnValDelegate {
    var paymentMethod: CitconPaymentMethodType
    
    //UPI SDK
    private var mPaymentMethodType: CitconPaymentMethodType = CitconPaymentMethodType.NONE
    private var mAccessToken: String = ""
    private var mChargeToken: String = ""
    private var mReference: String = ""
    private var mConsumerID: String = ""
    
    //CPaySDK CPayOrder
    private var  mAmount: String = ""
    private var  mCurrency: String = ""
    private var  mSubject: String = ""
    private var  mBody: String = ""
    private var  mIpnUrl: String = ""
    private var  mCallbackUrl: String = ""
    private var  mAllowDuplicate = true
    
    var resultClosure:ResultClosure?
    
    func paymentMethod(method: CitconPaymentMethodType) -> CPayRequest {
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
    
    private var mOrder: CPayOrder = CPayOrder()
    private var mViewController: NextViewController
    
    public init() {
        paymentMethod = CitconPaymentMethodType.NONE
        mViewController = NextViewController(method: paymentMethod)
    }
    
    public func start(_ viewController: UIViewController, resultClosure: ResultClosure? = nil) {
        mViewController.returnDelegate = self
        viewController.present(mViewController, animated: true) {
            self.resultClosure = resultClosure
        }
        
    }
}
