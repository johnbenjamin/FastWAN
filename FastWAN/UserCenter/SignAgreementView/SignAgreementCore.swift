//
//  SignAgreementCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/7.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import XCTest

struct SignAgreementState: Equatable {
    static func == (lhs: SignAgreementState, rhs: SignAgreementState) -> Bool { false }
    
    var message: String = ""
    var uploadBlock: ((String?) -> ())?
}

enum SignAgreementAction: Equatable, BindableAction {
    static func == (lhs: SignAgreementAction, rhs: SignAgreementAction) -> Bool { false }
    
    case uploadSign(uploadBlock: ((String?) -> ()))
    case uploadSignURL(Bool, String?)
    case getUploadToken(Result<UploadTokenModel, ProviderError>)
    case getPrivateTokenResponse(Result<PrivateTokenModel, ProviderError>)
    case uploadResponse(Result<UserAuthModel, ProviderError>)
    case binding(BindingAction<SignAgreementState>)
}

struct SignAgreementEnvironment {
    var uploadTokenClient: UploadTokenClient
    var getPrivateToken: PrivateTokenClient
    var uploadSignClient: UploadSignClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let uploadSignReducer = Reducer<SignAgreementState, SignAgreementAction, SignAgreementEnvironment> { state, action, environment in
    struct UPloadSignCancelId: Hashable {}

    switch action {
    case .uploadSign(let block):
        state.uploadBlock = block
        return .concatenate(environment.uploadTokenClient
                                .uploadTokenClient()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(SignAgreementAction.getUploadToken)
                                .cancellable(id: UPloadSignCancelId()))
    case .getUploadToken(.success(let response)):
        guard response.code == 200 else {
            state.message = response.msg
            return .none
        }
        guard let block = state.uploadBlock else { return .none }
        block(response.info.token)
        return .none
    case .getUploadToken(.failure(let error)):
        state.message = "网络错误,请稍后再试"
        return .none
    case .uploadSignURL(let isOK, let url):
        guard isOK, let url = url else {
            state.message = "上传图片失败,请稍后再试"
            return .none
        }
        return .concatenate(environment.getPrivateToken
                                .getPrivateToken(url)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(SignAgreementAction.getPrivateTokenResponse)
                                .cancellable(id: UPloadSignCancelId()))

    case .getPrivateTokenResponse(.success(let response)):
        return .concatenate(environment.uploadSignClient
                                .uploadSign(response.info.url)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(SignAgreementAction.uploadResponse)
                                .cancellable(id: UPloadSignCancelId()))
    case .getPrivateTokenResponse(.failure(let error)):
        state.message = "网络错误,请稍后再试"
        return .none

    case .uploadResponse(.success(let response)):
        if response.code == 200 {
            state.message = "提交成功"
        }
        state.message = response.msg
        return .none
    case .uploadResponse(.failure(let error)):
        state.message = "网络错误,请稍后再试"
        return .none

    case .binding(_):
        return .none
    }
}.binding()
