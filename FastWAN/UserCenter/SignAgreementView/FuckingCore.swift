//
//  FuckingCoew.swift
//  FastWAN
//
//  Created by Xeon on 2022/8/9.
//

import ComposableArchitecture

struct coreState: Equatable {
    @BindableState var stateStr: String
}

enum CoreAction: Equatable {
    case cation
}

struct CoreEnvironment {
    var uploadSignClient: UploadSignClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let reducer = Reducer<coreState, CoreAction, CoreEnvironment> { state, action, environment in
    switch action {
    case .cation:
        return .none
    }
}
