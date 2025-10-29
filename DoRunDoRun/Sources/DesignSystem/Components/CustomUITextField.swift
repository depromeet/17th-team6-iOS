//
//  CustomUITextField.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

import SwiftUI

struct CustomUITextField: UIViewRepresentable {
    @Binding var text: String
    var style: TypographyStyle
    var textColor: UIColor
    var placeholder: String
    var placeholderColor: UIColor
    var keyboardType: UIKeyboardType = .default
    var alignment: NSTextAlignment = .left
    var maxLength: Int? = nil
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = keyboardType
        textField.textAlignment = alignment
        textField.backgroundColor = .clear
        
        let spec = style.spec
        let font = UIFont(name: spec.weight.rawValue, size: spec.size) ?? UIFont.systemFont(ofSize: spec.size)
        
        textField.font = font
        textField.textColor = textColor
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.minimumLineHeight = spec.lineHeight
        paragraph.maximumLineHeight = spec.lineHeight
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph,
            .kern: spec.letterSpacing,
            .foregroundColor: placeholderColor
        ]
        
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        if uiView.text != text { uiView.text = text }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomUITextField
        
        init(parent: CustomUITextField) {
            self.parent = parent
        }

        @objc func textChanged(_ sender: UITextField) {
            parent.text = sender.text ?? ""
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            var filtered = newText
            if parent.keyboardType == .numberPad {
                filtered = newText.filter { $0.isNumber }
            }
            
            if let maxLength = parent.maxLength, filtered.count > maxLength {
                textField.text = String(filtered.prefix(maxLength))
                parent.text = textField.text ?? ""
                return false
            }
            
            parent.text = filtered
            return true
        }
    }
}
