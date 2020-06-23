//
//  ContentView.swift
//  bluetooth
//
//  Created by Mirko Dziadzka on 21.06.20.
//  Copyright © 2020 Mirko Dziadzka. All rights reserved.
//

import SwiftUI
import CoreBluetooth

extension Date {
    var timeAsString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss"
        return formatter.string(from: self)
    }
}

struct DeviceView : View {
    @Environment(\.colorScheme) var colorScheme

    var device: DeviceEntry
    
    private var uuid: String { device.uuid }
    private var name: String {device.periperal.name ?? "" }
    private var freshnes: Double { -device.lastSeen.timeIntervalSinceNow }
    private var age: Double { -device.firstSeeen.timeIntervalSinceNow }

    private var lastSeenAsString : String { freshnes < 1 ? "now" : "\(Int(freshnes)) seconds ago" }
    private var firstSeenAsString: String { age < 1 ? "now" : "\(Int(age)) seconds ago" }
    
    private var defaultColor: Color { colorScheme == .dark ? Color.white : Color.black }
    private var rssiColor: Color {
        device.rssi > -60 ? Color.green : (device.rssi > -70 ? Color.orange : defaultColor )
    }
    
    private var freshnesColor: Color {
        freshnes < 5 ? Color.green : (age < 15 ? Color.orange : defaultColor )
    }

    var body: some View {
        HStack {
            Text("Device: \(uuid)")
            Spacer()
            Text("first seen: \(firstSeenAsString)")
            Text("last seen: \(lastSeenAsString)").foregroundColor(freshnesColor)
            Text("signal strength: \(device.rssi, specifier: "%.0f")").foregroundColor(rssiColor)
        }
    }
}

struct ContentView : View {
    @ObservedObject var scanner: Scanner
    
    private var currentDeviceUUIDs: [String] {
        scanner.uuids.filter {
            scanner.devices[$0]?.isCurrent ?? false
        }
    }
    private var otherDeviceUUIDs: [String] {
        scanner.uuids.filter {
            scanner.devices[$0]?.isCurrent == false
        }
    }
    
    var body: some View {
        VStack {
            Text("Devices with BLE Beacon type \(exposureNotificationServiceUuid) seen in the last \(exposureNotificationMaxAge, specifier: "%.0f") seconds")
            HStack {
                Text("Scanner State:")
                Text("\(scanner.scannerState.asString)").foregroundColor(scanner.scannerState.asColor)
            }
            Divider()
            List {
                Section(header: Text("Current")) {
                    ForEach(currentDeviceUUIDs, id: \.self) { uuid in
                        DeviceView(device: self.scanner.devices[uuid]!)
                    }
                }
                if otherDeviceUUIDs.count > 0 {
                    Section(header: Text("Other")) {
                        ForEach(otherDeviceUUIDs, id: \.self) { uuid in
                            DeviceView(device: self.scanner.devices[uuid]!)
                        }
                    }
                }
            }
                .id(UUID()) // make this not cachable
            
        }
        .frame(minWidth: 640)
        .frame(alignment: .topLeading)
    }
}

