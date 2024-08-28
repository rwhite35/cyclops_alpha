//
//  DetectionManager.swift
//  CyclOps
//
//  Created by Ron White on 6/4/24.
//

import Foundation

final class DetectionManager: NSObject, ObservableObject {
    
    @Published var isODSRunning: Bool = false
    @Published var odsLabel: [String] = ["Start","Stop"]
}
