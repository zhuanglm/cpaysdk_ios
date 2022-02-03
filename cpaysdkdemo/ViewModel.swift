//
//  ViewModel.swift
//  cpaysdkdemo
//
//  Created by Raymond Zhuang on 2021-10-21.
//

import Foundation
import CPaySDK

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
    let paymentMethod = CPayMethodType.NONE
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
    
    func applyToken() {
        self.mIsLoading = true
        
        let api = UPIAPI()
        
        api.getAccessToken { response in
            if response is CitconApiResponse<AccessToken> {
                let at = response as! CitconApiResponse<AccessToken>
                self.mAccessToken = at.data.access_token
                
                api.getChargeToken(self.mAccessToken, self.mReference) { response in
                    self.mIsLoading = false
                    
                    if response is CitconApiResponse<ChargeToken> {
                        let ct = response as! CitconApiResponse<ChargeToken>
                        self.mChargeToken = ct.data.charge_token
                    } else {
                        self.mIsLoading = false
                        self.mErrorMsg = response as? CitconApiResponse<ErrorMessage>
                        
                        self.mIsPresentAlert = true
                    }
                }
                
            } else {
                self.mIsLoading = false
                self.mErrorMsg = response as? CitconApiResponse<ErrorMessage>
                
                self.mIsPresentAlert = true
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
