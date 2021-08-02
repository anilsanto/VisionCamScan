//
//  ViewController.swift
//  SwiftScanner
//
//  Created by anilsanto on 08/01/2021.
//  Copyright (c) 2021 anilsanto. All rights reserved.
//

import UIKit
#if canImport(VisionCamScan)
import VisionCamScan
#endif

class ViewController: UIViewController, VisionCamScanViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if #available(iOS 13, *) {
            let controller = VisionCamScanViewController(with: self, mode: .card, title: "Card Scanner")
            self.present(controller, animated: true, completion: nil)
//            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @available(iOS 13, *)
    func scannerViewControllerDidCancel(_viewController: VisionCamScanViewController) {
        
    }
    
    @available(iOS 13, *)
    func scannerViewController(_ viewController: VisionCamScanViewController, didErrorWith error: ScannerError) {
        
    }
    
    @available(iOS 13, *)
    func scannerViewController<T>(_ viewController: VisionCamScanViewController, didFinishWith data: T) {
        if let card = data as? CreditCard {
            print(card.name)
            print(card.number)
            print(card.expireDate)
        }
        else{
            print(data)
        }
        viewController.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


