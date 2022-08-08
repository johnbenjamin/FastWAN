//
//  UserManager.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/29.
//

import Foundation

struct UserManager {
    static var shared = UserManager()
    enum ConfigKeys {
        static let user = "FastWan_Login"
    }

    private var loginInfo: LoginInfo? {
        return Storage.retrieve(ConfigKeys.user, from: .documents, as: LoginInfo.self)
    }

    var isLogin: Bool { loginInfo?.token != nil }
    
    var token: String {
        guard let token = loginInfo?.token else { return "Bearer 57840b01268cc006c7f529ed9f2bef14" }
        return "Bearer \(token)"
    }

    var userInfo: UserInfo? { loginInfo?.userInfo }
    

    func save(loginInfo: LoginInfo?) {
        guard let info = loginInfo else { return }
        Storage.store(info, to: .documents, as: ConfigKeys.user)
    }

    func removeLoginData() {
        Storage.remove(ConfigKeys.user, from: .documents)
    }
}
