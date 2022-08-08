//
//  RegisterClient.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/28.
//

import ComposableArchitecture

struct RegisterClient {
    var register: (_ userName: String, _ captcha: String, _ password: String) -> Effect<RegisterModel, ProviderError>
}

struct CaptchaClient {
    var captcha: (_ phoneNumber: String) -> Effect<RegisterModel, ProviderError>
}

struct LoginClient {
    var login: (_ userName: String, _ password: String) -> Effect<LoginModel, ProviderError>
}

struct FindPasswordClient {
    var findPassword: (_ userName: String, _ captcha: String, _ password: String) -> Effect<RegisterModel, ProviderError>
}

struct ResetPasswordClient {
    var resetPassword: (_ newPassword: String, _ oldPassWord: String) -> Effect<RegisterModel, ProviderError>
}

// MARK: - Extension
extension RegisterClient {
    static let live = RegisterClient { userName, captcha, password in
        Provider.shared.register(userName: userName, captcha: captcha, password: password)
            .eraseToEffect()
    }
}

extension CaptchaClient {
    static let live = CaptchaClient { phoneNumber in
        Provider.shared.captcha(phoneNumber: phoneNumber)
            .eraseToEffect()
    }
}

extension LoginClient {
    static let live = LoginClient.init { userName, password in
        Provider.shared.login(userName: userName, password: password)
            .eraseToEffect()
    }
}

extension FindPasswordClient {
    static let live = FindPasswordClient.init { userName, captcha, password in
        Provider.shared.findPassword(userName: userName, captcha: captcha, password: password)
            .eraseToEffect()
    }
}

extension ResetPasswordClient {
    static let live = ResetPasswordClient.init { newPassword, oldPassWord in
        Provider.shared.resetPassword(newPassword: newPassword, oldPassWord: oldPassWord).eraseToEffect()
    }
}
