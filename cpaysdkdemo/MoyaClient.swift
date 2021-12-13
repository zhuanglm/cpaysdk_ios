//
//  MoyaClient.swift
//  upisdkdemo
//
//  Created by Raymond Zhuang on 2021-09-08.
//

import Foundation
import Moya

public enum RequestApi {
    case accessToken
    case chargeToken(String,String)
    
}

extension RequestApi: TargetType {
    public var task: Task {
        switch self {
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
    }
    
    public var path: String {
        switch self {
        case .accessToken:
            return "access-tokens"
        case .chargeToken(_, _):
            return "charges"
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
        }
        
    }
    
    
}


