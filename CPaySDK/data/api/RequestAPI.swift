//
//  RequestAPI.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-13.
//

import Foundation
import Moya

public enum RequestApi {
    case accessToken
    case chargeToken(String,String)
    case loadConfig(String,String)
    case confirmCharge(String,String,String,String,String)
    
}

extension RequestApi: TargetType {
    public var task: Task {
        switch self {
            case .confirmCharge(_, _, _, _, _):
                return .requestParameters(parameters: ["token_type": "client"], encoding: JSONEncoding.default)
            case .loadConfig(_, let consumerID):
                return .requestParameters(parameters: ["client": "iOS", "consumer_id": consumerID, "gateway": "braintree"], encoding: JSONEncoding.default)
            case .accessToken:
                return .requestParameters(parameters: ["token_type": "client"], encoding: JSONEncoding.default)
            case .chargeToken(_, let reference):
                //return .requestPlain
                return .requestParameters(parameters: ["transaction":["reference":reference,
                                                                      "amount":10,
                                                                      "currency":"USD",
                                                                      "country":"US",
                                                                      "auto_capture":false,
                                                                      "note":"braintree test"],
                                                      ], encoding: JSONEncoding.default)
        }
    }
    
    public var baseURL: URL {
        return URL(string: "https://api.sandbox.citconpay.com/v1/")!
        //return URL(string: "https://api.qa01.citconpay.com/v1/")!
    }
    
    public var path: String {
        switch self {
            case .accessToken:
                return "access-tokens"
            case .chargeToken(_, _):
                return "charges"
            case .loadConfig(_, _):
                return "config"
            case .confirmCharge(_,let ct, _, _, _):
                return "charges/{\(ct)}"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var headers: [String : String]? {
        switch self {
            case .accessToken:
                return ["Authorization": "Bearer braintree", "Content-Type": "application/json"]
            case .chargeToken(let accessToken, _):
                return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
            case .loadConfig(let accessToken, _):
                return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
            case .confirmCharge(let accessToken, _, _, _, _):
                return ["Authorization": "Bearer \(accessToken)", "Content-Type": "application/json"]
        }
        
    }
    
    
}
