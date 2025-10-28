//
//  Image+Icon.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/28/25.
//

import SwiftUI

extension Image {
    init(_ icon: IconStyle, fill: IconFill = .normal, size: IconSize = .medium) {
        let name = "\(icon.rawValue)\(fill.rawValue)\(size.rawValue)"
        self.init(name)
    }
}
