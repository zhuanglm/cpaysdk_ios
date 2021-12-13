//
//  ViewModel.swift
//  cpaysdkdemo
//
//  Created by Raymond Zhuang on 2021-10-21.
//

import Foundation
import CPaySDK
import Moya

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
    var mErrorMsg: CitconApiResponse<ErrorMessage>? = nil
    let mDecoder = JSONDecoder()
    let paymentMethod = CPayMethodType.ALI_HK
    @Published var mOrderResult: String = ""
    @Published var mIsLoading = false
    @Published var mIsPresentAlert = false
    @Published var mAccessToken: String = ""
    @Published var mChargeToken: String = ""
    @Published var mReference: String = ""
    @Published var mIs3DS = true
    
    init() {
        mReference = randomString(16)
    }
    
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
    
    func getAccessToken() {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        let provider = MoyaProvider<RequestApi>(plugins: [networkLogger])
        
        self.mIsLoading = true
        provider.request(.accessToken) { (result) in
            switch result {
            case .success(let response):
                // Parsing the data:
                do {
                    let parsedData = try self.mDecoder.decode(CitconApiResponse<AccessToken>.self, from: response.data)
                    
                    if (parsedData.status == "success") {
                        self.mAccessToken = parsedData.data.access_token
                        //self.getReference()
                        self.getChargeToken(provider)
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
    
    private func getChargeToken(_ provider: MoyaProvider<RequestApi>) {
        provider.request(.chargeToken(self.mAccessToken, self.mReference)) { (result) in
            self.mIsLoading = false
            switch result {
            case .success(let response):
                // Parsing the data:
                do {
                    let parsedData = try self.mDecoder.decode(CitconApiResponse<ChargeToken>.self, from: response.data)
                    
                    if (parsedData.status == "success") {
                        self.mChargeToken = parsedData.data.charge_token
                    }
                } catch {
                    //print(error)
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
   
    func requestOrder(token: String, mode: Int, amount: Int, subject: String, body: String, currency: String, vendor: CPayMethodType, allowDuplicate: Bool, extra: Dictionary<String, String>) {
        
        let cpayReq: CPayRequest = CPayBuilder()
            .token(token)
            .envMode(CPayENVMode.init(rawValue: mode) ?? CPayENVMode.UAT)
            .amount(String(amount))
            .reference(mReference)
            .subject(subject)
            .body(body)
            .currency(currency)
            .ipnUrl("ipn.php")
            .callback("citcon.com")
            .setAllowDuplicate(allowDuplicate)
            .extra(extra.toJsonString() ?? "")
            .build(type: vendor)
        
        
            cpayReq.start() { retVal in
                self.mOrderResult = retVal.result
            }
    }
    
    func requestOrder(mode: Int, vendor: CPayMethodType) {
        let cpayReq: CPayRequest = DropInBuilder()
            .accessToken(self.mAccessToken)
            .chargeToken(self.mChargeToken)
            .reference(mReference)
            .consumer("115646448")
            .envMode(CPayENVMode.init(rawValue: mode) ?? CPayENVMode.UAT)
            .build(type: vendor)
        
        cpayReq.start() { retVal in
            self.mOrderResult = retVal.result
            print("return: \(retVal.result)\n")
        }
    }
        
}
