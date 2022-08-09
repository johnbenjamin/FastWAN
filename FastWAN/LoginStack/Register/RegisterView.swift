//
//  RegisterView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/16.
//

import SwiftUI
import ComposableArchitecture
import AlertToast

struct RegisterView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    var store: Store<RegisterState, RegisterAction>

    @State private var sendCaptchaText: String = "获取验证码"
    @State private var isCountdowning: Bool = false

    func sendCaptchaCountdown() {
        isCountdowning = true
        var seconds = 60

        let timer : DispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)

        timer.schedule(deadline: .now(), repeating: 1.0)

        timer.setEventHandler {
            seconds -= 1
            if seconds < 0{
                timer.cancel()
                sendCaptchaText = "获取验证码"
                isCountdowning = false
            }else{
                sendCaptchaText = "\(seconds)秒后重发"
            }
        }
        timer.resume()
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    HStack(alignment: .center) {
                        Text(viewStore.pageType == .register ? "欢迎注册" : "找回密码")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(mainColor)
                        Spacer()
                    }
                    Spacer()
                    
                    VStack(spacing: 11) {
                        HStack {
                            Text("+86")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(c_030364)
                                .padding(.leading, 21)
                            
                            TextField("请输入手机号码", text: viewStore.binding(
                                get: { $0.userName },
                                send: { RegisterAction.userInput(.userName($0)) }))
                                .keyboardType(.phonePad)
                                .foregroundColor(c_7F8398)
                                .frame(height: 29, alignment: .center)
                                .padding()
                        }.background(c_F4F5F7)
                            .cornerRadius(12)
                        
                        HStack {
                            TextField("请输入验证码", text: viewStore.binding(
                                get: { $0.captcha },
                                send: { RegisterAction.userInput(.captcha($0)) }))
                                .keyboardType(.numberPad)
                                .foregroundColor(c_7F8398)
                                .frame(height: 29, alignment: .center)
                                .padding()
                            
                                Button {
                                    sendCaptchaCountdown()
                                    viewStore.send(RegisterAction.captcha)
                                } label: {
                                    Text(sendCaptchaText)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .regular))
                                        .frame(alignment: .center)
                                }
                                .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
                                .background(!isCountdowning ? mainColor : mainColor.opacity(0.2))
                                .disabled(isCountdowning)
                                .cornerRadius(8)
                                Spacer()
                        }.background(c_F4F5F7)
                            .cornerRadius(12)
                        
                        HStack {
                            SecureTextField(text: viewStore.binding(
                                get: { $0.password },
                                send: { RegisterAction.userInput(.password($0)) }),
                                            placeholder:viewStore.pageType == .register ? "请设置登录密码" : "请设置新密码")
                                .foregroundColor(c_7F8398)
                                .frame(height: 29, alignment: .center)
                                .padding()
                        }.background(c_F4F5F7)
                            .cornerRadius(12)
                        
                        Button {
                            viewStore.send(RegisterAction.register)
                        } label: {
                            Spacer()
                            Text(viewStore.pageType == .register ? "立即注册" : "修改密码")
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
                    }
                    
                    if viewStore.pageType == .register {
                        HStack {
                            Spacer()
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text("已有帐号？")
                                    .foregroundColor(c_7F8398)
                                    .font(.system(size: 14, weight: .regular))
                                + Text("去登录")
                                    .foregroundColor(mainColor)
                                    .font(.system(size: 14, weight: .regular))
                            }
                        }.padding(.top, 16)
                    }
                    Spacer()
                }.padding(.horizontal, 29)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image("x")
                            }
                        }
                    }
            }
            .toast(isPresenting: viewStore.binding(\.$isLoading), tapToDismiss: false,  alert: {
                AlertToast(type: .loading)
            })
            .toast(isPresenting: viewStore.binding(\.$isFinishLoad), duration: 2) {
                AlertToast(displayMode: .hud, type: .regular, title: viewStore.message)
            } completion: {
                
            }
            .navigationBarHidden(true)
        }

    }
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegisterView(pageType: .register)
//    }
//}
