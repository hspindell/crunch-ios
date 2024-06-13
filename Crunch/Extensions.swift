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
}

extension View {
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

