//
//  Image+Graphic.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/2/25.
//

import SwiftUI

extension Image {
    init(_ graphic: GraphicStyle) {
        self.init(graphic.rawValue)
    }
}
