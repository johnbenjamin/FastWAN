//
//  OrderDetailView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI

struct OrderDetailView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                c_F1F2FF.opacity(0.5).ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        Image("success")
                        VStack(alignment: .leading, spacing: 5) {
                            Text("支付成功!")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                            Text("感谢您的购买")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .regular))
                        }
                        Spacer()
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 52)
                    .background(mainColor)
                    
                    Image("order").overlay{
                        VStack {
                            Spacer(minLength: 22)
                            Text("¥ ").foregroundColor(c_030364).font(.system(size: 18, weight: .bold))
                            + Text("99999").foregroundColor(c_030364).font(.system(size: 40, weight: .medium))
                            
                            Line().stroke(style: StrokeStyle(lineWidth: 0.5, dash: [2]))
                                .frame(height: 0.5).background(c_F4F5F7)
                                .padding([.leading, .trailing], 13)
                            Spacer(minLength: 22)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 7, content: {
                                    Text("订单编号")
                                    Text("下单时间")
                                    Text("支付方式")
                                }).foregroundColor(c_7F8398)
                                    .font(.system(size: 12, weight: .medium))
                                
                                VStack(alignment: .leading, spacing: 7) {
                                    Text("9475658613469")
                                    Text("2022-08-09 13:55:31")
                                    Text("支付宝支付")
                                }.foregroundColor(c_030364)
                                    .font(.system(size: 12, weight: .medium))
                                Spacer()
                            }.padding(.leading, 25)
                            Spacer(minLength: 24)
                        }
                    }
                    .padding(.top, -21)
                    Spacer()                    
                }
            }.navigationTitle("订单详情")
                .navigationBarTitleDisplayMode(.inline)
                .background(NavigationConfigurator { navigationConfigurator in
                    navigationConfigurator.navigationBar.barTintColor = .blue
                    navigationConfigurator.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white, .font : UIFont.systemFont(ofSize: 18, weight: .bold)]
                            })
                .font(.system(size: 18, weight: .bold))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            
                        } label: {
                            Image("back.white")
                        }
                    }
                }
        }
    }
}

struct OrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        OrderDetailView()
    }
}
