//
//  MainPageStore.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/10.
//

import ComposableArchitecture

struct MainPageState: Equatable {
    var version: VersionInfo?
    @BindableState var isPresentVersionChecker: Bool = false
}

enum MainPageAction: Equatable, BindableAction {
    static func == (lhs: MainPageAction, rhs: MainPageAction) -> Bool { false }
    
    case checkVersion
    case versionResponse(Result<VersionModel, ProviderError>)
    case binding(BindingAction<MainPageState>)
}

struct MainPageEnvironment {
    var checkVersion: VersionClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let mainPageReducer = Reducer<MainPageState, MainPageAction, MainPageEnvironment> { state, action, environment in
    struct MainPageCancelId: Hashable {}

    switch action {
    case .checkVersion:
        return .concatenate(environment.checkVersion
                                .checkVersion()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(MainPageAction.versionResponse)
                                .cancellable(id: MainPageCancelId()))

    case .versionResponse(.success(let version)):
        guard let localVersion = Environment.versionString?.replacingOccurrences(of: ".", with: ""), let localVersionNumber = Float(localVersion) else { return .none }
        guard let serverVersion = version.info?.versionCode?.replacingOccurrences(of: ".", with: ""), let serverVersionNumber = Float(serverVersion) else { return .none }

        if  serverVersionNumber > localVersionNumber {
            state.isPresentVersionChecker = UserManager.shared.hasCkeckedVersion == false
            UserManager.shared.hasCkeckedVersion = true
            state.version = version.info
        }
        return .none
    case .versionResponse(.failure(_)):
        return .none
    case .binding(_):
        return .none
    }
}.binding()
