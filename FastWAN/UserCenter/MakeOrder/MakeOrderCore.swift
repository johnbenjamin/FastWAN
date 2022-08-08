//
//  MakeOrderCore.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/31.
//

import Foundation
import ComposableArchitecture

enum Payment {
    case wechat
    case aliPay

    var icon: String {
        switch self {
        case .wechat: return "Wechat"
        case .aliPay: return "Ali"
        }
    }

    var paymentName: String {
        switch self {
        case .wechat:
            return "微信支付"
        case .aliPay:
            return "支付宝"
        }
    }
}
struct MakeOrderState: Equatable {
    var payment: Payment = .wechat
    var pickProduct: ProductInfo?
    var selectionKeeper: Int = 0
    @BindableState var productList: [ProductInfo] = []
    @BindableState var isShowMore: Bool = false

    var hasMore: Bool { productList.count > 3 }
    var listingCount: Int { hasMore ? (isShowMore ? productList.count : 3) : productList.count }
}

enum MakeOrderAction: Equatable, BindableAction {
    case moreList
    case getProducts
    case productsResponse(Result<ProductModel, ProviderError>)
    case pickProduct(ProductInfo, Int)
    case pickPayment(Payment)
    case pay
    case binding(BindingAction<MakeOrderState>)
}

struct MakeOrderEnvironment {
    var productsClient: ProductListClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let makeOrderReducer = Reducer<MakeOrderState, MakeOrderAction, MakeOrderEnvironment> { state, action, environment in
    struct MakeOrderCancelId: Hashable {}

    switch action {
    case .getProducts:
        return .concatenate(environment.productsClient
                                .productListClient(10, 0)
                                .receive(on: environment.mainQueue)
                                .catchToEffect()
                                .map(MakeOrderAction.productsResponse)
                                .cancellable(id: MakeOrderCancelId()))

    case .productsResponse(.success(let response)):
        state.productList = response.info ?? []
        return .none

    case .productsResponse(.failure(let error)):
        return .none

    case .pickProduct(let product, let index):
        state.pickProduct = product
        state.selectionKeeper = index
        return.none

    case .pickPayment(let payment):
        state.payment = payment
        return .none

    case .pay:
        return .none

    case .binding:
        return .none

    case .moreList:
        state.isShowMore = !state.isShowMore
        return .none
    }
}.binding()
