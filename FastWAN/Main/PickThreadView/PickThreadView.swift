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

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text("选择线路")
                        .foregroundColor(c_030364)
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image("x.fill")
                    }
                }.padding(.top, 21)

                List(viewStore.binding(\.$threadList), id:\.self) { thread in
                    ThreadRow(thread: thread)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .frame(height: 50)
                        .padding([.leading, .trailing], -13)
                        .onTapGesture {
                            thread.isSet.wrappedValue = true
                        }
                }
                .listStyle(PlainListStyle())
                
                Button {
                    
                } label: {
                    Spacer()
                    Text("确认")
                        .foregroundColor(viewStore.isUserInputed ? .white : mainColor)
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                }
                .frame(height: 60)
                .background(viewStore.isUserInputed ? mainColor : mainColor.opacity(0.2))
                .cornerRadius(12)
                .shadow(color:viewStore.isUserInputed ? mainColor.opacity(0.2) :     mainColor.opacity(0), radius: 12, x: 0, y: 8)
                .disabled(!viewStore.isUserInputed)
                .padding(.top, 33)
            }.padding([.leading, .trailing], 36)

        }
    }
}

//struct PickThreadView_Previews: PreviewProvider {
//    static var previews: some View {
//        PickThreadView()
//    }
//}

struct ThreadRow: View {
    @Binding var thread: ThreadInfoModel
    
    var body: some View {
        HStack {
            Text("\(thread.type) | \(thread.tag)")
                .foregroundColor(c_030364)
                .font(.system(size: 16, weight: .regular))
                .padding([.leading, .top, .bottom], 14)
            Spacer()
            
            Image(thread.isSet ? "greenhook.big" : "")
                .frame(width: 24, height: 24)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(c_E3E6EE)
                })
                .padding(.trailing, 12)
        }.background(c_F4F5F7)
            .cornerRadius(12)
    }
    
}
