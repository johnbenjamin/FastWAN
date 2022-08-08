//
//  PickThreadCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/7.
//

import Foundation
import ComposableArchitecture

struct PickThreadState: Equatable {
    @BindableState var threadList: [ThreadInfoModel] = []
    var isUserInputed: Bool { (threadList.firstIndex { $0.isSet } != nil) }
}

enum PickThreadAction: BindableAction {
    case getList
    case response(Result<ThreadProperty, ProviderError>)
    case binding(BindingAction<PickThreadState>)
}

struct PickThreadEnvironment {
    var threadListClient: ThreadListClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let threadReducer = Reducer<PickThreadState, PickThreadAction, PickThreadEnvironment> { state, action, environment in
    struct ThreadCancelId: Hashable {}

    switch action {
    case .getList:
        return .concatenate(environment.threadListClient
                                .threadListClient()
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(PickThreadAction.response)
                                .cancellable(id: ThreadCancelId()))
    case .response(.success(let response)):
        return .none
    case .response(.failure(_)):
        return .none
    case .binding(_):
        return .none
    }
}.binding()
