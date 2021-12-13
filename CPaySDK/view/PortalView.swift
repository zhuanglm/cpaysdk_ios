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
                
                if(viewModel.mIsLoading) {
                    ProgressView()
                    Text("loading...").padding()
                }
                
                Button("Cancel") {
                    let value = opacity as Double
                    let paymentMethod = self.request?.mPaymentMethodType
                    result?.result = "payment: \(paymentMethod ?? CPayMethodType.NONE) value: \(value)"
                    viewModel.unregisterNotification()
                    presentationMode.wrappedValue.dismiss()
                }.padding()
                    .alert(isPresented: $viewModel.mIsPresentAlert, content: {
                        Alert(title: Text(viewModel.mErrorMsg?.status ?? "loading"), message: Text("\(viewModel.mErrorMsg?.data.message ?? "") -- \(viewModel.mErrorMsg?.data.code ?? "")"), dismissButton: .default(Text("OK")))
                    })
            }
        }.onAppear {
            print("SDK PortalView appeared!")
            
            //viewModel.registerNotification()
            
            if (request != nil) {
                if(viewModel.isRequsted) {
                    viewModel.inquire(request!)
                } else {
                    viewModel.startRequst(request!)
                }
            
            }
            
            
        }.onDisappear {
            print("SDK PortalView disappeared!")
            
            //viewModel.unregisterNotification()
            
        }.onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
            if shouldDismiss {
                //return CPayResult
                result?.result = viewModel.orderResult
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
