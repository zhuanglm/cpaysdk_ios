//
//  NextView.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import SwiftUI

public struct PortalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var opacity = 0.5
    
    private var paymentMethod: CPayMethodType
    var result: CPayResult
    
    public init(method: CPayMethodType) {
        self.paymentMethod = method
        result = CPayResult("")
    }
    
    public var body: some View {
        ZStack {
            Color.black
                .opacity(opacity)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Slider(value: $opacity, in: 0...1)
                    .padding()
                
                Button("Done") {
                    let value = opacity as Double
                    result.result = "payment: \(self.paymentMethod) value: \(value)"
                    presentationMode.wrappedValue.dismiss()
                }.padding()
            }
        }.onAppear {
            print("SDK PortalView appeared!")
            //viewModel.registerNotification()
            
            //CPayManager.initSDK()
            //CPayManager.setupMode(CPAY_MODE_UAT)
        }.onDisappear {
            print("SDK PortalView disappeared!")
            
            //viewModel.unregisterNotification()
            
        }
    }
}
