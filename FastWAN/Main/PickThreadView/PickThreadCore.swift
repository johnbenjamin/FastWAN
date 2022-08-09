//
//  PickThreadCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/7.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct PickThreadState: Equatable {
    @BindableState var threadList: [ThreadInfoModel] = []
    var selectModel: ThreadInfoModel?
    var hasSelectedModel: Bool {
        selectModel != nil
    }
}

enum PickThreadAction: BindableAction {
    case getList
    case response(Result<ThreadModel, ProviderError>)
    case binding(BindingAction<PickThreadState>)
    case select(ThreadInfoModel)
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
        state.threadList = response.info
        return .none
    case .response(.failure(_)):
        return .none
    case .binding(_):
        return .none
    case .select(let model):
        state.selectModel = model
        return .none
    }
}.binding()
