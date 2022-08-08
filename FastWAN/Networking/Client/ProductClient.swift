//
//  ProductClient.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/31.
//

import Foundation
import ComposableArchitecture

struct ProductListClient {
    var productListClient: (_ limit: Int, _ page: Int) -> Effect<ProductModel, ProviderError>
}

struct ThreadListClient {
    var threadListClient: () -> Effect<ThreadProperty, ProviderError>
}

extension ProductListClient {
    static let live = ProductListClient { limit, page in
        Provider.shared.productList(limit: limit, page: page).eraseToEffect()
    }
}

extension ThreadListClient {
    static let live = ThreadListClient {
        Provider.shared.threadList().eraseToEffect()
    }
}
