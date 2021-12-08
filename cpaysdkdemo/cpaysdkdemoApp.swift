//
//  cpaysdkdemoApp.swift
//  cpaysdkdemo
//
//  Created by Raymond Zhuang on 2021-10-19.
//

import SwiftUI

@main
struct cpaysdkdemoApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                print("open URL is \(url)")
//                CPayManager.processOpenUrl(UIApplication.shared, url: url) { result in
//                    //NSLog(@"openURL result: %@ status: %li, message: %@, transaction id: %@", result.result, result.resultStatus, result.message, result.order.transactionId);
//                }
            }
        }.onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                print("App is active")
                //print("App is active: \(CPayManager.getVersion())")
//                CPayManager.initSDK()
//                CPayManager.setupMode(CPAY_MODE_UAT)
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is in background")
            @unknown default:
                print("Oh - interesting: I received an unexpected new value.")
            }
        }
    }
}
