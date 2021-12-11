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
    
   
    func requestOrder(token: String, mode: Int, reference: String, amount: Int, subject: String, body: String, currency: String, vendor: CPayMethodType, allowDuplicate: Bool, extra: Dictionary<String, String>) {
        
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
        
        
            cpayReq.start() { retVal in
                self.mOrderResult = retVal.result
                print("return: \(retVal.result)\n")
            }
    }
        
}
