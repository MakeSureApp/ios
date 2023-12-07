//
//  BackspaceDetectingTextField.swift
//  MakeSure
//
//  Created by Macbook Pro on 07.12.2023.
//

import Foundation
import SwiftUI
import UIKit

class BackspaceDetectingTextField: UITextField {

    var onBackspace: (() -> Void)?

    override func deleteBackward() {
        if self.text?.isEmpty == true {
            onBackspace?()
        }
        super.deleteBackward()
    }
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var textSize: CGFloat = 24
    var onBackspace: () -> Void

    func makeUIView(context: Context) -> BackspaceDetectingTextField {
        let textField = BackspaceDetectingTextField()
        textField.onBackspace = onBackspace
        textField.delegate = context.coordinator
        
        textField.font = UIFont(name: "Rubik-Regular", size: textSize)
        textField.textColor = UIColor(CustomColors.darkBlue)
        textField.tintColor = UIColor(CustomColors.darkBlue)
        textField.keyboardType = .numberPad
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.clear
        
        return textField
    }
    
    func makeUIView(context: Context) -> UIView {
        let textField = BackspaceDetectingTextField()

        // Apply direct styling for debugging
        textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)

        let paddingView = UIView()
        paddingView.backgroundColor = UIColor.green.withAlphaComponent(0.3) // Debug color

        paddingView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: paddingView.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -8),
            textField.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor, constant: -8)
        ])

        return paddingView
    }

    func updateUIView(_ uiView: BackspaceDetectingTextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>

        init(_ text: Binding<String>) {
            self.text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            if let textField = textField as? BackspaceDetectingTextField {
                self.text.wrappedValue = textField.text ?? ""
            }
        }
    }
}
