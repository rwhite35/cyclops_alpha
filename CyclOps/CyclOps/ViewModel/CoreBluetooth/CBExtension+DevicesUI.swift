//
//  CBExtension+DevicesUI.swift
//  CyclOps
//
//  Created by Ron White on 6/5/24.
//

import SwiftUI
import CoreBluetooth

//MARK: - Navigation Items
extension CBViewModel {
    func navigationToDetailView(isDetailViewLinkActive: Binding<Bool>) -> some View {
        let navigationToDetailView =
            NavigationLink("",
                           destination: Devices(),
                           isActive: isDetailViewLinkActive).frame(width: 0, height: 0)
        return navigationToDetailView
    }
}

//MARK: - View Items
extension CBViewModel {
    func UIButtonView(proxy: GeometryProxy, text: String) -> some View {
        let UIButtonView =
            VStack {
                Text(text)
                    .frame(width: proxy.size.width / 1.1,
                           height: 50,
                           alignment: .center)
                    .foregroundColor(Color.blue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2))
            }
        return UIButtonView
    }
}
