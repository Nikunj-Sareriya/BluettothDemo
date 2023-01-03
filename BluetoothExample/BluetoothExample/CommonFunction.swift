//
//  CommonFunction.swift
//  BluetoothExample
//
//  Created by Nikunj Sareriya on 27/06/22.
//

import Foundation
import UIKit

class CommonFunction {
    class func showAlert(msg: String, vc: UIViewController) {
        let alert = UIAlertController(title: "Oops!", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        vc.present(alert, animated: true)
    }
}

