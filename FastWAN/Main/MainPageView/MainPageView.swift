//
//  MainPageView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/23.
//

import SwiftUI
import QGrid

struct MainPageView: View {
    @State private var isPresentedThreads: Bool = false
    @State private var isOn: Bool = true
    @State private var progress: Float = 0.25
    @State private var threadPropertys = [ThreadProperty(id: 0, title: "上传速度", descpt: "3521", Unit: "KB/S", imageName: "upload"),
                           ThreadProperty(id: 1, title: "下载速度", descpt: "3522", Unit: "KB/S", imageName: "download"),
                           ThreadProperty(id: 2, title: "过期时间", descpt: "22-12-28", Unit: nil, imageName: "expired"),
                           ThreadProperty(id: 3, title: "套餐余量(GB)", descpt: "2398.6", Unit: "KB/S", imageName: "remaining")
    ]

    var body: some View {
        NavigationView {
            VStack {
                ProgressView(isON: $isOn, progress: progress)

                HStack {
                    Spacer()
                    Image(isOn ? "Switch.white" : "Switch.Gray")
                        .padding(.all, 11)
                        .background(isOn ? mainColor : .white)
                        .cornerRadius(16)
                        .onTapGesture {
                            isOn = !isOn
                            progress += 0.25
                        }
                }

                HStack {
                    Text("当前线路 I A1 I 香港01")
                        .foregroundColor(c_7F8398)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.leading, 17)
                        .padding([.top, .bottom], 15)
                    Spacer()
                    
                    Button {
                        isPresentedThreads = !isPresentedThreads
                    } label: {
                        Image("Arrow.right2")
                    }
                    .adaptiveSheet(isPresented: $isPresentedThreads, detents: [.medium()], smallestUndimmedDetentIdentifier: .large) {
                        PickThreadView(store: .init(initialState: .init(), reducer: threadReducer, environment: .init(threadListClient: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler())))
                    }
                    .padding(.trailing, 11)
                }
                    .background(.white)
                    .cornerRadius(12)

                QGrid(threadPropertys, columns: 2, vSpacing: 8, hSpacing: 8) { property in
                    ThreadPropertyCell(threadProperty: property)
                        .background(.white)
                        .cornerRadius(12)
                        .frame(height: 77)
                }.padding([.leading, .trailing], -8)
                    .frame(height: 185)

                HStack {
                    Text("套餐充值")
                        .foregroundColor(c_7F8398)
                        .font(.system(size: 14, weight: .regular))
                        .padding(.leading, 17)
                        .padding([.top, .bottom], 15)
                    Spacer()
                    
                    NavigationLink(destination: MakeOrderView(store: .init(initialState: .init(), reducer: makeOrderReducer, environment: .init(productsClient: .live, mainQueue: DispatchQueue.main.eraseToAnyScheduler())))) {
                        Image("Arrow.right2")
                    }.padding(.trailing, 11)
                }
                    .background(.white)
                    .cornerRadius(12)
            }
            .padding([.leading, .trailing], 16)
            .background{
                Image("Main.Backgroud")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("加速器")
                        .foregroundColor(c_030364)
                        .font(.system(size: 18, weight: .bold))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: UserCenterView()) {
                        Image("Ali").frame(width: 35, height: 35)
                    }
                }
            }
        }
    }
}

struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainPageView()
        }
    }
}

struct ProgressView: View {
    @Binding var isON: Bool
    var progress: Float = 0.25

    var body: some View {
        ZStack(content: {
            GeometryReader { proxy in
                let width = proxy.size.width * 0.6331
                Image("Progress.Backgroud")
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.width, alignment: .center)
                
                Circle()
                    .trim(from: 0.0, to:  CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .rotation(Angle(degrees: 180))
                    .foregroundStyle(.linearGradient(
                        Gradient(colors: [mainColor, .purple]),
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 0.6)
                    ))
                    .frame(width: width, height: width, alignment: .center)
                    .offset(x: (proxy.size.width - width) / 2, y: (proxy.size.width - width) / 2)
                
                Path { path in
                    path.move(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.width / 2))

                    let linAngle: CGFloat = 360.0 * CGFloat(progress)
                    let center = proxy.size.width / 2
                    let X = width/2 * cos(linAngle * .pi / 180);
                    let Y = width/2 * sin(linAngle * .pi / 180);
                    path.addLine(to: CGPoint(x: center - X, y: center - Y))
                }.stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .fill(mainColor)
                
                Circle()
                    .frame(width: width * 0.6, height: width * 0.6)
                    .offset(x: width / 2, y: width / 2)
                    .foregroundStyle(.white)
                    .overlay(content: {
                        if isON {
                            VStack {
                                Spacer()
                                Text("Kbps")
                                    .foregroundColor(c_7F8398.opacity(0.55))
                                    .font(.system(size: 13, weight: .regular))
                                
                                Text("264.85")
                                    .foregroundColor(mainColor)
                                    .font(.system(size: 32, weight: .regular))
                                
                                Spacer()
                                Text("12:35:45")
                                    .foregroundColor(c_999999)
                                    .font(.system(size: 12, weight: .regular))
                                    .padding(.bottom)
                                }
                            .offset(x: width/2, y: width / 2)
                        } else {
                            Image("rocket")
                                .frame(width: width * 0.6, height: width * 0.6, alignment: .center)
                                .cornerRadius(width * 0.6 / 2)
                                .offset(x: width/2, y: width / 2)
                        }
                    })
            }
        })
            .padding(.top, 42)
    }
}

struct ThreadPropertyCell: View {
    var threadProperty: ThreadProperty
    
    var body: some View {
        HStack(spacing: 10) {
            threadProperty.icon
                .padding(.leading, 15)
                .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 5) {
                Text(threadProperty.title)
                    .foregroundColor(c_7F8398)
                    .font(.system(size: 12, weight: .regular))
                Text(threadProperty.descpt)
                    .foregroundColor(c_030364)
                    .font(.system(size: 20, weight: .regular))
                + Text(threadProperty.Unit ?? "")
                    .foregroundColor(c_030364)
                    .font(.system(size: 10, weight: .regular))
            }.padding([.top, .bottom], 16)
            Spacer()
        }
    }
    
}
