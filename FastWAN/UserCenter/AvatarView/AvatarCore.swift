//
//  AvatarCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct AvatarState: Equatable {
    static func == (lhs: AvatarState, rhs: AvatarState) -> Bool { false }
    
    var avatarURL: URL? = URL(string: UserManager.shared.userInfo?.avatar_back ?? "")
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var message: String = ""
    var uploadBlock: ((String?) -> ())?

    @BindableState var selectedImage: UIImage = UIImage()
    @BindableState var isImagePickerDisplay = false
    @BindableState var isPresentedSheet = false
}

enum AvatarAction: Equatable, BindableAction {
    static func == (lhs: AvatarAction, rhs: AvatarAction) -> Bool { false }
    
    case presentSheet(Bool)
    case imageActionPick(UIImagePickerController.SourceType)
    case starUpload(UIImage?, uploadBlock: ((String?) -> ()))
    case upload(Result<UploadTokenModel, ProviderError>)
    case uploadAvatarURL(Bool, String?)
    case getPrivateTokenResponse(Result<PrivateTokenModel, ProviderError>)
    case uploadResponse(Result<RegisterModel, ProviderError>)
    case binding(BindingAction<AvatarState>)
}

struct AvatarEnvironment {
    var avatarClient: AvatarClient
    var getPrivateToken: PrivateTokenClient
    var uploadTokenClient: UploadTokenClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let avatarReducer = Reducer<AvatarState, AvatarAction, AvatarEnvironment> { state, action, environment in
    struct AvatarCancelId: Hashable {}

    switch action {
    case .presentSheet(let isPresented):
        state.isPresentedSheet = isPresented
        return .none

    case .starUpload(let image, let block):
        guard let image = image else {
            return .none
        }
        state.uploadBlock = block
        state.selectedImage = image
        return .concatenate(environment.uploadTokenClient
                                .uploadTokenClient()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(AvatarAction.upload)
                                .cancellable(id: AvatarCancelId()))

    case .upload(.success(let response)):
        guard response.code == 200 else {
            state.message = response.msg
            return .none
        }
        guard let block = state.uploadBlock else { return .none }
        block(response.info.token)
        return .none

    case .upload(.failure(let error)):
        return .none

    case .uploadAvatarURL(let isOK, let url):
        guard isOK, let url = url else {
            state.message = "上传图片失败,请稍后再试"
            return .none
        }
        return .concatenate(environment.getPrivateToken
                                .getPrivateToken(url)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(AvatarAction.getPrivateTokenResponse)
                                .cancellable(id: AvatarCancelId()))
        
    case .getPrivateTokenResponse(.success(let response)):
        state.message = response.msg
        return .concatenate(environment.avatarClient
                                .uploadAvatar(response.info.url)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(AvatarAction.uploadResponse)
                                .cancellable(id: AvatarCancelId()))
    case .getPrivateTokenResponse(.failure(_)):
        state.message = "网络错误,请稍后再试"
        return .none

    case .imageActionPick(let sourceType):
        state.sourceType = sourceType
        state.isPresentedSheet = false
        switch state.sourceType {
            case .camera:
            state.isImagePickerDisplay = true
        case .photoLibrary:
            state.isImagePickerDisplay = true
        case .savedPhotosAlbum:
            state.isImagePickerDisplay = false
            UIImageWriteToSavedPhotosAlbum(state.selectedImage, nil, nil, nil)
        @unknown default: break
        }
        return .none

    case .binding(_):
        return .none
    
    case .uploadResponse(_):
        return .none
    }
}.binding()
