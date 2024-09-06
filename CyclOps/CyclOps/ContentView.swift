//
//  ContentView.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//
import UIKit
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var parentStore: ParentStore = .viewstack
    let appName = "CyclOps Alpha v"
    let appVer = "1.0"

    init() {
        UINavigationBar.appearance()
            .largeTitleTextAttributes = [
                .font: UIFont.preferredFont(forTextStyle:.largeTitle)
            ]
    }

    var body: some View {
        NavigationView {
            List(parentStore.children, id: \.self) { child in
                NavigationLink(child) {
                    ViewStackTop(child: child)
                }
            }.navigationTitle(appName + appVer)
        }
    }
}

struct ViewStackTop: View {
    let child: String
    var body: some View {
        VStack {
            /// Text("Opening your child \(child)")
            switch child {
                case "Home": Home(model: HomeUI())
                case "Settings": Devices()
                case "Quick Setup": Camera(model: CameraUI())
                default: Home(model: HomeUI())
            }
        }
        Button("Remove from stack") {
            ParentStore.viewstack.remove(child)
        }
    }
}

final class ParentStore: ObservableObject {
    static let viewstack = ParentStore()
    
    @Published var children: [String] = ["Home", "Settings", "Quick Setup"]
    
    func add(_ child: String) {
        children.append(child)
    }
    
    func remove(_ child: String) {
        children.removeAll(where: {$0 == child})
    }
}

// #Preview {
//     ContentView()
// }
