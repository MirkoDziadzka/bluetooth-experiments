//
//  CBManagerState+asString.swift
//  bluetooth
//
//  Created by Mirko Dziadzka on 22.06.20.
//  Copyright © 2020 Mirko Dziadzka. All rights reserved.
//

import Foundation
import CoreBluetooth
import SwiftUI

extension CBManagerState {
    var asString : String {
        switch( self ) {
        case .unknown:
             return "unkwnon"
        case .resetting:
            return "resetting"
        case .unsupported:
             return "unsupported"
        case .unauthorized:
             return "unauthorized"
        case .poweredOff:
             return "poweredOff"
        case .poweredOn:
             return "poweredOn"
        @unknown default:
             return "unknown default"
        }
        
    }
    
    var asColor: Color? {
        switch self {
        case .unknown:
            return nil
        case .resetting:
            return Color.orange
        case .unsupported:
            return Color.red
        case .unauthorized:
            return Color.red
        case .poweredOff:
            return Color.red
        case .poweredOn:
            return Color.green
        @unknown default:
            return Color.red
        }
    }
}

