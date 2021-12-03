//
//  NextView.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-11-30.
//

import SwiftUI

public struct NextView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var opacity = 0.5
    
    public init() {
        
    }

    public var body: some View {
        ZStack {
            Color.black
                .opacity(opacity)
                .edgesIgnoringSafeArea(.all)
            
            Slider(value: $opacity, in: 0...1)
                .padding()
            
            
        }
    }
}
