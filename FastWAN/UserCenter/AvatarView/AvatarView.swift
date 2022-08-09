//
//  AvatarView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct AvatarView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    private let user = UserManager.shared.userInfo
    var store: Store<AvatarState, AvatarAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    Divider().overlay(.white)
                    KFImage.url(URL(string: user?.avatar ?? ""))
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
                            viewStore.send(AvatarAction.presentSheet(true))
                        } label: {
                            Image("dot")
                        }
                    }
                }
            }
            .adaptiveSheet(isPresented: viewStore.binding(\.$isPresentedSheet), detents: [.medium()], smallestUndimmedDetentIdentifier: .large) {
                AvatarSettingView(viewStore: viewStore)
            }
            .sheet(isPresented: viewStore.binding(\.$isImagePickerDisplay), content: {
                ImagePickerView(selectedImage: viewStore.binding(get: { $0.selectedImage }, send: { AvatarAction.starUpload($0) { token in
                    QNImageUper.imageUpload(image: viewStore.selectedImage, token: token ?? "") { isOK, url in
                        viewStore.send(AvatarAction.uploadAvatarURL(isOK, url ?? ""))
                    }
                } }), sourceType: viewStore.sourceType)
            })
            .navigationBarHidden(true)
        }
    }
}

struct AvatarSettingView: View {
    var viewStore: ViewStore<AvatarState, AvatarAction>
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
                            case "从手机相册选择":
                                viewStore.send(AvatarAction.imageActionPick(.photoLibrary))
                            case "保存图片":
                                viewStore.send(AvatarAction.imageActionPick(.savedPhotosAlbum))
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
                viewStore.send(AvatarAction.presentSheet(false))
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
