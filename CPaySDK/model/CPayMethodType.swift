//
//  CitconPaymentMethodType.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import Foundation

public enum CPayMethodType: String, CaseIterable, Identifiable {
    
    public var id : String { UUID().uuidString }
    
    case UPOP = "upop"
    case WECHAT = "wechatpay"
    case ALI = "alipay"
    case ALI_HK = "alipay_hk"
    case KAKAO = "kakaopay"
    case DANA = "dana"
    case UNKNOWN = "credit card"
    case NONE = "none"
}
