//
//  Environment.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/28.
//

import Foundation

public enum Environment {
    // MARK: Keys
    
    enum ConfigKey {
        static let apiURL = "http://120.232.174.157:6677"
        static let authKey = "Authorization"
        static let defualtAuth = "Bearer 57840b01268cc006c7f529ed9f2bef14"
        static let securityProtocolsURL = "http://wanapi.wesawtech.com/file/terms.html"
        static let UserPrivacyAgreementURL = "http://wanapi.wesawtech.com/file/security.html"
    }
    
    // MARK: Plist
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // MARK: Plist values
    
    static let apiURL: URL = {
        guard let url = URL(string: ConfigKey.apiURL) else {
            fatalError("API URL is invalid")
        }
        return url
    }()

    static let versionString: String? = {
        return infoDictionary["CFBundleShortVersionString"] as? String ?? nil
    }()
}
