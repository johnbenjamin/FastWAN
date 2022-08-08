//
//  ResetPasswordView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI
import ComposableArchitecture

struct ResetPasswordView: View {

    var store: Store<ResetPasswordState, ResetPasswordAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1, content: {
                            Text("请重新编辑您的密码")
                                .foregroundColor(c_030364)
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("建议您的新密码以简单好记为标准")
                                .foregroundColor(c_7F8398)
                                .font(.system(size: 12, weight: .medium))
                        })
                        Spacer()
                    }.padding(.bottom, 79)
                    
                    SecureTextField(text: viewStore.binding(
                        get: { $0.newPassword },
                        send: { ResetPasswordAction.input(.newPassword($0)) }), placeholder:"请输入您的新密码")
                        .foregroundColor(c_7F8398)
                        .frame(height: 29, alignment: .center)
                        .padding()
                    
                    SecureTextField(text: viewStore.binding(
                        get: { $0.verifyPassword },
                        send: { ResetPasswordAction.input(.verifyPassword($0)) }), placeholder:"请再次输入您的密码")
                        .foregroundColor(c_7F8398)
                        .frame(height: 29, alignment: .center)
                        .padding()
                    
                    Button {
                        
                    } label: {
                        Spacer()
                        Text("立即注册")
                            .foregroundColor(viewStore.isUserInputed ? .white : mainColor)
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                    }
                    .frame(height: 60)
                    .background(viewStore.isUserInputed ? mainColor : mainColor.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(color:viewStore.isUserInputed ? mainColor.opacity(0.2) :     mainColor.opacity(0), radius: 12, x: 0, y: 8)
                    .disabled(!viewStore.isUserInputed)
                    .padding(.top, 59)
                    
                    Spacer()
                }
                .padding([.leading, .trailing], 29)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            
                        } label: {
                            Image("back")
                        }

                    }
                }
            }
        }
    }
}

//struct ResetPasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResetPasswordView()
//    }
//}
