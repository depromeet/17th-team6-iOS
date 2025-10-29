//
//  String+PhoneFormatting.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/23/25.
//

extension String {
    func formattedPhoneNumber() -> String {
        let digits = self.filter { $0.isNumber }
        let limited = String(digits.prefix(11))
        
        if limited.count <= 3 {
            return limited
        } else if limited.count <= 7 {
            let start = limited.prefix(3)
            let middle = limited.suffix(limited.count - 3)
            return "\(start)-\(middle)"
        } else {
            let start = limited.prefix(3)
            let middle = limited.dropFirst(3).prefix(4)
            let end = limited.suffix(limited.count - 7)
            return "\(start)-\(middle)-\(end)"
        }
    }
}
