//
//  NetworkRouter.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/26.
//

import Foundation

enum Router {
    case login(userName: String, password: String)
    case register(userName: String, captcha: String, password: String)
    case findPassword(userName: String, captcha: String, password: String)
    case resetPassword(newPassword: String, oldPassWord: String)
    case captcha(phoneNumber: String)
    case uploadAvatar(avatar: String)
    case uploadIDCard(cardBackend: String, cardFront: String, idCardNo: String, realName: String)
    case uploadSign(url: String)
    case productList(limit: Int, page: Int)
    case getMyConfig
    case version

    case uploadToken
    case priviteToken(url: String)
}

extension Router: NetworkRoute {
    var path: String {
        switch self {
        case .login:
            return "/api/users/login"
        case .register:
            return "/api/users/register"
        case .findPassword:
            return "/api/users/password"
        case .resetPassword:
            return "/api/users/reset_pwd"
        case .captcha:
            return "/api/users/code"
        case .uploadAvatar:
            return "/api/users/reset_avatar"
        case .uploadIDCard:
            return "/api/users/approve"
        case .uploadSign:
            return "/api/users/approve/sign"
        case .productList:
            return "/api/products/product/up/page"
        case .getMyConfig:
            return "/get_my_config"

        case .uploadToken:
            return "/upload_token"
        case .priviteToken:
            return "/privite_token"
        case .version:
            return "/version"
        }
    }

    var method: NetworkMethod {
        switch self {
        case .login,
                .register,
                .findPassword,
                .resetPassword,
                .captcha,
                .uploadAvatar,
                .uploadIDCard,
                .productList,
                .uploadSign,
                .priviteToken:
            return .post

        case .uploadToken,
            .getMyConfig,
            .version:
            return .get
        }
    }

    var body: [String : String]? {
        switch self {
        case .login(let username, let password):
            return ["password": password, "user_type": "1", "username": username]
        case .register(let username, let captcha, let password):
            return ["password": password, "user_type": "1", "phone_number": username, "code": captcha]
        case .findPassword(let userName, let captcha, let password):
            return ["password": password, "phone_number": userName, "code": captcha]
        case .resetPassword(let newPassword, let oldPassWord):
            return ["new_pwd": newPassword, "old_pwd": oldPassWord]
        case .captcha(let phoneNumber):
            return ["phone_number": phoneNumber]
        case .uploadAvatar(avatar: let avatar):
            return ["avatar": avatar]
        case .uploadIDCard(cardBackend: let cardBackend, cardFront: let cardFront, idCardNo: let idCardNo, realName: let realName):
            return ["card_backend": cardBackend, "card_front": cardFront, "id_card_no": idCardNo, "real_name": realName]
        case .uploadSign(let url):
            return ["sign_photo": url]
        case .productList(let limit, let page):
            return ["limit": "\(limit)", "page": "\(page)"]
        case .getMyConfig:
            return [:]

        case .uploadToken:
            return [:]
        case .priviteToken(let url):
            return ["url": "http://oss.wesaw.cn/\(url)"]
        case .version:
            return [:]
        }
    }
}
