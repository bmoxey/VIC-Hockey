//
//  ConfirmationAlertView.swift
//  VIC Hockey
//
//  Created by Brett Moxey on 28/10/2023.
//

import SwiftUI

struct ConfirmationAlertView: UIViewControllerRepresentable {
    let title: String
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.onConfirm()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            self.onCancel()
        }))
        return alertController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
}
