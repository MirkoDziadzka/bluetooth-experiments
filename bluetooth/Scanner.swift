//
//  Scanner.swift
//  bluetooth
//
//  Created by Mirko Dziadzka on 22.06.20.
//  Copyright © 2020 Mirko Dziadzka. All rights reserved.
//

import Foundation
import CoreBluetooth

// MARK: config section

let exposureNotificationServiceUuid = CBUUID(string: "FD6F")
let exposureNotificationMaxAge: Double  = 15 * 60
let exposureNotificationCurrrentAge : Int = 60


struct DeviceEntry: Comparable {
    static func < (lhs: DeviceEntry, rhs: DeviceEntry) -> Bool {
        if lhs.isCurrent != rhs.isCurrent {
            return lhs.isCurrent
        }
        return lhs.uuid < rhs.uuid
    }
    
    static func == (lhs: DeviceEntry, rhs: DeviceEntry) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    var uuid: String
    var periperal: CBPeripheral
    var firstSeeen: Date
    var lastSeen: Date
    var rssi: Double
    var advertisementData: [String: Any]
    
    var isCurrent: Bool {
        return -lastSeen.timeIntervalSinceNow < Double(exposureNotificationCurrrentAge)
    }
    
    var isExpired: Bool {
        return -lastSeen.timeIntervalSinceNow > exposureNotificationMaxAge
    }
    
    var data: String {
        let uuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as! [CBUUID]?
        let uuidStrings = uuids?.map { uuid in uuid.uuidString}
        
        return (uuidStrings ?? []).joined(separator: ", ")
    }
    
    mutating func updateLastSeen(_ lastSeen: Date) {
        self.lastSeen = lastSeen
    }
    mutating func updateLastSeen(_ rssi: Double) {
        self.rssi = rssi
    }
}


class Scanner: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var devices: [String: DeviceEntry] = [:]
    @Published var scannerState: CBManagerState = .unknown
    
    private var centralManager: CBCentralManager!
    
    var uuids: [String] {
        return devices.values
            // .filter({ !$0.isExpired })
            .sorted()
            .map { $0.uuid }
    }
    
    func updateLastSeen(for uuid: String, withRssi rssi: Double) {
        if var deviceEntry = devices[uuid] {
            deviceEntry.updateLastSeen(Date())
            deviceEntry.updateLastSeen(rssi)
            devices[uuid] = deviceEntry
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    // MARK: CBCentralManagerDelegate implementations
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
            // let services = [exposureNotificationServiceUuid]
            let services : [CBUUID]? = nil
            centralManager.scanForPeripherals(withServices: services, options: options)
        }
        scannerState = central.state
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let uuid = peripheral.identifier.uuidString
        
        if devices[uuid] == nil {
            devices[uuid] = DeviceEntry(
                uuid: uuid,
                periperal: peripheral,
                firstSeeen: Date(),
                lastSeen: Date(),
                rssi: Double(truncating: RSSI),
                advertisementData: advertisementData
            )
        } else {
            updateLastSeen(for: uuid, withRssi: Double(truncating: RSSI))
        }
    }
}
