//
//  SignAgreementView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/21.
//

import SwiftUI
import PencilKit
import ComposableArchitecture
import ToastUI

struct SignAgreementView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    let signatureView = UserSignatureView(store: .init(initialState: .init(), reducer: uploadSignReducer, environment: .init(uploadTokenClient: .live, getPrivateToken: .live, uploadSignClient: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
    var webViewModel = StupidUIWebViewModel()
    @State private var isSignPresented = false
    @State private var isAgreetSign = false
    @State private var isPresented = false

    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("请阅读并确认以下\n信息安全协议")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                        Label("FastWAN严格遵守协议约定，保障您的消费者权益", image: "Shield.White")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .regular))
                    }.padding(.bottom, 67)
                    Spacer()
                }.background(mainColor)

            	ZStack {
            	    VisualEffectView(effect: UIBlurEffect(style: .light))
            	        .edgesIgnoringSafeArea(.all)
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white, lineWidth: 1)
                        })
            	    
                    VStack(alignment: .leading) {
                        StupidUIWebView(webView: webViewModel.webView)
                            .onAppear(perform: {
                                webViewModel.urlString = Environment.ConfigKey.securityProtocolsURL
                                webViewModel.loadUrl()
                            })
                            .padding(.top, 49)
            	    }
            	}
                .cornerRadius(16)
            	.padding(.top, -61)
            	Spacer(minLength: 10)
            	
                VStack {
                    HStack {
                        Button {
                            isAgreetSign = !isAgreetSign
                        } label: {
                            Image(isAgreetSign ? "greenhook" : "")
                                .frame(width: 16, height: 16)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isAgreetSign ? .clear : c_7F8398, lineWidth: 1)
                                })
                            Text("我已阅读并同意签署")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(c_030364)
                        }
                        
                        Button("个人信息安全协议-FastWAN") {}.font(.system(size: 12, weight: .bold))
                            .foregroundColor(c_030364)
                    }.padding(.top, 8)
                    
                    HStack {
                        
                        Button {
                            isPresented = !isPresented
                        } label: {
                            Spacer()
                            Text("我已阅读并同意以上协议")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular))
                            Spacer()
                        }.adaptiveSheet(isPresented: $isPresented, detents: [.medium()], smallestUndimmedDetentIdentifier: .large, content: {
                            signatureView
                        })
                        .frame(height: 60)
                        .background(isAgreetSign ? mainColor : mainColor.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color:mainColor.opacity(0.2), radius: 12, x: 0, y: 8)
                    }.padding(13)
                }.background(c_F4F5F7)
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("back.white")
                    }
                }
            }
        }.navigationBarHidden(true)
    }
}

struct UserSignatureView: View {
    let canvas = Canvas()
    var store: Store<SignAgreementState, SignAgreementAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text("手绘签字")
                        .foregroundColor(c_030364)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.leading, 36)
                    Spacer()
                }.frame(height: 70)

                GeometryReader { proxy in
                    canvas.frame(width: proxy.size.width, height: 250)
                }

                Label("请正楷签署您的姓名，避免错别字导致无法法律效力", image: "!.green")
                    .foregroundColor(c_7F8398)
                    .font(.system(size: 12, weight: .regular))
                
                HStack(spacing: 12) {
                    Button {
                        canvas.canvasView.drawing = PKDrawing()
                    } label: {
                        Spacer()
                        Text("重写")
                            .foregroundColor(mainColor)
                            .font(.system(size: 16, weight: .regular))
                            .frame(height: 50)
                        Spacer()
                    }
                    .background(mainColor.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.leading, 29)

                    Button {
                        viewStore.send(SignAgreementAction.uploadSign(uploadBlock: { token in
                            guard let image = saveSignature() else { return }
                            QNImageUper.imageUpload(image: image, token: token ?? "") { isOK, url  in
                                viewStore.send(SignAgreementAction.uploadSignURL(isOK, url))
                            }
                        }))
                    } label: {
                        Spacer()
                        Text("提交")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .regular))
                            .frame(height: 50)
                        Spacer()
                    }
                    .background(mainColor)
                    .cornerRadius(12)
                    .padding(.trailing, 29)
                    .toast(isPresented: viewStore.binding(\.$isLoading), content: {
                        ToastView("Loading...").toastViewStyle(.indeterminate)
                    })
                    .toast(isPresented: viewStore.binding(\.$showMessage), dismissAfter: 2.0, content: {
                        ToastView(viewStore.message).toastViewStyle(.information)
                    })
                }
            }
            .navigationBarHidden(true)

        }
    }

    func saveSignature() -> UIImage? {
        return canvas.canvasView.drawing.image(from: canvas.canvasView.bounds, scale: 1.0)
    }
}

struct SignAgreementView_Previews: PreviewProvider {
    static var previews: some View {
        SignAgreementView()
    }
}
