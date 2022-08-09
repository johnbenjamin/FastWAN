//
//  LoginView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/12.
//

import SwiftUI
import ComposableArchitecture
import AlertToast

struct LoginView: View {
    enum LoginMethod {
        case captcha
        case password
    }
    
    @State private var loginMethod: LoginMethod = .password
    @State private var sendCaptchaText: String = "获取验证码"
    @State private var isCountdowning: Bool = false
    @State private var isPresented = false

    private var userNamePlaceholder: String { loginMethod == .password ? "请输入用户名/手机号" : "请输入手机号" }
    private var userPasswordPlaceholder: String { loginMethod == .password ? "请输入密码" : "请输入验证码" }

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack(alignment: .center) {
                    Spacer()
                    
                    HStack(alignment: .center) {
                        Text("您好，\n欢迎来到FastWAN")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(mainColor)
                        Spacer()
                    }
                    Spacer()
//                    HStack(alignment: .bottom, spacing: 23) {
//                        Button {
//                            loginMethod = .captcha
//                        } label: {
//                            Text("验证码登录")
//                                .font(loginMethod == .captcha ? .system(size: 16, weight: .bold) : .system(size: 14, weight: .regular))
//                                .foregroundColor(loginMethod == .captcha ? c_030364 : c_7F8398)
//                        }.hidden()
//
//                        Button {
//                            loginMethod = .password
//                        } label: {
//                            Text("密码登录")
//                                .font(loginMethod == .password ? .system(size: 16, weight: .bold) : .system(size: 14, weight: .regular))
//                                .foregroundColor(loginMethod == .password ? c_030364 : c_7F8398)
//                        }
//                        Spacer()
//                    }.padding(EdgeInsets(top: 83, leading: 0, bottom: 32, trailing: 0))
                    
                    VStack {
                        HStack {
                            TextField(userNamePlaceholder, text: viewStore.binding(
                                get: { $0.userName },
                                send: { LoginAction.userIput(.userName($0)) }))
                                .keyboardType(.asciiCapable)
                                .foregroundColor(c_7F8398)
                                .frame(height: 29, alignment: .center)
                                .padding()
                        }.background(c_F4F5F7)
                            .cornerRadius(12)
                        
                        HStack {
                            TextField(userPasswordPlaceholder, text: viewStore.binding(
                                get: { $0.password },
                                send: { LoginAction.userIput(.password($0)) }))
                                .keyboardType(.numberPad)
                                .foregroundColor(c_7F8398)
                                .frame(height: 29, alignment: .center)
                                .padding()
                            
                            if loginMethod == .captcha {
                                Button {
                                    sendCaptchaCountdown()
                                } label: {
                                    Text(sendCaptchaText)
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .regular))
                                        .frame(alignment: .center)
                                }
                                .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
                                .background(!isCountdowning ? mainColor : c_7F8398)
                                .disabled(isCountdowning)
                                .cornerRadius(8)
                                Spacer()
                            }
                        }.background(c_F4F5F7)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        viewStore.send(LoginAction.login)
                    } label: {
                        Spacer()
                        Text("登录")
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

                    
                    
                    
                    HStack {
                        if loginMethod == .password {
                            NavigationLink(destination: RegisterView(store: .init(initialState: .init(pageType: RegisterPageType.findPassword),
                                                                                                           reducer: registerReducer,
                                                                                  environment: .init(registerClient: .live, captchaClient: .live, findPasswordClient: .live,
                                                                                                                              mainQueue: DispatchQueue.main.eraseToAnyScheduler())))) {
                                Text("找回密码")
                                    .foregroundColor(c_7F8398)
                                    .font(.system(size: 14, weight: .regular))
                            }
                        }
                        Spacer()
                        NavigationLink(destination: RegisterView(store: .init(initialState: .init(pageType: RegisterPageType.register),
                                                                              reducer: registerReducer,
                                                                              environment: .init(registerClient: .live, captchaClient: .live, findPasswordClient: .live,
                                                                                                 mainQueue: DispatchQueue.main.eraseToAnyScheduler())))) {
                            Text("立即注册")
                                .foregroundColor(c_7F8398)
                                .font(.system(size: 14, weight: .regular))
                        }
                    }.padding(.top, 16)
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    HStack {
                        Button {
                            viewStore.send(LoginAction.agreePolicy)
                        } label: {
                            Image(viewStore.isAgree ? "greenhook" : "")
                                .frame(width: 16, height: 16)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewStore.isAgree ? .clear : c_7F8398, lineWidth: 1)
                                })

                            Text("我已阅读并同意")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(c_030364)
                        }
                        
                        Button("用户协议及私隐条款") {
                            isPresented = true
                        }.adaptiveSheet(isPresented: $isPresented, detents: [.medium()], smallestUndimmedDetentIdentifier: .large, content: {
                            AgreementAndPrivacyPolicyView(agreeBlock: {
                                viewStore.send(LoginAction.agreePolicy)
                            })
                        }).font(.system(size: 12, weight: .bold))
                            .foregroundColor(c_030364)
                    }
                }
                .padding(.horizontal, 29)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            
                        } label: {
                            Image("x")
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .toast(isPresenting: viewStore.binding(\.$isLoading), tapToDismiss: false,  alert: {
                AlertToast(type: .loading)
            }, completion: {
                
            })
            .toast(isPresenting: viewStore.binding(\.$isFinishLoad), duration: 2) {
                AlertToast(displayMode: .hud, type: .regular, title: viewStore.message)
            } completion: {
                guard viewStore.LoginSuccess else { return }
                RootWindow().window?.rootViewController = UIHostingController(rootView: MainPageView())
            }

        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}

extension LoginView {
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
}
