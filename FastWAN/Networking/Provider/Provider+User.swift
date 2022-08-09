//
//  Provider+User.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation
import Combine

extension Provider {
    func uploadAvatar(avatar: String) -> AnyPublisher<RegisterModel, ProviderError> {
        let request = Router.uploadAvatar(avatar: avatar).request
        return Provider.shared.requestAuthorizedPublisher(request)
    }

    func uploadIDCard(cardBackend: String, cardFront: String, idCardNo: String, realName: String) -> AnyPublisher<UserAuthModel, ProviderError> {
        let request = Router.uploadIDCard(cardBackend: cardBackend, cardFront: cardFront, idCardNo: idCardNo, realName: realName).request
        return Provider.shared.requestAuthorizedPublisher(request)
    }

    func uploadSign(url: String) -> AnyPublisher<UserAuthModel, ProviderError> {
        let request = Router.uploadSign(url: url).request
        return Provider.shared.requestAuthorizedPublisher(request)
    }

    func uploadToken() -> AnyPublisher<UploadTokenModel, ProviderError> {
        let request = Router.uploadToken.request
        return Provider.shared.requestAuthorizedPublisher(request)
    }

    func privateToken(url: String) -> AnyPublisher<PrivateTokenModel, ProviderError> {
        let request = Router.priviteToken(url: url).request
        return Provider.shared.requestAuthorizedPublisher(request)
    }

    func version() -> AnyPublisher<VersionModel, ProviderError> {
        let request = Router.version.request
        return Provider.shared.requestAuthorizedPublisher(request)
    }
}
