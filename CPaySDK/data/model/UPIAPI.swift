//
//  UPIConfig.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-14.
//

import Foundation
import Moya

public typealias RespondClosure = (AnyObject) -> Void

public class UPIAPI {
    let mDecoder = JSONDecoder()
    var mErrorMsg: CitconApiResponse<ErrorMessage>? = nil
    let apiProvider: MoyaProvider<RequestApi>?
    //var respondClosure:RespondClosure?
        
    public init() {
        let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        apiProvider = MoyaProvider<RequestApi>(plugins: [networkLogger])
    }
    
    public func getAccessToken(complete: RespondClosure?) {
        
        if let respondClosure = complete {
            apiProvider!.request(.accessToken) { (result) in
                switch result {
                case .success(let response):
                    // Parsing the data:
                    do {
                        let parsedData = try self.mDecoder.decode(CitconApiResponse<AccessToken>.self, from: response.data)
                        
                        if (parsedData.status == "success") {
                            respondClosure(parsedData as CitconApiResponse<AccessToken>)
                        }
                    } catch {
                        let errorResponse = try! self.mDecoder.decode(CitconApiResponse<ErrorMessage>.self, from: response.data)

                        if (errorResponse.status == "fail") {
                            respondClosure(errorResponse as CitconApiResponse<ErrorMessage>)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
            }
        }
        
    }
    
    public func getChargeToken(_ accessToken: String?, _ ref: String?, complete: RespondClosure?) {
        
        if let respondClosure = complete {
            apiProvider!.request(.chargeToken(accessToken!, ref!)) { (result) in
                switch result {
                case .success(let response):
                    // Parsing the data:
                    do {
                        let parsedData = try self.mDecoder.decode(CitconApiResponse<ChargeToken>.self, from: response.data)
                        
                        if (parsedData.status == "success") {
                            respondClosure(parsedData as CitconApiResponse<ChargeToken>)
                        }
                    } catch {
                        let errorResponse = try! self.mDecoder.decode(CitconApiResponse<ErrorMessage>.self, from: response.data)

                        if (errorResponse.status == "fail") {
                            respondClosure(errorResponse as CitconApiResponse<ErrorMessage>)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    
                }
            }
        }
        
    }

    func getClientToken(_ paymentRequest: CPayRequest, complete: RespondClosure?) {

        if let respondClosure = complete {
            apiProvider!.request(.loadConfig(paymentRequest.mAccessToken, paymentRequest.mConsumerID)) { (result) in
                switch result {
                    case .success(let response):
                        // Parsing the data:
                    do {
                        let parsedData = try self.mDecoder.decode(CitconApiResponse<LoadedConfig>.self, from: response.data)

                        if (parsedData.status == "success") {
                            respondClosure(parsedData as CitconApiResponse<LoadedConfig>)
                        }
                    } catch {
                        let errorResponse = try! self.mDecoder.decode(CitconApiResponse<ErrorMessage>.self, from: response.data)

                        if (errorResponse.status == "fail") {
                            respondClosure(errorResponse as CitconApiResponse<ErrorMessage>)
                        }
                    }

                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
}
