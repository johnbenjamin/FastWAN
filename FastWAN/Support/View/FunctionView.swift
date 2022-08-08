//
//  SecureTextField.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct SecureTextField: View {
    @State private var isSecureTextField: Bool = true
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        HStack {
            if isSecureTextField {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }.overlay(alignment: .trailing) {
            Image(isSecureTextField ? "eye.slash" : "eye").onTapGesture {
                isSecureTextField.toggle()
            }
        }

    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct RootWindow {
    let window = UIApplication
        .shared
        .connectedScenes
        .flatMap {( $0 as? UIWindowScene)?.windows ?? []}
        .first{ $0.isKeyWindow }
}


// This is taken from the Release Notes, with a typo correction, marked below
struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    typealias Index = Base.Index
    typealias Element = (index: Index, element: Base.Element)

    let base: Base

    var startIndex: Index { base.startIndex }

   // corrected typo: base.endIndex, instead of base.startIndex
    var endIndex: Index { base.endIndex }

    func index(after i: Index) -> Index {
        base.index(after: i)
    }

    func index(before i: Index) -> Index {
        base.index(before: i)
    }

    func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
