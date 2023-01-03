//
//  ScanViewController.swift
//  BluetoothExample
//
//  Created by Nikunj Sareriya on 24/06/22.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController {
    
    @IBOutlet weak var tblScanView: UITableView! {
        didSet {
            self.tblScanView.delegate = self
            self.tblScanView.dataSource = self
        }
    }
    @IBOutlet weak var lblBLEStatus: UILabel! {
        didSet {
            self.lblBLEStatus.text = "Scanning"
            self.lblBLEStatus.textColor = .black
        }
    }
    @IBOutlet weak var activityIndicaor: UIActivityIndicatorView! {
        didSet {
            self.activityIndicaor.startAnimating()
        }
    }
    
    var centralManager: CBCentralManager!
    var arrPeripheral: [CBPeripheral] = []
    var isFromDidSelect = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.lblBLEStatus.text = "Scanning"
        self.lblBLEStatus.textColor = .black
        self.activityIndicaor.startAnimating()
        // MARK: - 1) Initialize Central Manager, it represents the iOS device
        // This will call centralManagerDidUpdateState delegate method
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getStateName(state: Int) -> String {
        switch state {
        case 0:
            return "Disconnected"
        case 1:
            return "Connecting"
        case 2:
            return "Connected"
        default:
            return "Disconnected"
        }
    }

}

extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPeripheral.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell") as? ScanTableViewCell else { return UITableViewCell() }
        if let name = self.arrPeripheral[indexPath.row].name, !name.isEmpty {
            cell.lblName.text = name
        } else {
            cell.lblName.text = self.arrPeripheral[indexPath.row].identifier.uuidString
        }
        cell.lblState.text = self.getStateName(state: self.arrPeripheral[indexPath.row].state.rawValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.isFromDidSelect = true
        centralManager.connect(arrPeripheral[indexPath.row])
    }
}

extension ScanViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      
      switch central.state {
      case .unknown:
        print("central.state is .unknown")
          self.activityIndicaor.stopAnimating()
          CommonFunction.showAlert(msg: "central.state is .unknown", vc: self)
      case .resetting:
        print("central.state is .resetting")
          self.activityIndicaor.stopAnimating()
          CommonFunction.showAlert(msg: "central.state is .resetting", vc: self)
      case .unsupported:
        print("central.state is .unsupported")
          self.activityIndicaor.stopAnimating()
          CommonFunction.showAlert(msg: "central.state is .unsupported", vc: self)
      case .unauthorized:
        print("central.state is .unauthorized")
          self.activityIndicaor.stopAnimating()
          CommonFunction.showAlert(msg: "central.state is .unauthorized", vc: self)
      case .poweredOff:
        print("central.state is .poweredOff")
          self.activityIndicaor.stopAnimating()
          CommonFunction.showAlert(msg: "central.state is .poweredOff", vc: self)
        
      case .poweredOn:
        print("central.state is .poweredOn")
        // MARK: - 2) Start scanning for Peripherals
        // Here we are specifically looking for peripherals with Heart Rate service
        // We can change the UUID to look for peripherals with other services
        // Or we can set it to nil and get all peripherals around
        // This will call didDiscover delegate method
        centralManager.scanForPeripherals(withServices: nil)
      @unknown default:
          print("central.state is .poweredOff")
      }
    }
    
    // MARK: - 3) Here we get a reference to the peripheral
    // Now we stop scanning other for other peripherals
    // And connect centralManager to heartRatePeripheral
    // This will call didConnect delegate method
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("found peripheral: \(peripheral)")
        if self.isFromDidSelect {
            self.lblBLEStatus.text = "Connecting"
            self.lblBLEStatus.textColor = .blue
        } else {
            self.lblBLEStatus.text = "Scanning"
            self.lblBLEStatus.textColor = .black
        }
        if let per = arrPeripheral.filter({ $0.name == peripheral.name }) as? [CBPeripheral], per.count == 0 {
            arrPeripheral.append(peripheral)
            DispatchQueue.main.async {
                self.tblScanView.reloadData()
            }
        }
    }
    
    // MARK: - 4) Here the iOS device as a central and the Heart Rate sensor as a peripheral are connected
    // Now we discover the Heart Rate Service in the Peripheral
    // We can discover all available services by setting the array to nil
    // This will call didDiscoverServices delegate method
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
        self.lblBLEStatus.text = "Connected"
        self.lblBLEStatus.textColor = .green
        self.activityIndicaor.stopAnimating()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "PeripheralViewController") as? PeripheralViewController {
            vc.examplePeripheral = peripheral
            self.navigationController?.pushViewController(vc, animated: true)
        }
//      heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
  }
