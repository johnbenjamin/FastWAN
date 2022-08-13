//
//  AvatarView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import ToastUI

struct AvatarView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @State private var isPresentedSheet: Bool = false
    @State private var isImagePickerDisplay: Bool = false
    @Binding var avatar: String

    var store: Store<AvatarState, AvatarAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Divider().overlay(.white)
                    KFImage.url(URL(string: viewStore.avatarURLString))
                        .onSuccess({ result in
                            viewStore.send(AvatarAction.defualtImage(result.image))
                            if avatar != viewStore.avatarURLString {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                    avatar = viewStore.avatarURLString
                                }
                            }
                        })
                        .placeholder {
                            Image("Avatar.Backgourd")
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(c_E2E9FB)
                        Spacer()
                }
                .navigationTitle("个人头像")
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(c_030364)
                .font(.system(size: 18, weight: .bold))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("x")
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresentedSheet = true
                        } label: {
                            Image("dot")
                        }
                        .adaptiveSheet(isPresented: $isPresentedSheet, detents: [.medium()], smallestUndimmedDetentIdentifier: .large, content: {
                            AvatarSettingView(viewStore: viewStore) { displayPicker in
                                isImagePickerDisplay = displayPicker
                            }
                            .sheet(isPresented: $isImagePickerDisplay, content: {
                                ImagePickerView(selectedImage: viewStore.binding(get: { $0.selectedImage }, send: { AvatarAction.starUpload($0) { token in
                                    guard let image = viewStore.selectedImage else { return }
                                    QNImageUper.imageUpload(image:image, token: token ?? "") { isOK, url in
                                        viewStore.send(AvatarAction.uploadAvatarURL(isOK, url ?? ""))
                                    }
                                } }), sourceType: viewStore.sourceType)
                            })
                        })
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

struct AvatarSettingView: View {
    typealias BoolBlock = ((Bool) -> ())

    @SwiftUI.Environment(\.presentationMode) var presentationMode
    var viewStore: ViewStore<AvatarState, AvatarAction>
    var settingBlock: BoolBlock
    let list: [String] = ["拍照", "从手机相册选择", "保存图片"]

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
                                viewStore.send(AvatarAction.imageActionPick(.camera))
                                settingBlock(true)
                            case "从手机相册选择":
                                viewStore.send(AvatarAction.imageActionPick(.photoLibrary))
                                settingBlock(true)
                            case "保存图片":
                                viewStore.send(AvatarAction.imageActionPick(.savedPhotosAlbum))
                                settingBlock(false)
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
                presentationMode.wrappedValue.dismiss()
            } label: {
                Spacer()
                Text("取消")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
            }.frame(maxWidth:  .infinity)
                .background(mainColor)
                .cornerRadius(12)
                .frame(height: 50)
                .padding([.top], 33)
        }.padding([.leading, .trailing], 29)
            .onDisappear {
            }

    }
    
}

//struct AvatarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AvatarView()
//    }
//}
