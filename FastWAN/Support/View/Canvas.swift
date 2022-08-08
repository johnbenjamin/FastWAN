//
//  PencilKitRepresentable.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/23.
//

import SwiftUI
import PencilKit

struct Canvas : UIViewRepresentable {
    let canvasView = PKCanvasView()
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pencil, color: UIColor.init(hex: "#030364"), width: 5)
      #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
      #endif
      return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) { }
}

