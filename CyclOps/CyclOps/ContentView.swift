//
//  ContentView.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var parentsStore: ParentsStore = .vwstack
    
    var body: some View {
        NavigationView {
            List(parentsStore.children, id: \.self) { child in
                NavigationLink(child) {
                    ViewStackTop(child: child)
                }
            }.navigationTitle("CyclOps Alpha v1.0")
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
            case "Settings": Devices()  /// temporary, will be Settings
            case "Sign In": Camera()    /// temporary, will be SignIn
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
    
    @Published var children: [String] = ["Home", "Settings", "Sign In"]
    
    func add(_ child: String) {
        children.append(child)
    }
    
    func remove(_ child: String) {
        children.removeAll(where: {$0 == child})
    }
}

#Preview {
    ContentView()
}
