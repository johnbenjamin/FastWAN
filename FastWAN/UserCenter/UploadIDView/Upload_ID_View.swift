//
//  Upload_ID_View.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI
import ComposableArchitecture
import ToastUI

struct Upload_ID_View: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @State private var isPresentedSheet: Bool = false
    @State private var isImagePickerDisplay: Bool = false

    var store: Store<Upload_ID_State, Upload_ID_Action>
    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView(showsIndicators: false, content: {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 1, content: {
                                Text("请拍摄/上传 ")
                                    .foregroundColor(c_030364)
                                    .font(.system(size: 20, weight: .bold))
                                + Text(UserManager.shared.userInfo?.userNick ?? "")
                                    .foregroundColor(c_1ED9AD)
                                    .font(.system(size: 20, weight: .bold))
                                + Text(" 本人身份证")
                                    .foregroundColor(c_030364)
                                .font(.system(size: 20, weight: .bold))
                                
                                Text("请确保证件边框完整、字体清晰、亮度均匀")
                                    .foregroundColor(c_7F8398)
                                    .font(.system(size: 12, weight: .medium))
                            })
                            
                            Spacer()
                        }
                        
                        ZStack {
                            if viewStore.cardFrond != nil {
                                Image(uiImage: viewStore.cardFrond!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image("ID.Front")
                                    .aspectRatio(contentMode: .fill)
                            }
                            
                            VStack(spacing: 6) {
                                Button {
                                    viewStore.send(Upload_ID_Action.pick(.cardFrond))
                                    isPresentedSheet = true
                                } label: {
                                    Image("add")
                                        .frame(width: 43, height: 43)
                                }

                                Text("点击上传人像面")
                                    .foregroundColor(c_030364)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }

                        ZStack {
                            if viewStore.cardBack != nil {
                                Image(uiImage: viewStore.cardBack!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image("ID.Back")
                                    .aspectRatio(contentMode: .fill)
                            }
                            
                            VStack(spacing: 6) {
                                Button {
                                    viewStore.send(Upload_ID_Action.pick(.cardBack))
                                    isPresentedSheet = true
                                } label: {
                                    Image("add")
                                        .frame(width: 43, height: 43)
                                }

                                Text("背面身份证")
                                    .foregroundColor(c_030364)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        
                        HStack {
                            Text("请完善您的个人信息")
                                .foregroundColor(c_030364)
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                        }.padding(.top, 20)
                        
                        TextField("请输入姓名", text: viewStore.binding(
                            get: { $0.realName },
                            send: { Upload_ID_Action.input(.realName($0)) }))
                        .foregroundColor(c_7F8398)
                        .frame(height: 29, alignment: .center)
                        .padding()
                        .background(c_F4F5F7)
                        .cornerRadius(12)
                        
                        TextField("请输入本人身份证号", text: viewStore.binding(
                            get: { $0.idCardNo },
                            send: { Upload_ID_Action.input(.idNumber($0)) }))
                        .foregroundColor(c_7F8398)
                        .frame(height: 29, alignment: .center)
                        .padding()
                        .background(c_F4F5F7)
                        .cornerRadius(12)

                        Button {
                            viewStore.send(Upload_ID_Action.CheckTheBox)
                        } label: {
                            Image(viewStore.isCheckBox ? "Shield" : "Shield.Gray")
                                .foregroundColor(.gray)
                            Text("FastWAN将对信息加密，实时保障信息安全")
                                .foregroundColor(c_7F8398)
                                .font(.system(size: 12, weight: .regular))
                        }.padding(.top, 16)
                        
                        Button {
                            viewStore.send(Upload_ID_Action.send)
                        } label: {
                            Spacer()
                            Text("确认")
                                .foregroundColor(viewStore.ready ? .white : c_3D3CEE)
                                .font(.system(size: 16, weight: .regular))
                            Spacer()
                        }.frame(height: 60)
                            .background(viewStore.ready ? mainColor : mainColor.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color:viewStore.ready ? mainColor.opacity(0.2) :     mainColor.opacity(0), radius: 12, x: 0, y: 8)
                        .disabled(!viewStore.ready)
                        Spacer()
                    }
                    .padding([.leading, .trailing], 29)
                    .padding(.bottom, 16)
                })
//                    .background(NavigationConfigurator { navigationConfigurator in
//                        navigationConfigurator.hidesBarsOnSwipe = true
//                    })
                .adaptiveSheet(isPresented: $isPresentedSheet, detents: [.medium()], smallestUndimmedDetentIdentifier: .large, content: {
                    IDUploadTableView(isPresentedSheet: $isPresentedSheet, viewStore: viewStore) { displayPicker in
                        isImagePickerDisplay = displayPicker
                    }
                    .sheet(isPresented: $isImagePickerDisplay) {
                        ImagePickerView(selectedImage: viewStore.binding(get: { $0.selectImage }, send: { Upload_ID_Action.takePhoto($0) { token in
                            isPresentedSheet = false
                            QNImageUper.imageUpload(image: viewStore.selectImage!, token: token ?? "") { isOK, url  in
                                viewStore.send(Upload_ID_Action.uploadAvatarURL(isOK, url))
                            }
                        } }), sourceType: viewStore.sourceType)
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("x")
                        }

                    }
                }
            }
            .toast(isPresented: viewStore.binding(\.$isLoading), content: {
                ToastView("Loading...").toastViewStyle(.indeterminate)
            })
            .toast(isPresented: viewStore.binding(\.$showMessage), dismissAfter: 2.0, content: {
                ToastView(viewStore.message).toastViewStyle(.information)
            })
            .navigationBarHidden(true)
        }
    }
}

//struct Upload_ID_View_Previews: PreviewProvider {
//    static var previews: some View {
//        Upload_ID_View()
//    }
//}
typealias BoolBlock = ((Bool) -> ())
struct IDUploadTableView: View {

    @Binding var isPresentedSheet: Bool

    var viewStore: ViewStore<Upload_ID_State, Upload_ID_Action>
    var settingBlock: BoolBlock

    let list: [String] = ["拍照", "从手机相册选择"]

    var body: some View {
        VStack {
            Group {
                ForEach(list, id: \.self) { text in
                        HStack {
                            Spacer()
                            Text(text)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(c_030364)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            switch text {
                            case "拍照":
                                viewStore.send(Upload_ID_Action.imageActionPick(.camera))
                                settingBlock(true)
                            case "从手机相册选择":
                                viewStore.send(Upload_ID_Action.imageActionPick(.photoLibrary))
                                settingBlock(true)
                            default: break
                            }
                        }
                        .frame(height: 50, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .frame(height: 50)
                    .background(c_F4F5F7)
                    .cornerRadius(12)
            }
            .listStyle(PlainListStyle())
            .padding(.top, 10)

            Button {
                settingBlock(false)
                isPresentedSheet = false
            } label: {
                Spacer()
                Text("取消")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular))
                    .frame(height: 50)
                Spacer()
            }
            .background(mainColor)
            .cornerRadius(12)
            .padding([.top], 33)
        }.padding([.leading, .trailing], 29)
    }
    
}
