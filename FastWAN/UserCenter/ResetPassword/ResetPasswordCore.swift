//
//  ResetPasswordCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/31.
//

import Foundation
import ComposableArchitecture

struct ResetPasswordState: Equatable {
    var oldPassword: String
    var newPassword: String
    var verifyPassword: String

    var isSamePassword: Bool = false
    var isUserInputed: Bool { oldPassword.count > 8 && newPassword.count > 8 && verifyPassword == newPassword }
}

enum ResetPasswordAction {
    enum InputType {
        case oldPassword(String)
        case newPassword(String)
        case verifyPassword(String)
    }

    case input(InputType)
    case send
    case resetResponse(Result<RegisterModel, ProviderError>)
}

struct ResetPasswordEnvironment {
    var resetpasswordClient: ResetPasswordClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let resetPasswordReducer = Reducer<ResetPasswordState, ResetPasswordAction, ResetPasswordEnvironment> { state, action, environment in
    struct ResetPasswordCancelId: Hashable {}

    switch action {
    case .input(let input):
        state.isSamePassword = false
        switch input {
        case .oldPassword(let oldPassword):
            state.oldPassword = oldPassword
        case .newPassword(let newPassword):
            state.newPassword = newPassword
        case .verifyPassword(let verifyPassword):
            state.verifyPassword = verifyPassword
        }
        return .none

    case .send:
        state.isSamePassword = state.verifyPassword == state.newPassword
        guard state.isSamePassword else {
            return .none
        }

        return .concatenate(environment.resetpasswordClient
                                .resetPassword(state.oldPassword, state.newPassword)
                  .receive(on: environment.mainQueue)
                  .catchToEffect()
                  .map(ResetPasswordAction.resetResponse)
                  .cancellable(id: ResetPasswordCancelId()))

    case .resetResponse(.success(let response)):
        return .none

    case .resetResponse(.failure(let error)):
        return .none
    }
}
