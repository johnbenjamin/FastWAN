//
//  UserCenterView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/17.
//

import SwiftUI
import Kingfisher

struct UserCenterView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    private let user = UserManager.shared.userInfo
    private var rowmarks: [UserCenterRowMark] = [UserCenterRowMark(title: "实名认证", state: UserManager.shared.userInfo?.approved == 1 ? "已认证" : "未认证", imageName: "ID.card"),
                                                 UserCenterRowMark(title: "信息安全协议", state: UserManager.shared.userInfo?.approved == 1 ? "已签署" : "未签署", imageName: "Shield"),
                                                 UserCenterRowMark(title: "帐号管理", imageName: "setting"),
                                                 UserCenterRowMark(title: "投诉与建议", imageName: "book")]
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user?.user_nick ?? user?.username ?? "")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(c_030364)
                        Text(user?.invite_code ?? "")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(c_7F8398)
                    }
                    Spacer(minLength: 29)
                    
                    ZStack(alignment: .bottomTrailing, content: {
                        KFImage.url(URL(string: user?.avatar ?? ""))
                            .placeholder({
                                Image("Avatar.Default")
                            })
                            .frame(width: 81, height: 81)
                                .cornerRadius(40.5)

                        NavigationLink(destination: {
                            AvatarView(store: .init(initialState: .init(),
                                                                              reducer: avatarReducer,
                                                    environment: .init(avatarClient: .live, getPrivateToken: .live, uploadTokenClient: .live,
                                                                                                 mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
                        }) {
                            Image("pencil")
                                .frame(width: 12, height: 12)
                                .padding(6)
                        }
                        .background(c_1ED9AD)
                        .cornerRadius(12)
                    })
                }.padding([.leading, .trailing], 16)
                Spacer(minLength: 29)
                
                HStack(alignment: .top, content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("流量套餐 VIP会员")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("充值即可使用流量，享3项专属福利")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white)
                    }.padding(EdgeInsets(top: 19, leading: 15, bottom: 55, trailing: 0))
                    Spacer()
                    
                    NavigationLink {
                        MakeOrderView(store: .init(initialState: .init(), reducer: makeOrderReducer, environment: .init(productsClient: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
                    } label: {
                        Text("立即充值")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(mainColor)
                            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    }.background(.white)
                        .cornerRadius(18)
                        .padding(.trailing, 11)
                        .padding(.top, 24)
                }).background(mainColor)
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 29)
                
                ZStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .border(.white, width: 1)
                        .edgesIgnoringSafeArea(.all)

                    List(rowmarks.indexed(), id: \.1.self) { index, mark in
                        NavigationLink {
                            cellClick(mark: mark, index: index)
                        } label: {
                            UserCenterRow(rowMark: mark)
                                .frame(height: 50)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.leading, 8)
                        }.background(.clear)
                    }.listStyle(PlainListStyle())
                        .padding(.top, 37)
                }.padding(.top, -37)

                Button {
                    RootWindow().window?.rootViewController = UIHostingController(rootView: LoginView(store: .init(initialState: .init(),
                                                                                                      reducer: loginReducer,
                                                                                                      environment: .init(loginClient: .live,
                                                                                                                         mainQueue: DispatchQueue.main.eraseToAnyScheduler()))))

                    UserManager.shared.removeLoginData()
                } label: {
                    Spacer()
                    Text("退出账号")
                        .foregroundColor(mainColor)
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                }
                .frame(height: 60)
                .cornerRadius(12)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(mainColor.opacity(0.2), lineWidth: 1)
                })
                .padding([.leading, .trailing], 29)
                Spacer(minLength: 70)
            }.background {
                Image("UserCenter.backgroud")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("back")
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    func cellClick(mark: UserCenterRowMark, index: Int) -> AnyView {
        switch index {
        case 0:
            return AnyView(Upload_ID_View(store: .init(initialState: .init(), reducer: uploadIDReducer, environment: .init(uploadIDClient: .live, uploadTokenClient: .live, getPrivateToken: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler()))))
        case 1:
            return AnyView(SignAgreementView())
        case 2:
            return AnyView(RegisterView(store: .init(initialState: .init(pageType: .findPassword), reducer: registerReducer, environment: .init(registerClient: .live, captchaClient: .live, findPasswordClient: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler()))))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct UserCenterRow: View {
    var rowMark: UserCenterRowMark
    
    var body: some View {
        HStack {
            rowMark.image
            Text(rowMark.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(c_030364)
            Spacer()
            
            if rowMark.state != nil {
                Text("--")
                    .font(.system(size: 14, weight: .regular))
            }
        }
    }
    
}

struct UserCenterView_Previews: PreviewProvider {
    static var previews: some View {
        UserCenterView()
    }
}
