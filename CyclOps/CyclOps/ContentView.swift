//
//  ContentView.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//
import SwiftUI

struct ContentView: View {
    
    @ObservedObject var parentsStore: ParentsStore = .vwstack
    let appName = "CyclOps Alpha v"
    let appVer = "1.0"

    init() {
        UINavigationBar.appearance()
            .largeTitleTextAttributes = [.font: UIFont.preferredFont(forTextStyle:.largeTitle)]
    }

    var body: some View {
        NavigationView {
            List(parentsStore.children, id: \.self) { child in
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
            case "Settings": Devices()      /// temporary, will be Settings
            case "Quick Setup": Camera()    /// temporary, will be QuickSetup
            default: Home(model: HomeUI())
            }
        }
        Button("Remove from stack") {
            ParentsStore.vwstack.remove(child)
        }
    }
}

final class ParentsStore: ObservableObject {
    static let vwstack = ParentsStore()
    
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
