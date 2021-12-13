//
//  Response.swift
//  upisdkdemo
//
//  Created by Raymond Zhuang on 2021-09-09.
//

import Foundation

public class CitconApiResponse<T: Codable>: Codable {
    public let status: String
    public let app: String
    public let version: String
    public let data: T
}

public class ErrorMessage : Codable {
    public let code: String
    public let message: String
}

public class AccessToken: Codable {
    public let access_token: String
    public let token_type: String?
    public let expiry: UInt
    public let permission: Array<String>?
}

public class ChargeToken: Codable {
    public let object: String
    public let charge_token: String
    public let id: String
    public let reference: String
    public let amount: Int
    public let currency: String
    public let time_created: Int
    public let time_captured: Int?
    public let status: String?
    public let country: String?
}

class Configuration: Codable {
    let client: String
    let client_token: String
    let gateway: String
}

class LoadedConfig: Codable {
    let payment: Configuration
}
