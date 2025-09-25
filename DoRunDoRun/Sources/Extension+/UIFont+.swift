//
//  UIFont+.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/13/25.
//

import UIKit

extension UIFont {
    static func pretendard(size: CGFloat, weight: Weight) -> UIFont {
        let fontName: String = "Pretendard"
        
        let font: UIFont? = switch weight {
            case .black:
                UIFont(name: "\(fontName)-Black", size: size)
            case .heavy:
                UIFont(name: "\(fontName)-ExtraBold", size: size)
            case .bold:
                UIFont(name: "\(fontName)-Bold", size: size)
            case .semibold:
                UIFont(name: "\(fontName)-SemiBold", size: size)
            case .medium:
                UIFont(name: "\(fontName)-Medium", size: size)
            case .regular:
                UIFont(name: "\(fontName)-Regular", size: size)
            case .light:
                UIFont(name: "\(fontName)-Light", size: size)
            case .ultraLight:
                UIFont(name: "\(fontName)-ExtraLight", size: size)
            case .thin:
                UIFont(name: "\(fontName)-Thin", size: size)
            default:
                nil
        }
        
        return font ?? UIFont.systemFont(ofSize: size, weight: weight)
    }
}
