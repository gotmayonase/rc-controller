//
//  ChooseDeviceController.swift
//  rc-controller
//
//  Created by Mike Mayo on 3/20/15.
//  Copyright (c) 2015 Mike Mayo. All rights reserved.
//

import UIKit

import CoreBluetooth
import QuartzCore


class ChooseDeviceController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
  
  var peripherals: [CBPeripheral] = []
  var centralManager: CBCentralManager!
  var chosenPeripheral: CBPeripheral!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func centralManagerDidUpdateState(central: CBCentralManager!) {
    NSLog("central manager updated state to %d", central.state.rawValue)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peripherals.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("DeviceCell", forIndexPath: indexPath) as UITableViewCell
    
    var label: UILabel = cell.viewWithTag(1) as UILabel
    var peripheral = peripherals[indexPath.row]
    
    label.text = peripheral.name
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    NSLog("did select row at indexpath: %@", indexPath)
    self.chosenPeripheral = peripherals[indexPath.row]
    self.chosenPeripheral.delegate = self
    NSLog("Attempting to connect to peripheral: %@", chosenPeripheral)
    NSLog("centralManager: %@", centralManager)
    NSLog("centralManager state: %d", centralManager.state.rawValue)
    centralManager.stopScan()
    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
      self.centralManager.connectPeripheral(self.chosenPeripheral, options: nil)
    })
  }
  
  func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
    NSLog("connected to peripheral!")
    peripheral.discoverServices(nil)
  }
  
  func centralManager(central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!) {
    NSLog("did retrieve connected peripherals")
  }
  
  func centralManager(central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
    NSLog("did retried peripherals")
  }
  
  func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
    NSLog("Failed to connect to peripheral: %@", peripheral)
  }
  
  func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
    NSLog("disconnected from peripheral: %@", peripheral)
  }
  
  func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
    for service in peripheral.services as [CBService] {
      NSLog("Discovered service: %@", service)
    }
  }
  
  
}
