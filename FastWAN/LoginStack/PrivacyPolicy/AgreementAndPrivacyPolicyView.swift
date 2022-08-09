//
//  AgreementAndPrivacyPolicyView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/16.
//

import SwiftUI
import ComposableArchitecture

struct AgreementAndPrivacyPolicyView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    var agreeBlock: ((Bool) -> ())?
    var webViewModel = StupidUIWebViewModel()

    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    Text("用户协议及私隐条款")
                        .foregroundColor(c_030364)
                    .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                Spacer(minLength: 45)
                
                StupidUIWebView(webView: webViewModel.webView)
                    .onAppear {
                        webViewModel.urlString = Environment.ConfigKey.UserPrivacyAgreementURL
                        webViewModel.loadUrl()
                    }
                Spacer(minLength: 13)
                
                HStack(spacing: 11) {
                    Button {
                        if agreeBlock != nil { agreeBlock!(false) }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Spacer()
                        Text("不同意")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(c_7F8398)
                            .padding([.top, .bottom], 14)
                        Spacer()
                    }.background(c_F4F5F7)
                        .frame(height: 50)
                        .cornerRadius(12)

                    Button {
                        if agreeBlock != nil { agreeBlock!(true) }
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Spacer()
                        Text("同意")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding([.top, .bottom], 14)
                        Spacer()
                    }.background(mainColor)
                        .frame(height: 50)
                        .cornerRadius(12)

                }
                
            }.padding(EdgeInsets(top: 21, leading: 35, bottom: 35, trailing: 12))
        }

    }
}

struct AgreementAndPrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementAndPrivacyPolicyView()
    }
}
