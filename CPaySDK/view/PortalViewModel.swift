//
//  PortalViewModel.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-08.
//

import Foundation
import Combine
import CPay
import BraintreeDropIn
import Moya

class PortalViewModel: ObservableObject {
    var paymentRequest: CPayRequest?
    var orderResult: String = ""
    var mClientToken: String?
    var isRequsted = false
    let mDecoder = JSONDecoder()
    var mErrorMsg: CitconApiResponse<ErrorMessage>? = nil
    
    @Published var mIsLoading = false
    @Published var mIsPresentAlert = false
    
    let viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    private func showDropIn(clientTokenOrTokenizationKey: String, viewController: UIViewController) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
        } else if (result?.isCanceled == true) {
                print("CANCELED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentMethodType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                //print("return from BT: \(result.paymentMethod)\n")
                self.returnResult(result: result)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        viewController.present(dropIn!, animated: true, completion: nil)
    }
    
    func startRequst(_ request: CPayRequest) {
        self.paymentRequest = request
        
        switch request.mPaymentMethodType {
            case .ALI_HK, .ALI, .DANA, .KAKAO, .WECHAT, .UPOP:
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
                
            case .UNKNOWN, .VENMO, .PAYPAL:
                getClientToken()
                                
            default:
                print( "default start case")
        }
    }
    
    func getClientToken() {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        let provider = MoyaProvider<RequestApi>(plugins: [networkLogger])
        
        self.mIsLoading = true
        provider.request(.loadConfig(self.paymentRequest!.mAccessToken, self.paymentRequest!.mConsumerID)) { (result) in
            switch result {
                case .success(let response):
                    // Parsing the data:
                do {
                    let parsedData = try self.mDecoder.decode(CitconApiResponse<LoadedConfig>.self, from: response.data)
                    
                    if (parsedData.status == "success") {
                        self.mClientToken = parsedData.data.payment.client_token
                        if let keyWindow = UIWindow.key {
                            self.showDropIn(clientTokenOrTokenizationKey: self.mClientToken!, viewController:
                                        UIWindow.getVisibleViewControllerFrom(keyWindow.rootViewController)!)
                        }
                    }
                } catch {
                    self.mIsLoading = false
                    self.mErrorMsg = try! self.mDecoder.decode(CitconApiResponse<ErrorMessage>.self, from: response.data)
                    
                    if (self.mErrorMsg?.status == "fail") {
                        self.mIsPresentAlert = true
                    }
                }
                
            case .failure(let error):
                print(error)
            }
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
    
    private func returnResult(result: BTDropInResult) {
        self.orderResult = String(format: "status: %@\n  nonce: ", result.paymentDescription) + result.paymentMethod!.nonce
        
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
