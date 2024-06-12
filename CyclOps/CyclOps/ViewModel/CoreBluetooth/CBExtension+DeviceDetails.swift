//
//  CBExtension+DevicesUI.swift
//  CyclOps
//
//  Created by Ron White on 6/5/24.
//

import SwiftUI
import CoreBluetooth

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
