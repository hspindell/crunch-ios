//
//  Extensions.swift
//  Crunch
//
//  Created by Henry Spindell on 5/16/24.
//

import Foundation
import SwiftUI
import Supabase

extension PostgrestResponse {
    func debug() -> Self {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            print(json)
        } else if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
            print(json)
        } else {
            print("Unable to parse response")
        }
        return self
    }
}

extension Optional {
    var isNil: Bool {
        self == nil
    }
    
    var hasValue: Bool {
        self != nil
    }
}

extension String {
    var url: URL? {
        return URL(string: self)
    }
    
    var isPresent: Bool {
        !isEmpty
    }
    
    var presence: String? {
        if isEmpty { return nil }
        return self
    }
}

extension Array {
    var presence: Array? {
        if isEmpty { return nil }
        return self
    }
}

extension View {
    func labeled(_ label: String, labelSpacing: CGFloat = 6, font: Font = .system(size: 14), color: Color = .black) -> some View {
        VStack(alignment: .leading, spacing: labelSpacing) {
            if label.isPresent {
                Text(label)
                    .font(font)
                    .foregroundColor(color)
                    .fixedSize(horizontal: false, vertical: true)
            }
            self
        }
    }
    
    func solidShadow(size: CGSize, cornerRadius: CGFloat, offset: (CGFloat, CGFloat) = (3, 5)) -> some View {
        ZStack {
            Color.black
                .cornerRadius(cornerRadius)
                .frame(width: size.width, height: size.height)
                .offset(x: offset.0, y: offset.1)
            self
        }
    }
    
    func solidShadow(cornerRadius: CGFloat, offset: (CGFloat, CGFloat) = (3, 5)) -> some View {
        ZStack {
            Color.black
                .cornerRadius(cornerRadius)
                .offset(x: offset.0, y: offset.1)
            self
        }
    }
    
    func messageBox() -> some View {
        HStack {
            self
            Spacer()
        }
        .padding(10)
        .background(Color.backgroundCream.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
//    func solidShadow(cornerRadius: CGFloat, offset: (CGFloat, CGFloat) = (3, 5)) -> some View {
//        GeometryReader { geo in
//            ZStack {
//                Color.black
//                    .cornerRadius(cornerRadius)
//                    .frame(width: geo.size.width, height: geo.size.height)
//                    .offset(x: offset.0, y: offset.1)
//                self
//            }
//        }
//    }
    
    func padding(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> some View {
        self.padding(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }
    
    func padding(h: CGFloat = 0, v: CGFloat = 0) -> some View {
        self.padding(EdgeInsets(top: v, leading: h, bottom: v, trailing: h))
    }
}

extension Color {
    static let backgroundCream = Color(red: 243/255, green: 242/255, blue: 233/255)
    static let buttonBackground = Color(red: 28/255, green: 169/255, blue: 172/255)
    static let buttonBackgroundPressed = Color(red: 30/255, green: 205/255, blue: 209/255)
    
//    static let crunchGreen = Color(red: 4/255, green: 195/255, blue: 39/255)
    
    static let lightText = Color(red: 85/255, green: 85/255, blue: 82/255)
    
    static let crunchYellow = Color(red: 239/255, green: 227/255, blue: 82/255)
    static let crunchCyan = Color(red: 109/255, green: 192/255, blue: 192/255)
    static let crunchPurple = Color(red: 183/255, green: 131/255, blue: 223/255)
    static let crunchGreen = Color(red: 146/255, green: 239/255, blue: 107/255)
    static let crunchOrange = Color(red: 1, green: 155/255, blue: 0)
}

extension UIColor {
    var r: CGFloat { CIColor(color: self).red }
    var g: CGFloat { CIColor(color: self).green }
    var b: CGFloat { CIColor(color: self).blue }
    var a: CGFloat { CIColor(color: self).alpha }
}

extension Color {
    init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, opacity: a)
    }

    init(hex: Int) {
        self.init(
            r: (hex >> 16) & 0xFF,
            g: (hex >> 8) & 0xFF,
            b: hex & 0xFF
        )
    }

    init?(hex: String) {
        var str = hex
        if str.hasPrefix("#") {
            str.removeFirst()
        }
        guard str.count == 6, let color = Int(str, radix: 16) else { return nil }
        self.init(hex: color)
    }

    /// Produces a lighter version of this color
    /// Tint of 0 results in the same color, tint of 100 results in pure white
    /// Use `shade` to get a darker color.
    func tint(_ tint: CGFloat) -> Color {
        let c = UIColor(self)
        let d = 100.0 / tint
        let tintRed = c.r + (1 - c.r) / d
        let tintGreen = c.g + (1 - c.g) / d
        let tintBlue = c.b + (1 - c.b) / d

        return Color(red: tintRed, green: tintGreen, blue: tintBlue, opacity: c.a)
    }

    /// Produces a darker version of this color
    /// Shade of 0 results in the same color, shade of 100 results in pure black
    /// Use `tint` to get a darker color.
    func shade(_ shade: CGFloat) -> Color {
        let c = UIColor(self)
        let d = 100.0 / shade
        let shadeRed = c.r - c.r / d
        let shadeGreen = c.g - c.g / d
        let shadeBlue = c.b - c.b / d

        return Color(red: shadeRed, green: shadeGreen, blue: shadeBlue, opacity: c.a)
    }
}
