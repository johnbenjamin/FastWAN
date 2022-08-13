//
//  RegisterCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/28.
//

import ComposableArchitecture

enum RegisterPageType {
    case register
    case findPassword
}

struct RegisterState: Equatable {

    var pageType: RegisterPageType
    var captcha: String = ""
    var userName: String = ""
    var password: String = ""
    @BindableState var isLoading: Bool = false
    @BindableState var isFinishLoad: Bool = false
    var registSuccess: Bool = false
    var message: String = ""
    var isUserInputed: Bool {
        userName.count > 8 && password.count > 8 && captcha.count > 0
    }
}

enum RegisterAction: Equatable, BindableAction {
    static func == (lhs: RegisterAction, rhs: RegisterAction) -> Bool { false }

    enum InputType {
        case captcha(String)
        case userName(String)
        case password(String)
    }

    case pageType(RegisterPageType)
    case userInput(InputType)
    case captcha
    case captchaResponse(Result<RegisterModel, ProviderError>)
    case register
    case registerResponse(Result<RegisterModel, ProviderError>)
    case binding(BindingAction<RegisterState>)
}

struct RegisterEnvironment {
    var registerClient: RegisterClient
    var captchaClient: CaptchaClient
    var findPasswordClient: FindPasswordClient
    
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

// MARK: - Reducer
let registerReducer =
  Reducer<RegisterState, RegisterAction, RegisterEnvironment> { state, action, environment in
      struct RegisterCancelId: Hashable {}

      switch action {
      case .captcha:
          state.isLoading = true
          return .concatenate(environment.captchaClient
                    .captcha(state.userName)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(RegisterAction.captchaResponse)
                    .cancellable(id: RegisterCancelId()))

      case .captchaResponse(.success(let captcha)):
          state.isLoading = false
          state.message = captcha.msg
          return.none

      case .captchaResponse(.failure(let error)):
          state.isLoading = false
          return.none

      case .register:
          state.isLoading = true
          state.isFinishLoad = false
          if state.pageType == .register {
              return .concatenate(
                environment.registerClient
                    .register(state.userName, state.captcha, state.password)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(RegisterAction.registerResponse)
                    .cancellable(id: RegisterCancelId()))
          } else {
              return .concatenate(
                environment.findPasswordClient
                    .findPassword(state.userName, state.captcha, state.password)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map(RegisterAction.registerResponse)
                    .cancellable(id: RegisterCancelId()))
          }
          
      case .registerResponse(.success(let register)):
          state.isLoading = false
          state.message = register.info ?? ""
          state.registSuccess = register.code == 0 ? true : false
          state.isFinishLoad = true
          return .none
          
      case .registerResponse(.failure(let error)):
          state.isLoading = false
          state.registSuccess = false
          state.isFinishLoad = true
          return .none
          
      case .userInput(.userName(let userName)):
          state.userName = userName
          return .none
          
      case .userInput(.password(let password)):
          state.password = password
          return .none
          
      case .userInput(.captcha(let captcha)):
          state.captcha = captcha
          return .none
      case .binding:
          return .none
      case .pageType(let pageType):
          state.pageType = pageType
          return.none
      }
  }.binding()
