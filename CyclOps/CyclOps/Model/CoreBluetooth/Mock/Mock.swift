//
//  Mock.swift
//  CyclOps
//
//  Created by Ron White on 6/5/24.
//

import Foundation

protocol Mock {}

extension Mock {
    var className: String {
        return String(describing: type(of: self))
    }
    
    func log(_ message: String? = nil) {
        print("Mocking bird class -", className, message ?? "")
    }
}
