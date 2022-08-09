//
//  LoginCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import ComposableArchitecture

struct LoginState: Equatable {
    var userName: String = ""
    var password: String = ""
    @BindableState var isLoading: Bool = false
    @BindableState var isFinishLoad: Bool = false
    @BindableState var LoginSuccess: Bool = false
    @BindableState var isAgree: Bool = false
    var message: String = ""
    var isUserInputed: Bool {
        userName.count > 3 && password.count > 5 && isAgree
    }
}

enum LoginAction: Equatable, BindableAction {
    
    static func == (lhs: LoginAction, rhs: LoginAction) -> Bool { false }
    
    enum InputType {
        case userName(String)
        case password(String)
    }
    
    case agreePolicy
    case userIput(InputType)
    case login
    case loginResponse(Result<LoginModel, ProviderError>)
    case binding(BindingAction<LoginState>)
}

struct LoginEnvironment {
    var loginClient: LoginClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    struct LoginCancelId: Hashable {}

    switch action {
    case .agreePolicy:
        state.isAgree = true
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
    }
}.binding()
