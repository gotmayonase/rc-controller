//
//  ViewController.swift
//  rc-controller
//
//  Created by Mike Mayo on 3/17/15.
//  Copyright (c) 2015 Mike Mayo. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

class RemoteController: UIViewController, JoystickDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder);
  }
  
  @IBOutlet var leftJoyStick: JoyStickView!
  @IBOutlet var rightJoyStick: JoyStickView!
  @IBOutlet var connectionLabel: UILabel!
  
  var centralManager: CBCentralManager!
  var peripheral: CBPeripheral!
  var transmitCharacteristic: CBCharacteristic!
  var receiveCharacteristic: CBCharacteristic!
  
  var lastDir: UInt8 = 0x02
  var lastSpeed: Int32 = 0
  var lastSide: UInt8 = 0x02

  override func viewDidLoad() {
    super.viewDidLoad()
    centralManager = CBCentralManager(delegate: self, queue: nil)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func joystick(stick: JoyStickView!, didMoveToX x_value: NSNumber!, andY y_value: NSNumber!) {
    var speed: Float
    
    var _direction: UInt8!

    
    if(y_value.floatValue < 0.0) {
      _direction = 0x01
    } else {
      _direction = 0x00
    }
    
    speed = (y_value.floatValue) / (Float(stick.frame.height) / 2)
    speed *= 255
    
    var correctedSpeed = abs(Int32(speed))
    correctedSpeed = min(255, correctedSpeed)
    var side: UInt8!
    
    if(stick == rightJoyStick) {
      side = 0x01
    } else {
      side = 0x00
    }
    let fudge = 20
    let sameDir = (lastDir == _direction)
    let sameSpeed = correctedSpeed > lastSpeed - fudge && correctedSpeed < lastSpeed + fudge
    let sameSide = (lastSide == side)
    
    if (sameDir && sameSpeed && sameSide) {
      NSLog("no op")
      return;
    } else {
      NSLog("%d, %d, %d", _direction, correctedSpeed, side)
      lastDir = _direction
      lastSpeed = correctedSpeed
      lastSide = side
      writeJoystickMovement(side, direction: _direction, speed: UInt8(correctedSpeed))
    }
  }
  
  func writeJoystickMovement(side: UInt8, direction: UInt8, speed: UInt8) {
    var buf = [side, direction, speed]
    var speedData = NSData(bytes: buf, length: 3)
    peripheral.writeValue(speedData, forCharacteristic: receiveCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
  }
  
  func centralManagerDidUpdateState(central: CBCentralManager!) {
    NSLog("central manager updated state: %d", central.state.rawValue)
    centralManager.scanForPeripheralsWithServices([CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")], options: nil)
  }
  
  func centralManager(central: CBCentralManager!, didDiscoverPeripheral _peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
    centralManager.stopScan()
    if(peripheral != _peripheral) {
      peripheral = _peripheral
      
      centralManager.connectPeripheral(peripheral, options: nil)
    }
  }
  
  func centralManager(central: CBCentralManager!, didConnectPeripheral _peripheral: CBPeripheral!) {
    peripheral.delegate = self
    peripheral.discoverServices([CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")])
  }
  
  func peripheral(_peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
    for service in peripheral.services as [CBService] {
      peripheral.discoverCharacteristics(nil, forService: service)
    }
  }
  
  func centralManager(central: CBCentralManager!, didDisconnectPeripheral _peripheral: CBPeripheral!, error: NSError!) {
    connectionLabel.text = "Disconnected"
    connectionLabel.textColor = UIColor.redColor()
    leftJoyStick.userInteractionEnabled = false
    rightJoyStick.userInteractionEnabled = false
    peripheral = nil;
    centralManager.scanForPeripheralsWithServices([CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")], options: nil)
  }
  
  func peripheral(_peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
    for characteristic in service.characteristics as [CBCharacteristic] {
      if(characteristic.UUID == CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")){
        receiveCharacteristic = characteristic;
      }
      if(characteristic.UUID == CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")){
        transmitCharacteristic = characteristic;
      }
    }
    leftJoyStick.userInteractionEnabled = true
    rightJoyStick.userInteractionEnabled = true
    connectionLabel.text = "Connected"
    connectionLabel.textColor = UIColor.greenColor()
  }



}

