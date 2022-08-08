//
//  Provider+Product.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/31.
//

import Foundation
import Combine

extension Provider {
    func productList(limit: Int, page: Int) -> AnyPublisher<ProductModel, ProviderError> {
        let request = Router.productList(limit: limit, page: page).request
        return Provider.shared.requestAuthorizedPublisher(request)
    }

    func threadList() -> AnyPublisher<ThreadProperty, ProviderError>  {
        let request = Router.getMyConfig.request
        return Provider.shared.requestAuthorizedPublisher(request)
    }
}
