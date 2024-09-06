//
//  ExtendedUIStyle.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//

import SwiftUI

/// View Modifiers: Screen width, height computed from active view
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

/// Buttons: Action buttons style and annimation treatment
struct MainButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, 20)
            .background(Color("mainBtnBkg")) /// Assets.Color Set
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius:25, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Buttons: Navigation buttons style and animation treatment
struct NavButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, 15)
            .background(.ultraThinMaterial)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius:20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
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
    /// Subheads Text, adapts to light/dark mode
    func sectionHeader() -> some View {
        font(Font.custom("Arial",size:13)).fontWeight(.semibold).foregroundColor(.secondary)
    }

    /// Body Copy Text, adapts to light/dark mode
    func bodyCopy() -> some View {
        font(Font.custom("Arial",size:12)).fontWeight(.regular).foregroundColor(Color("bodyTextColor"))
    }

    /// Action button label font size/style
    /// - color set from buttonStyle configuration.label property
    func mainBtnLabel() -> some View {
        font(Font.custom("Arial", size: 16)).fontWeight(.semibold)
    }

    /// Navigation button label font size/style
    /// - color set from buttonStyle configuration.label property
    func navBtnLabel() -> some View {
        font(Font.custom("Arial", size: 14)).fontWeight(.regular)
    }
}

/// Color Set extension
extension Color {
    /// public static var mainBtnBkg: Color {
    ///    return Color(red:0.25, green:0.50, blue:0.95)
    /// }
}



