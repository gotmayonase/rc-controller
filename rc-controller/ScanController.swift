//
//  ScanController.swift
//  rc-controller
//
//  Created by Mike Mayo on 3/20/15.
//  Copyright (c) 2015 Mike Mayo. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

class ScanController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @IBOutlet var scanButton: UIButton!
  
  var centralManager: CBCentralManager!
  var peripherals: [CBPeripheral]! = []
  var chosenPeripheral: CBPeripheral!
  var transmitCharacteristic: CBCharacteristic!
  var receiveCharacteristic: CBCharacteristic!
  
  @IBAction func scan() {
    centralManager.scanForPeripheralsWithServices([CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")], options: nil)
  }
  
  override func viewDidLoad() {
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  func centralManagerDidUpdateState(central: CBCentralManager!) {
    NSLog("central manager updated state: %d", central.state.rawValue)
    if(central.state == .PoweredOn) {
      scanButton.enabled = true
    }
  }
  
  func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
    centralManager.stopScan()
    if(chosenPeripheral != peripheral) {
      chosenPeripheral = peripheral
      
      centralManager.connectPeripheral(chosenPeripheral, options: nil)
    }
  }
  
  func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
    chosenPeripheral.delegate = self
    chosenPeripheral.discoverServices([CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")])
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var vc: RemoteController = segue.destinationViewController as RemoteController
    vc.peripheral = chosenPeripheral
    vc.transmitCharacteristic = transmitCharacteristic
    vc.receiveCharacteristic = receiveCharacteristic
  }
  
  func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
    for service in peripheral.services as [CBService] {
      chosenPeripheral.discoverCharacteristics(nil, forService: service)

    }
  }
  
  func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
    for characteristic in service.characteristics as [CBCharacteristic] {
      if(characteristic.UUID == CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")){
        receiveCharacteristic = characteristic;
      }
      if(characteristic.UUID == CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")){
        transmitCharacteristic = characteristic;
      }
    }
    self.performSegueWithIdentifier("ToController", sender: nil);
  }

  
}
