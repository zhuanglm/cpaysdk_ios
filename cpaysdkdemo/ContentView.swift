//
//  ContentView.swift
//  cpaysdkdemo
//
//  Created by Raymond Zhuang on 2021-10-19.
//

import SwiftUI
import CPaySDK

struct ContentView: View {
    @State var envIndex: Int = 1
    @State var tokenIndex: Int = 0
    @State var referenceID: String = ""
    @State var orderSubject: String = "test subject"
    @State var orderBody: String = "test data"
    @State var extKey: String = "reference2"
    @State var extValue: String = "112233445566"
    @State var amount: Int = 1
    @State var currencyIndex: Int = 0
    @State var vendorIndex: Int = 0
    @State var allowDuplicate = true
    @StateObject var viewModel = ViewModel()
    
    @State private var isPresented = false
    
    private var tokens = ["52A92BB2E055434DBAC0CC4585C242B2",
                          "XYIL2W9BCQSTNN1CXUQ6WEH9JQYZ3VLM",
                          "9FBBA96E77D747659901CCBF787CDCF1",
                          "CNYAPPF6A0FE479A891BF45706A690AE",
                          "6763A8C42CB44B288CAC9093466BC72F",
                          "FF792AB416FA4197B8122319B8F68750",
                          "52463C5B22A163F4AF9CDD35DF881BDB",
                          "61FB84DB288D4075AC1B229717E319F8"]
    
    private var currencies = ["USD", "CNY", "CAD", "HKD", "KRW", "IDR"]
    
    private var vendors = ["upop", "wechatpay", "alipay", "kakaopay", "dana", "alipay_hk"]
    
    
    enum ENV: Int, CaseIterable, Identifiable {
        case DEV
        case UAT
        case PROD
        
        var id: Int { self.rawValue }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Group {
                    Picker(selection: $envIndex,
                           label: Text("Select ENV"),
                           content: {
                        Text("DEV").tag(0)
                        Text("UAT").tag(1)
                        Text("PROD").tag(2)
                    }).padding()
                        .pickerStyle(SegmentedPickerStyle())
                    
                    Menu(tokens[tokenIndex]){
                        ForEach(0..<tokens.count) { index in
                            Button(action: {
                                tokenIndex = index
                            }) {
                                Text(tokens[index])
                            }
                            
                        }
                    }.menuStyle(BorderlessButtonMenuStyle())
                    
                    HStack {
                        Text("reference:").padding()
                        TextField("", text: $referenceID )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    
                    Button(action: {
                        referenceID = viewModel.randomString(16)
                    }) {
                        Text("regenerate")
                            .font(.body)
                            .padding(.horizontal, 60.0)
                            .padding(.vertical, 8.0)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    
                    HStack {
                        Text("subject:").padding()
                        TextField("", text: $orderSubject )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.trailing])
                    }
                    
                    HStack {
                        Text("body:").padding([.leading,.trailing])
                        TextField("", text: $orderBody )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding([.trailing])
                    }
                    
                    HStack {
                        Text("amount").padding(.leading)
                        TextField("amount", text: Binding(
                            get: { String(amount) },
                            set: { amount = Int($0) ?? 0 }
                        )).padding(.leading)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                        Toggle(isOn: $allowDuplicate) {
                            Text("duplicate")
                        }.padding(.leading, 20)
                            .padding(.trailing)
                    }
                    
                    HStack {
                        Text("currency").padding(.leading)
                        Menu(currencies[currencyIndex]){
                            ForEach(0..<currencies.count) { index in
                                Button(action: {
                                    currencyIndex = index
                                }) {
                                    Text(currencies[index])
                                }
                                
                            }
                        }.menuStyle(BorderlessButtonMenuStyle())
                            .padding(.trailing)
                        
                        Text("vendor").padding(.leading)
                        Menu(LocalizedStringKey(vendors[vendorIndex])){
                            ForEach(0..<vendors.count) { index in
                                Button(action: {
                                    vendorIndex = index
                                }) {
                                    Text(LocalizedStringKey(vendors[index]))
                                }
                                
                            }
                        }.menuStyle(BorderlessButtonMenuStyle())
                    }
                    
                    HStack {
                        VStack {
                            Text("Ext - key").padding(.horizontal, 30.0)
                            TextField("key", text: $extKey).padding(.leading)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 150)
                        }
                        
                        VStack {
                            Text("Ext - value").padding(.horizontal, 60.0)
                            TextField("value", text: $extValue).padding(.leading)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 150)
                        }
                    }
                    
                }
                
                Group {
                    Button(action: {
                        viewModel.requestOrder(token: tokens[tokenIndex], mode: envIndex, reference: referenceID, amount: amount, subject: orderSubject, body: orderBody, currency: currencies[currencyIndex], vendor: vendors[vendorIndex], allowDuplicate: allowDuplicate, extra: [extKey: extValue])
                        
                    }) {
                        Text("new_payment")
                            .font(.body)
                            .padding(.horizontal, 60.0)
                            .padding(.vertical, 8.0)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }.padding()
                    
//                    Button("ttt") {
//                                self.isPresented = true
//                            }.fullScreen(isPresented: $isPresented, content: {
//                                NextView()
//                            })
                    Button(action: {
                        viewModel.startTestView()
                    }) {
                        Text("test view")
                    }
                    
                    Text("result").padding(.leading)
                    
                    Text(viewModel.mOrderResult).multilineTextAlignment(.leading)
                        .lineSpacing(11).lineLimit(nil)
                    
                    Spacer()
                }
                
            }.onAppear {
                print("ContentView appeared!")
                viewModel.registerNotification()
                
                //CPayManager.initSDK()
                //CPayManager.setupMode(CPAY_MODE_UAT)
            }.onDisappear {
                print("ContentView disappeared!")
                
                viewModel.unregisterNotification()
                
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.locale, .init(identifier: "zh"))
    }
}

