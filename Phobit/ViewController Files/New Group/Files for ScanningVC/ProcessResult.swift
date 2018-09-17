//
//  ProcessResult.swift
//  Phobit
//
//  Created by 73 on 01.05.18.
//  Copyright © 2018 73. All rights reserved.
//


import UIKit

extension ScanningViewController {
    
    fileprivate func doOCR(processorImage: UIImage) {
        let webservice = WebService.init(image: processorImage)
        
        let tuple = self.showLoadingScreen(webservice: webservice)
        
        let progressView = tuple.0
        let alertView = tuple.1
        
        webservice.start(completion: { (response, statusCode) in
            
            UserDefaults.standard.removeObject(forKey: "OCRstring")
            
            print("###### completion started")
            
            if statusCode == WebServiceStatus.normal {
                // perform with text in here.
                let tag = Tagger.init()
                if let rechnungsersteller = tag.recognizeOCR_Result(für: response) {
                    self.billdata?.rechnungsersteller = rechnungsersteller
                }
                UserDefaults.standard.set(response, forKey: "OCRstring")
                // end
                
                alertView.dismiss(animated: false, completion: {
                    self.overlay?.invisible()
                    self.session?.startRunning()
                    
                    let noBillData = (self.billdata == nil)
                    
                    self.jumpToAuswertung(withImage: processorImage, noBillData: noBillData)
                    self.cleanUp()
                })
            } else if statusCode == WebServiceStatus.systemCancelled || statusCode == WebServiceStatus.timeout {
                // dissmissing the loading alertView...
                alertView.dismiss(animated: false, completion: {
                    DispatchQueue.main.async {
                        self.overlay?.invisible()
                        self.cleanUp()
                    }
                    
                    
                    self.infromUserAboutWebserviceFailure(webservicestatus: statusCode)
                })
                
            } else {
                // userCancelled...
                
                DispatchQueue.main.async {
                    self.cleanUp()
                    self.session?.startRunning()
                }
            }
            
        }, progressView: progressView)
    }
    
    
    func gotImage() {
        
        self.session?.stopRunning()
        // webservice task here.
        // user information.
        // crop image.
        // filter image.
        
        
        let processor = ImageProcessor.init(image: self.image!)
        
        processor.process { (success) in
            
            let qrResult = self.isQRok()
            
            if success && qrResult {
                self.doOCR(processorImage: processor.getImage())
            } else {
                DispatchQueue.main.async {
                    self.session?.startRunning()
                    self.cleanUp()
                }
            }
        }
    }
    
    
    
    func cleanUp() {
        self.autoCapture?.resumeStop()
        self.autoCapture?.resumeQR()
        self.image = nil
        self.billdata = nil
        self.cameraButton.isEnabled = true
        self.canTakeNextQR = true
    }
    
    
    @objc func jumpToAuswertung(withImage correctedImage: UIImage?, noBillData : Bool) {
        /*
         guard let billdata = billdata else {
         let alert = UIAlertController.init(title: "Keinen passenden QR-Code gefunden!", message: nil, preferredStyle: .alert)
         self.present(alert, animated: true, completion: nil)
         let dispatchAfter = DispatchTime.now() + 2.5
         DispatchQueue.main.asyncAfter(deadline: dispatchAfter){
         alert.dismiss(animated: true, completion: nil)
         }
         
         return
         }
         */
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "Auswertung") as! AuswertungsTableViewController
        
        vc.bill = billdata
        
        vc.noBillData = noBillData
        
        if let image = correctedImage {
            vc.image = image
        }
        
        let nvc = UINavigationController.init(rootViewController: vc)
        
        self.present(nvc, animated: true) {
            self.cameraButton.isEnabled = true
            self.autoCapture?.resumeQR()
            self.autoCapture?.resumeStop()
            self.billdata = nil
            self.foundQRCodeBanner.removeFromSuperview()
            self.blitzButton.setTitle("Aus", for: .normal)
        }
    }
    
    @objc func jumpToAuswertungWithQR() {
        self.jumpToAuswertung(withImage: nil, noBillData: false)
    }
    
    func isQRok() -> Bool{
        
        guard billdata != nil else {
            //IN DEVELOPMENT ..
            //DO NOT DELETE OR CHANGE
            
            let processor = ImageProcessor.init(image: self.image!)
            
            processor.process { (success) in
                let processedImage = processor.getImage()
                
                let alert = UIAlertController.init(title: "Keinen passenden QR-Code gefunden", message: "Willst du deine Rechnung selber ausfüllen?", preferredStyle: .alert)
                
                //Jump to Auswertung without BillData, let's see if this works ..
                let jaAction = UIAlertAction.init(title: "Ja, ich will meine Rechnung selber eingeben", style: .default, handler: { action in
                    self.doOCR(processorImage: processedImage)
                    //self.jumpToAuswertung(withImage: processedImage, noBillData: true)
                })
                
                let neinAction = UIAlertAction.init(title: "Nein, ich versuche es erneut.", style: .destructive, handler: nil)
                
                alert.addAction(jaAction)
                alert.addAction(neinAction)
                self.present(alert, animated: false, completion: nil)
            }
            
            
            
            //UNCOMMENT THESE LINES IN CASE OF FAILURE AND COMMENT THE LINES ABOVE
            
            /**
             let alert = UIAlertController.init(title: "Keinen passenden QR-Code gefunden!", message: nil, preferredStyle: .alert)
             self.present(alert, animated: true, completion: nil)
             let dispatchAfter = DispatchTime.now() + 2.5
             DispatchQueue.main.asyncAfter(deadline: dispatchAfter){
             alert.dismiss(animated: true, completion: nil)
             }
             **/
            return false
        }
        
        return true
    }
}

