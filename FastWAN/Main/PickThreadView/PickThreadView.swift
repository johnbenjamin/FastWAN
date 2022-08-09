//
//  PickThreadView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/24.
//

import SwiftUI
import ComposableArchitecture

struct PickThreadView: View {
    var store: Store<PickThreadState, PickThreadAction>
    var done: ((ThreadInfoModel?) -> Void)?
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ThreadTitle()
                List(viewStore.threadList, id:\.self) { thread in
                    ThreadRow(thread: thread, viewStore: viewStore)
                }
                .listStyle(PlainListStyle())
                ThreadButton(viewStore: viewStore) {
                    done?(viewStore.selectModel)
                }
            }
            .onAppear {
                viewStore.send(.getList)
            }
        }
    }
}

struct ThreadTitle: View {
    var body: some View {
        HStack {
            Text("选择线路")
                .foregroundColor(c_030364)
                .font(.system(size: 20, weight: .bold))
            Spacer()
            
            Button {
                
            } label: {
                Image("x.fill")
            }
        }
        .padding(.top, 21)
        .padding([.leading, .trailing], 36)
    }
}

struct ThreadRow: View {
    var thread: ThreadInfoModel
    var viewStore: ViewStore<PickThreadState, PickThreadAction>
    var body: some View {
        HStack {
            Text("\(thread.type ?? "--") | \(thread.tag ?? "--")")
                .foregroundColor(c_030364)
                .font(.system(size: 16, weight: .regular))
                .padding([.leading, .top, .bottom], 14)
            Spacer()
            Image(viewStore.state.selectModel == thread ? "greenhook.big" : "")
                .frame(width: 24, height: 24)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewStore.state.selectModel == thread ? .clear : c_E3E6EE)
                })
                .padding(.trailing, 12)
        }
        .background(c_F4F5F7)
        .cornerRadius(12)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .frame(height: 50)
        .padding([.leading, .trailing], -13)
        .onTapGesture {
            viewStore.send(PickThreadAction.select(thread))
        }
        .padding([.leading, .trailing], 36)
    }
}

struct ThreadButton: View {
    var viewStore: ViewStore<PickThreadState, PickThreadAction>
    var done: (() -> Void)?
    var body: some View {
        Button {
            done?()
        } label: {
            Spacer()
            Text("确认")
                .foregroundColor(viewStore.state.hasSelectedModel ? .white : mainColor)
                .font(.system(size: 16, weight: .regular))
            Spacer()
        }
        .frame(height: 60)
        .background(viewStore.state.hasSelectedModel ? mainColor : mainColor.opacity(0.2))
        .cornerRadius(12)
        .shadow(color: viewStore.state.hasSelectedModel ? mainColor.opacity(0.2) : mainColor.opacity(0), radius: 12, x: 0, y: 8)
        .disabled(!viewStore.state.hasSelectedModel)
        .padding(.top, 33)
        .padding([.leading, .trailing], 36)
    }
}
