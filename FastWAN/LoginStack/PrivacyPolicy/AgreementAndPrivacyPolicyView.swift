//
//  AgreementAndPrivacyPolicyView.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/16.
//

import SwiftUI

let policy = "我们深知个人信息的重要性，我们将按照法律法规的要求，采取必要的保护措施确保您个人信息的安全。为更好了解我们如何收集、存储、使用您的个人信息以及您在使用我们产品中的权益，请您务必仔细阅读[《用户协议》](www.baidu.com)、[《隐私政策》](www.baidu.com)及[《儿童隐私政策》](www.baidu.com)，其中包括:\n1我们如何收集和使用您的个人信息，特别是您的个人敏感信息;\n2.我们如何共享、转让、公开、披露您的个人信息;\n3.您对于个人信息享有的权利，包括删除、更改、注销等。请您阅读上述协议，并确保您在全面了解、知晓协议内容的情况下点击同意。"

struct AgreementAndPrivacyPolicyView: View {

    var body: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    Text("用户协议及私隐条款")
                        .foregroundColor(c_030364)
                    .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                Spacer(minLength: 45)
                
                Text(policy)
                    .lineLimit(.max)
                    .lineSpacing(12)
                    .foregroundColor(c_7F8398)
                    .font(.system(size: 16, weight: .medium))
                Spacer(minLength: 13)
                
                HStack(spacing: 11) {
                    Button {
//                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Spacer()
                        Text("不同意")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(c_7F8398)
                            .padding([.top, .bottom], 14)
                        Spacer()
                    }.background(c_F4F5F7)
                        .frame(height: 50)
                        .cornerRadius(12)

                    Button {
//                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Spacer()
                        Text("同意")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding([.top, .bottom], 14)
                        Spacer()
                    }.background(mainColor)
                        .frame(height: 50)
                        .cornerRadius(12)

                }
                
            }.padding(EdgeInsets(top: 21, leading: 35, bottom: 35, trailing: 12))
        }

    }
}

struct AgreementAndPrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        AgreementAndPrivacyPolicyView()
    }
}
