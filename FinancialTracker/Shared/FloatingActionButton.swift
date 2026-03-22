//
//  FloatingActionButton.swift
//  FinancialTracker
//
//  Created by David Callender on 3/14/26.
//

//
//  FloatingActionButton.swift
//  CatholicConnect
//
//  Created by David Callender on 2/6/26.
//

import SwiftUI
import UIKit

// UIKit-based floating action button with gradient background.
struct FloatingActionButtonView: UIViewRepresentable {
    let onTap: () -> Void

    private static let gradientLayerName = "fabGradient"

    // Build the UIKit view hierarchy for the FAB.
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let button = UIButton(type: .system)
        let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTap), for: .touchUpInside)

        container.addSubview(button)

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = Self.gradientLayerName
        gradientLayer.colors = [
            UIColor(Color(hex: "2B7FFF")).cgColor,
            UIColor(Color(hex: "00D3F3")).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        gradientLayer.cornerRadius = 28
        button.layer.insertSublayer(gradientLayer, at: 0)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    // Keep gradient sizing in sync with layout changes.
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layoutIfNeeded()
        guard let button = uiView.subviews.compactMap({ $0 as? UIButton }).first else {
            return
        }
        button.layer.sublayers?.forEach { layer in
            guard layer.name == Self.gradientLayerName else { return }
            layer.frame = button.bounds
        }
    }

    // Provide coordinator for button tap handling.
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    // Button target handler.
    final class Coordinator {
        private let onTap: () -> Void

        init(onTap: @escaping () -> Void) {
            self.onTap = onTap
        }

        // Relay UIButton tap to SwiftUI.
        @objc func didTap() {
            onTap()
        }
    }
}
