//
//  LoadingAlertViewController.swift
//  Phobit
//
//  Created by Paul Wiesinger on 12.07.18.
//  Copyright © 2018 LonoS. All rights reserved.
//

import UIKit
import AVFoundation

class LoadingAlertViewController: UIViewController {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var messageView: UIView!
    
    var webservice: WebService?
    var image: UIImage?
    var vc: ScanningViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let vc = getScanningViewController() {
            self.vc = vc
            if let image = vc.image {
                self.image = image
            }
        }
        
        message.text = RandomLoadingMessages.init().message
        message.adjustsFontSizeToFitWidth = true
        
        // animating the Message in.
        messageView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.2, animations: {
            self.messageView.transform = CGAffineTransform.identity
        })
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        webservice?.cancelUploadFromUser()
        self.dismiss(animated: false, completion: {
            
        })
    }
    
    @IBAction func saveLocalButton(_ sender: Any) {
        webservice?.cancelUploadFromUser()
        self.dismiss(animated: false) {
            if let vc = self.vc {
                vc.session?.startRunning()
                if let image = self.image {
                    let processor = ImageProcessor.init(image: image)
                    processor.process(completion: { (success) in
                        if let bill = vc.billdata {
                            LokaleAblage.init().save(billdata: bill, image: processor.getImage(), target: self)
                        }
                        vc.cleanUp()
                    })
                } else {
                    vc.cleanUp()
                }
            }
        }
    }
    
    @IBAction func proceedWithoutRecognition(_ sender: Any) {
        
    }
    
    
    func getScanningViewController() -> ScanningViewController? {
        if let snapVC = presentingViewController as? SnapContainerViewController {
            return (snapVC.middleVc.childViewControllers.first as! ScanningViewController)
        }
        
        return nil
    }
}

