//
//  NavigationConfigurator.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/19.
//

import SwiftUI

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            guard let navigationController = controller.navigationController else { return }
            self.configure(navigationController)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
