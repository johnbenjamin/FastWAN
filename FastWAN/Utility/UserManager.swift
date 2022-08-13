//
//  UserManager.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation
import SwiftUI

struct UserManager {
    static var shared = UserManager()
    enum ConfigKeys {
        static let user = "FastWan_Login"
    }

    var hasCkeckedVersion: Bool = false
    var isLogin: Bool { loginInfo?.token != nil }

    private var loginInfo: LoginInfo? = {
        return Storage.retrieve(ConfigKeys.user, from: .documents, as: LoginInfo.self)
    }()

    var token: String {
        guard let token = loginInfo?.token else { return "Bearer 57840b01268cc006c7f529ed9f2bef14" }
        return "Bearer \(token)"
    }

    var userInfo: UserInfo? { loginInfo?.userInfo }

    func uploadUser(avatar: String) {
        guard var loginInfo = loginInfo else { return }
        loginInfo.userInfo?.avatar = avatar
        loginInfo.userInfo?.avatarBack = avatar
        save(loginInfo: loginInfo)
        guard let storage = Storage.retrieve(ConfigKeys.user, from: .documents, as: LoginInfo.self) else { return }
        UserManager.shared.loginInfo = storage
    }

    func save(loginInfo: LoginInfo?) {
        guard let info = loginInfo else { return }
        Storage.store(info, to: .documents, as: ConfigKeys.user)
    }

    func removeLoginData() {
        Storage.remove(ConfigKeys.user, from: .documents)
    }
}
