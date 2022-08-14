//
//  UploadIDCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/30.
//

import Foundation
import UIKit
import ComposableArchitecture

enum IDCardEnd {
    case cardFrond
    case cardBack
}

struct Upload_ID_State: Equatable {
    static func == (lhs: Upload_ID_State, rhs: Upload_ID_State) -> Bool { false }
    
    var idCardEndType: IDCardEnd = .cardFrond
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var cardFrond: UIImage?
    var cardBack: UIImage?
    var cardBackendURL: String = ""
    var cardFrontURL: String = ""
    var idCardNo: String = ""
    var realName: String = ""
    var isCheckBox: Bool = false
    var message: String = ""
    var uploadBlock: ((String?) -> ())?

    var selectImage: UIImage? {
        set {
            switch idCardEndType {
            case .cardFrond:
                cardFrond = newValue
            case .cardBack:
                cardBack = newValue
            }
        }
        get {
            switch idCardEndType {
            case .cardFrond:
                return cardFrond
            case .cardBack:
                return cardBack
            }
        }
    }

    var ready: Bool {
        !cardFrontURL.isEmpty && !cardBackendURL.isEmpty && !idCardNo.isEmpty && !realName.isEmpty && isCheckBox
    }

    @BindableState var isLoading: Bool = false
    @BindableState var showMessage: Bool = false
}

enum Upload_ID_Action: Equatable, BindableAction {
    static func == (lhs: Upload_ID_Action, rhs: Upload_ID_Action) -> Bool { false }

    enum InputType {
        case idNumber(String)
        case realName(String)
    }

    case pick(IDCardEnd)
    case imageActionPick(UIImagePickerController.SourceType)
    case input(InputType)
    case takePhoto(UIImage?, uploadBlock: ((String?) -> ())?)
    case upload(Result<UploadTokenModel, ProviderError>)
    case uploadAvatarURL(Bool, String?)
    case getPrivateTokenResponse(Result<PrivateTokenModel, ProviderError>)
    case uploadResponse(Result<UserAuthModel, ProviderError>)
    case CheckTheBox
    case send
    case binding(BindingAction<Upload_ID_State>)
}

struct Upload_ID_Environment {
    var uploadIDClient: UploadIDClient
    var uploadTokenClient: UploadTokenClient
    var getPrivateToken: PrivateTokenClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let uploadIDReducer = Reducer<Upload_ID_State, Upload_ID_Action, Upload_ID_Environment> { state, action, environment in
    struct IDCancelId: Hashable {}

    switch action {
    case .pick(let idCardEnd):
        state.idCardEndType = idCardEnd
        return .none
    
    case .imageActionPick(let sourceType):
        state.sourceType = sourceType
        return .none

    case .takePhoto(let image, let block):
        guard let image = image else { return .none }
        state.isLoading = true
        state.uploadBlock = block
        switch state.idCardEndType {
        case .cardFrond:
            state.cardFrond = image
        case .cardBack:
            state.cardBack = image
        }
        return .concatenate(environment.uploadTokenClient
                                .uploadTokenClient()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(Upload_ID_Action.upload)
                                .cancellable(id: IDCancelId()))
    case .upload(.success(let response)):
        guard response.code == 200 else {
            state.message = response.msg
            state.isLoading = false
            state.showMessage = true
            return .none
        }
        guard let block = state.uploadBlock else { return .none }
        block(response.info.token)
        return .none
    case .upload(.failure(let error)):
        state.message = "网络错误,请稍后再试"
        state.isLoading = false
        state.showMessage = true
        return .none
    
    case .uploadAvatarURL(let isOK, let url):
        guard isOK, let url = url else {
            state.message = "上传图片失败,请稍后再试"
            state.isLoading = false
            state.showMessage = true
            return .none
        }
        return .concatenate(environment.getPrivateToken
                                .getPrivateToken(url)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(Upload_ID_Action.getPrivateTokenResponse)
                                .cancellable(id: IDCancelId()))

    case .getPrivateTokenResponse(.success(let response)):
        state.message = response.msg
        state.isLoading = false
        state.showMessage = true
        switch state.idCardEndType {
        case .cardFrond:
            state.cardFrontURL = response.info.url
        case .cardBack:
            state.cardBackendURL = response.info.url
        }
        return .none
    case .getPrivateTokenResponse(.failure(_)):
        state.message = "网络错误,请稍后再试"
        state.isLoading = false
        state.showMessage = true
        return .none
        
    case .send:
        state.showMessage = false
        return .concatenate(environment.uploadIDClient
                                .uploadID(state.cardBackendURL, state.cardFrontURL, state.idCardNo, state.realName)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(Upload_ID_Action.uploadResponse)
                                .cancellable(id: IDCancelId())
        )

    case .uploadResponse(.success(let response)):
        state.message = response.msg
        state.isLoading = false
        state.showMessage = true
        return .none

    case .uploadResponse(.failure(let error)):
        state.message = "网络错误,请稍后再试"
        state.isLoading = false
        state.showMessage = true
        return .none

    case .binding(_):
        return .none
    case .input(let input):
        switch input {
        case .idNumber(let number):
            state.idCardNo = number
            return .none
        case .realName(let realName):
            state.realName = realName
            return .none
        }
    case .CheckTheBox:
        state.isCheckBox = !state.isCheckBox
        return .none
    }
}.binding()
