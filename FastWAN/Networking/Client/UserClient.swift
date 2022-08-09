//
//  UserClient.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/30.
//

import ComposableArchitecture

struct AvatarClient {
    var uploadAvatar: (_ avatar: String) -> Effect<RegisterModel, ProviderError>
}

struct UploadIDClient {
    var uploadID: (_ cardBackend: String, _ cardFront: String, _ idCardNo: String, _ realName: String) -> Effect<UserAuthModel, ProviderError>
}

struct UploadSignClient {
    var uploadSign: (_ url: String) -> Effect<UserAuthModel, ProviderError>
}

struct UploadTokenClient {
    var uploadTokenClient: () -> Effect<UploadTokenModel, ProviderError>
}

struct PrivateTokenClient {
    var getPrivateToken: (_ url: String) -> Effect<PrivateTokenModel, ProviderError>
}

struct VersionClient {
    var checkVersion: () -> Effect<VersionModel, ProviderError>
}

extension AvatarClient {
    static let live = AvatarClient.init { avatar in
        Provider.shared.uploadAvatar(avatar: avatar).eraseToEffect()
    }
}

extension UploadIDClient {
    static let live = UploadIDClient.init { cardBackend, cardFront, idCardNo, realName in
        Provider.shared.uploadIDCard(cardBackend: cardBackend, cardFront: cardFront, idCardNo: idCardNo, realName: realName).eraseToEffect()
    }
}

extension UploadSignClient {
    static let live = UploadSignClient.init { url in
        Provider.shared.uploadSign(url: url).eraseToEffect()
    }
}

extension UploadTokenClient {
    static let live = UploadTokenClient {
        Provider.shared.uploadToken().eraseToEffect()
    }
}

extension PrivateTokenClient {
    static let live = PrivateTokenClient { url in
        Provider.shared.privateToken(url: url).eraseToEffect()
    }
}

extension VersionClient {
    static let live = VersionClient {
        Provider.shared.version().eraseToEffect()
    }
}
