//
//  CPayMode.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-04.
//

import Foundation

public enum CPayENVMode: Int, CaseIterable, Identifiable {
    case DEV
    case UAT
    case PROD
    
    public var id: Int { self.rawValue }
}
