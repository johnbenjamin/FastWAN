//
//  LoginCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import ComposableArchitecture
import SwiftUI

struct LoginState: Equatable {
    var userName: String = ""
    var password: String = ""
    @BindableState var isLoading: Bool = false
    @BindableState var isFinishLoad: Bool = false
    @BindableState var LoginSuccess: Bool = false
    @BindableState var isAgree: Bool = false
    @BindableState var isPresentVersionChecker: Bool = false
    var message: String = ""
    var version: VersionInfo?
    var isUserInputed: Bool {
        userName.count > 3 && password.count > 4 && isAgree
    }
}

enum LoginAction: Equatable, BindableAction {
    
    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool { false }
    
    enum InputType {
        case userName(String)
        case password(String)
    }
    
    case agreePolicy(Bool)
    case userIput(InputType)
    case login
    case loginResponse(Result<LoginModel, ProviderError>)
    case binding(BindingAction<LoginState>)

    case checkVersion
    case versionResponse(Result<VersionModel, ProviderError>)
}

struct LoginEnvironment {
    var loginClient: LoginClient
    var checkVersion: VersionClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    struct LoginCancelId: Hashable {}

    switch action {
    case .agreePolicy(let agree):
        state.isAgree = agree
        return .none
    case .userIput(.userName(let userName)):
        state.userName = userName
        return.none
    case .userIput(.password(let password)):
        state.password = password
        return .none
    case .login:
        state.isLoading = true
        return .concatenate(environment.loginClient
                                .login(state.userName, state.password)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(LoginAction.loginResponse)
                                .cancellable(id: LoginCancelId()))
    case .loginResponse(.success(let login)):
        state.isLoading = false
        state.message = login.msg
        state.LoginSuccess = login.code == 200 ? true : false
        state.isFinishLoad = true
        UserManager.shared.save(loginInfo: login.info)
        return .none
    case .loginResponse(.failure(let error)):
        state.isLoading = false
        state.message = "网络错误, 请稍后再试"
        state.isFinishLoad = true
        return .none
    case .binding(_):
        return .none

    case .checkVersion:
        return .concatenate(environment.checkVersion
                                .checkVersion()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(LoginAction.versionResponse)
                                .cancellable(id: LoginCancelId()))

    case .versionResponse(.success(let version)):
        guard let localVersion = Environment.versionString?.replacingOccurrences(of: ".", with: ""), let localVersionNumber = Float(localVersion) else { return .none }
        guard let serverVersion = version.info?.versionCode?.replacingOccurrences(of: ".", with: ""), let serverVersionNumber = Float(serverVersion) else { return .none }

        if  serverVersionNumber > localVersionNumber {
            state.isPresentVersionChecker = UserManager.shared.hasCkeckedVersion == false
            UserManager.shared.hasCkeckedVersion = true
            state.version = version.info
        }
        return .none
    case .versionResponse(.failure(_)):
        return .none
    }
}.binding()
