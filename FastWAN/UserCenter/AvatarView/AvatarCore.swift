//
//  AvatarCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation
import ComposableArchitecture
import SwiftUI

typealias StringBlock = ((String?) -> ())?
var uploadBlock: StringBlock?

struct AvatarState: Equatable {

    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var message: String = ""

    @BindableState var avatarURLString: String = UserManager.shared.userInfo?.avatar ?? ""
    @BindableState var selectedImage: UIImage?
    @BindableState var isLoading: Bool = false
    @BindableState var showMessage: Bool = false
}

enum AvatarAction: Equatable, BindableAction {
    static func == (lhs: AvatarAction, rhs: AvatarAction) -> Bool { false }
    
    case defualtImage(UIImage)
    case imageActionPick(UIImagePickerController.SourceType)
    case starUpload(UIImage?, uploadBlock: StringBlock)
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
    case .defualtImage(let defualt):
        state.selectedImage = defualt
        return .none

    case .starUpload(let image, let block):
        guard let image = image else {
            return .none
        }
        state.isLoading = true
        uploadBlock = block
        state.selectedImage = image
        return .concatenate(environment.uploadTokenClient
                                .uploadTokenClient()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(AvatarAction.upload)
                                .cancellable(id: AvatarCancelId()))

    case .upload(.success(let response)):
        guard response.code == 200 else {
            state.isLoading = false
            state.message = response.msg
            state.showMessage = true
            return .none
        }
        guard let block = uploadBlock else { return .none }
        block!(response.info.token)
        return .none

    case .upload(.failure(let error)):
        state.isLoading = false
        state.message = "上传图片失败,请稍后再试"
        state.showMessage = true
        return .none

    case .uploadAvatarURL(let isOK, let url):
        guard isOK, let url = url else {
            state.isLoading = false
            state.message = "上传图片失败,请稍后再试"
            state.showMessage = true
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
        state.avatarURLString = response.info.url
        return .concatenate(environment.avatarClient
                                .uploadAvatar(response.info.url)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(AvatarAction.uploadResponse)
                                .cancellable(id: AvatarCancelId()))
    case .getPrivateTokenResponse(.failure(_)):
        state.isLoading = false
        state.message = "网络错误,请稍后再试"
        state.showMessage = true
        return .none

    case .imageActionPick(let sourceType):
        state.sourceType = sourceType
        switch state.sourceType {
        case .camera: break
        case .photoLibrary: break
        case .savedPhotosAlbum:
            state.isLoading = false
            if state.selectedImage != nil {
                UIImageWriteToSavedPhotosAlbum(state.selectedImage!, nil, nil, nil)
                state.message = "保存成功"
                state.showMessage = true
                return .none
            }
        @unknown default: break
        }
        return .none

    case .binding(_):
        return .none
    
    case .uploadResponse(.success(let response)):
        state.isLoading = false
        state.message = response.msg
        state.showMessage = true
        if response.code == 200 {
            UserManager.shared.uploadUser(avatar: state.avatarURLString)
        }
        return .none
    case .uploadResponse(.failure(_)):
        state.isLoading = false
        state.message = "网络错误,请稍后再试"
        state.showMessage = false
        return .none
    }
}.binding()
