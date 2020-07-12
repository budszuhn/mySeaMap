//
//  MSMViewControllerExtension.swift
//  mySeaMap
//
//  Created by Frank Budszuhn on 27.11.16.
//  Copyright © 2016 - 2020 Frank Budszuhn. See LICENSE.
//

import Foundation
import UIKit

extension MSMViewController {
    
    @objc func showNavigationWarningAlert() {

        let alert = UIAlertController(title: NSLocalizedString("WARNING_ALERT_HEADLINE", comment: ""), message: NSLocalizedString("WARNING_ALERT_TEXT", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("WARNING_ALERT_BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
