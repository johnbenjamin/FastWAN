//
//  Provider+Register.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/28.
//

import Foundation
import Combine

extension Provider {
    func register(userName: String, captcha: String, password: String) -> AnyPublisher<RegisterModel, ProviderError> {
        let request = Router.register(userName: userName, captcha: captcha, password: password).request
        return requestAuthorizedPublisher(request)
    }

    func captcha(phoneNumber: String) -> AnyPublisher<RegisterModel, ProviderError> {
        let request = Router.captcha(phoneNumber: phoneNumber).request
        return requestAuthorizedPublisher(request)
    }

    func login(userName: String, password: String) -> AnyPublisher<LoginModel, ProviderError> {
        let request = Router.login(userName: userName, password: password).request
        return requestAuthorizedPublisher(request)
    }

    func findPassword(userName: String, captcha: String, password: String) -> AnyPublisher<RegisterModel, ProviderError> {
        let request = Router.findPassword(userName: userName, captcha: captcha, password: password).request
        return requestAuthorizedPublisher(request)
    }

    func resetPassword(newPassword: String, oldPassWord: String) -> AnyPublisher<RegisterModel, ProviderError> {
        let request = Router.resetPassword(newPassword: newPassword, oldPassWord: oldPassWord).request
        return requestAuthorizedPublisher(request)
    }
}
