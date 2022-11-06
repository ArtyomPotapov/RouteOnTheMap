//
//  AddAddressAlert.swift
//  LocationRoute
//
//  Created by Artyom Potapov on 06.11.2022.
//

import UIKit

extension ViewController {
    
    func addAddressAlert(title: String, placeholder: String, completionHandler: @escaping (String)->()){
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField { textFiels in
            textFiels.placeholder = placeholder
        }
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            let textField = alertController.textFields?.first
            guard let text = textField?.text else { return }
            completionHandler(text)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(okButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: false)
    }
    
    func showErrorAlert(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelButton)
        present(alertController, animated: false)
    }
}
