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
    
    @IBOutlet weak var scan: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    @IBAction func scanAction(_ sender: Any) {
        if #available(iOS 13, *) {
            let controller = VisionCamScanViewController(with: self, mode: .MRZcode, title: "Card Scanner")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @available(iOS 13, *)
    func scannerViewControllerDidCancel(_ viewController: VisionCamScanViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 13, *)
    func scannerViewController(_ viewController: VisionCamScanViewController, didErrorWith error: ScannerError) {
        
    }
    
    @available(iOS 13, *)
    func scannerViewController<T>(_ viewController: VisionCamScanViewController, didFinishWith data: T) {
        viewController.dismiss(animated: true, completion: nil)
        if let card = data as? CreditCard {
            print(card.name)
            print(card.number)
            print(card.expireDate)
            let alert = UIAlertController(title: card.name ?? "",
                                          message: card.number ,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
        }
        else{
            print(data)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


