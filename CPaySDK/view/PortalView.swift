//
//  NextView.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import SwiftUI

public struct PortalView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = PortalViewModel()
    @State private var opacity = 0.5
    
    private var request: CPayRequest?
    var result: CPayResult?
    
    public init(request: CPayRequest?) {
        self.request = request
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
                
                ProgressView()
                
                Button("Done") {
                    let value = opacity as Double
                    let paymentMethod = self.request?.mPaymentMethodType
                    result?.result = "payment: \(paymentMethod ?? CPayMethodType.NONE) value: \(value)"
                    presentationMode.wrappedValue.dismiss()
                }.padding()
            }
        }.onAppear {
            print("SDK PortalView appeared!")
            //viewModel.registerNotification()
            if (request != nil) {
                viewModel.startRequst(request!)
            }
            //CPayManager.initSDK()
            //CPayManager.setupMode(CPAY_MODE_UAT)
        }.onDisappear {
            print("SDK PortalView disappeared!")
            
            //viewModel.unregisterNotification()
            
        }
    }
}
