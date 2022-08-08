//
//  MakeOrderView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/20.
//

import SwiftUI
import ComposableArchitecture

struct MakeOrderView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    var store: Store<MakeOrderState, MakeOrderAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("流量套餐来啦\n买一次送一次，限时特惠")
                                .foregroundColor(c_820000)
                                .font(.system(size: 24, weight: .bold))
                            Label("按此办理，补充短时流量", image: "gift")
                                .foregroundColor(c_820000)
                                .font(.system(size: 12, weight: .regular))
                        }
                        Spacer()
                    }.background{
                        Image("buy.backgourd")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea()
                    }

                        ZStack {
                            VisualEffectView(effect: UIBlurEffect(style: .light))
                                .edgesIgnoringSafeArea(.all)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white, lineWidth: 1)
                                })

                            ScrollView(content: {
                                VStack {
                                    ForEach(0..<viewStore.listingCount, id:\.self) { i in
                                        PackageRow(packageMark: viewStore.productList[i])
                                            .frame(height: 91)
                                            .listRowBackground(Color.clear)
                                            .opacity(i == viewStore.selectionKeeper ? 0.4 : 1)
                                            .padding(.leading, 8)
                                            .onTapGesture {
                                                viewStore.send(MakeOrderAction.pickProduct(viewStore.productList[i], i))
                                            }
                                    }
                                }.listStyle(PlainListStyle())
                                    .padding([.leading, .trailing], 29)
                                    .padding(.top, 35)

                                if !viewStore.isShowMore {
                                    HStack(alignment: .center) {
                                        Button {
                                            viewStore.send(MakeOrderAction.moreList)
                                        } label: {
                                            Image("list.more")
                                        }
                                    }
                                }

                                VStack(alignment: .leading, content: {
                                    Text("支付方式")
                                        .foregroundColor(c_030364)
                                    .font(.system(size: 14, weight: .medium))
                                    Divider()
                                    
                                    HStack {
                                        Label(Payment.wechat.paymentName, image: Payment.wechat.icon)
                                            .foregroundColor(c_7F8398)
                                            .font(.system(size: 14, weight: .regular))
                                        Spacer()
                                        if viewStore.payment == .wechat {
                                            Image("greenhook.big")
                                        }
                                    }
                                    .padding(EdgeInsets(top: 14, leading: 21, bottom: 6, trailing: 18))
                                    .onTapGesture {
                                        viewStore.send(MakeOrderAction.pickPayment(.wechat))
                                    }

                                    HStack {
                                        Label(Payment.aliPay.paymentName, image: Payment.aliPay.icon)
                                            .foregroundColor(c_7F8398)
                                            .font(.system(size: 14, weight: .regular))
                                        Spacer()
                                        if viewStore.payment == .aliPay {
                                            Image("greenhook.big")
                                        }
                                    }
                                    .padding(EdgeInsets(top: 14, leading: 21, bottom: 14, trailing: 18))
                                    .onTapGesture {
                                        viewStore.send(MakeOrderAction.pickPayment(.aliPay))
                                    }
                                    
                                    HStack {
                                        Button {
                                            viewStore.send(MakeOrderAction.pay)
                                        } label: {
                                            Spacer()
                                            Text("支付")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .regular))
                                            Spacer()
                                        }
                                        .frame(height: 60)
                                        .background(mainColor)
                                        .cornerRadius(12)
                                    .shadow(color:mainColor.opacity(0.2), radius: 12, x: 0, y: 8)
                                    }.padding(13)
                                    
                                })
                                    .padding(.leading, 16)
                            Spacer()
                            })
                        }
                        .cornerRadius(16)
                        .padding(.top, 36)
                        Spacer(minLength: 10)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image("back.red")
                        }

                    }
                }
            }
            .onAppear(perform: {
                viewStore.send(MakeOrderAction.getProducts)
            })
            .navigationBarHidden(true)
        }
    }
}

//struct MakeOrderView_Previews: PreviewProvider {
//    static var previews: some View {
//        MakeOrderView()
//    }
//}

struct PackageRow: View {
    var packageMark: ProductInfo
    var isDiscount: Bool { packageMark.state != 1 }
    
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(packageMark.flow_size ?? 0)")
                        .font(.system(size: 18, weight: .bold))
                    Text(packageMark.product_name ?? "")
                        .font(.system(size: 14, weight: .regular))
                }
                .padding([.top, .bottom], 21)
                .padding(.leading, 24)
                Spacer()
                
                HStack {
                    Text("¥ ")
                        .font(.system(size: 22, weight: .regular))
                    + Text(packageMark.price.decimalString(2))
                        .font(.system(size: 50, weight: .regular))
                }
                .padding(.trailing, 24)

            }.foregroundColor(isDiscount ? c_820000 : c_030364)
            
            if isDiscount {
                HStack {
                    VStack(content: {
                        Text(packageMark.remarks ?? "")
                            .frame(width: 66, height: 23, alignment: .center)
                            .foregroundColor(c_820000)
                        .font(.system(size: 12, weight: .bold))
                        .background(c_FFBF78)
                        .cornerRadius(12)
                        .padding(.top, -5)
                        Spacer()
                    })
                    Spacer()
                }
            }
        }
        .background(isDiscount ? .clear : c_F4F5F7)
        .cornerRadius(15)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 15)
                            .stroke(isDiscount ? c_FDCB7F : .clear, lineWidth: isDiscount ? 1 : 0)
                            .shadow(color: isDiscount ? c_FDCB7F : .clear, radius: 15, x: 0, y: 10)
        })
    }
}
