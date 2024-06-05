//
//  ExtendedUIStyle.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//

import SwiftUI

/// Screen calculator for width, height and orientation
struct ScreenCalculator: ViewModifier {
    @Binding var screenSize: CGSize
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear{
                        screenSize = proxy.size
                    }
            }
        )
    }
}

/// View extension bound data
extension View {
    /// screenSize property
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(ScreenCalculator(screenSize: size))
    }
}

/// Text: styles for healine, subhead, body
extension Text {
    /// Subheads, adapts to light/dark mode
    func sectionHeader() -> some View {
        font(Font.custom("Arial",size:13)).fontWeight(.semibold).foregroundColor(.secondary)
    }
    /// Body Copy, adapts to light/dark mode
    func bodyCopy() -> some View {
        font(Font.custom("Arial",size:12)).fontWeight(.regular).foregroundColor(Color(UIColor.systemGray))
    }
    /// Button labels
    func mainBtnLabel() -> some View {
        font(Font.custom("Arial", size: 12)).fontWeight(.semibold).foregroundColor(.black)
    }
}

/// Button: styles for button treatment and color values
extension Button {
    
    /// style for any process control buttons
    func mainBtnStyle() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius:25, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .frame(width: 200, height: 50)
        }
    }
}



