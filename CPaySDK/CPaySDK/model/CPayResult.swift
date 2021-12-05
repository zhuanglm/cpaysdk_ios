//
//  CPayResult.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-03.
//

import Foundation

public class CPayResult {
    public var result: String = ""
    
    public init(_ msg: String?) {
        self.result = msg ?? ""
    }
}
