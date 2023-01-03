//
//  PeripheralViewController.swift
//  BluetoothExample
//
//  Created by Nikunj Sareriya on 24/06/22.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {
    
    @IBOutlet weak var tblPeripheralView: UITableView! {
        didSet {
            self.tblPeripheralView.delegate = self
            self.tblPeripheralView.dataSource = self
        }
    }
    
    var examplePeripheral: CBPeripheral?
    var arrCharacteristic: [CBCharacteristic]?
    var dic: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.examplePeripheral?.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PeripheralViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell") as? ScanTableViewCell else { return UITableViewCell()}
//        if let char = self.dic["\(self.arrServices[indexPath.section])"] as? [CBCharacteristic] {
//            cell.lblName.text = "\(char[indexPath.row].name)"
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.examplePeripheral!.discoverCharacteristics(nil, for: self.arrCharacteristic![indexPath.row])
    }
}

extension PeripheralViewController: CBPeripheralDelegate {
    
    // MARK: - 5) Here we get an array that has one element which is Hate Rate service
    // Now we discover all characteristics in the Hate Rate service
    // This will call didDiscoverCharacteristicsFor delegate method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
      
      guard let services = peripheral.services else { return }
      
      for service in services {
        print(service)
        print(service.characteristics ?? "characteristics are nil")
//        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
    
    
    // MARK: - 6) Here we get 2 Characteristics:
    // 1. Body Location Characteristic: has read property for one time read
    // 2. Heart Rate Measurement Characteristic: has notify property, to notify the iOS device every time the heart rate changes
    // Now we read the value of each characteristic
    // This will update didUpdateValueFor delegate method
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        var arrChar: [CBCharacteristic] = []
      guard let characteristics = service.characteristics else { return }
      
      for characteristic in characteristics {
        print(characteristic)
        
        // Body Location Characteristic
        if characteristic.properties.contains(.read) {
          print("\(characteristic.uuid): properties contains .read")
          peripheral.readValue(for: characteristic)
        }
        
        // Heart Rate Measurement Characteristic
        if characteristic.properties.contains(.notify) {
          print("\(characteristic.uuid): properties contains .notify")
          peripheral.setNotifyValue(true, for: characteristic)
        }
          arrChar.append(characteristic)
      }
        self.dic["\(service)"] = arrChar
    }
    
    
    // MARK: - 7) Here we get the value of the Body Location one time & the value of Heart Rate every notification
    // So we read the characteristic value and show it on the corresponding Label
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
      print("characteristic: \(characteristic)")
//      switch characteristic.uuid {
//      case bodySensorLocationCharacteristicCBUUID:
//        let bodySensorLocation = bodyLocation(from: characteristic)
//        bodySensorLocationLabel.text = bodySensorLocation
//      case heartRateMeasurementCharacteristicCBUUID:
//        let bpm = heartRate(from: characteristic)
//        onHeartRateReceived(bpm)
//      default:
//        print("Unhandled Characteristic UUID: \(characteristic.uuid)")
//      }
    }
  }
