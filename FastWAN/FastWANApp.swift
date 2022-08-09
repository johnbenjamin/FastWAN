//
//  FastWANApp.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/12.
//

import SwiftUI

@main
struct FastWANApp: App {
    var body: some Scene {
        WindowGroup {
            if UserManager.shared.isLogin {
                MainPageView(store: .init(initialState: .init(),
                                          reducer: mainPageReducer,
                                          environment: .init(checkVersion: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
            } else {
                LoginView(store: .init(initialState: .init(),
                                       reducer: loginReducer,
                                       environment: .init(
                                        loginClient: .live, checkVersion: .live,
                                        mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
            }
        }
    }
}
