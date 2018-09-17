//
//  ScanningUserInformation.swift
//  Phobit
//
//  Created by 73 on 01.05.18.
//  Copyright © 2018 73. All rights reserved.
//

import UIKit

extension ScanningViewController {
    
    func errorWithCameraAuthorization() {
        let alert = UIAlertController.init(title: "Da stimmt etwas nicht!", message: "Wir können nicht auf deine Kamera zugreifen, da uns der Zugriff durch die Einstellungen verwährt wird. Gehe in die Einstellungen und erlaube uns den Zugriff auf deine Kamera.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction.init(title: "zu den Einstellungen", style: .default, handler: { (_) in
            UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func informUserAboutQR() {
        // present the sheet
        DispatchQueue.main.async {
            self.foundQRCodeBanner.alpha = 0
            
            self.foundQRCodeBanner.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 10, height: 87)
            
            self.foundQRCodeBanner.center = CGPoint.init(x: self.view.center.x, y: self.view.safeAreaInsets.top + 45)
            self.view.addSubview(self.foundQRCodeBanner)
            
            
            // animate in
            UIView.animate(withDuration: 0.3) {
                self.foundQRCodeBanner.alpha = 1
            }
            
            
            // animate out after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.foundQRCodeBanner.alpha = 0
                }, completion: { (success) in
                    self.foundQRCodeBanner.removeFromSuperview()
                    self.foundQRCodeBanner.alpha = 1
                    self.autoCapture?.resumeQR()
                    
                    self.canTakeNextQR = true
                })
            }
        }
    }
    
    
    // returns the progress view for loading progress to fill with data.
    
    // in former times this function returned a UIAlertController
    func showLoadingScreen(webservice: WebService) -> (UIProgressView, UIViewController) {
        /*
        let alertView = UIAlertController(title: "\n" + RandomLoadingMessages().message, message: nil, preferredStyle: .alert)
    
        
        let progressView = UIProgressView.init()
        progressView.progress = 0
        progressView.frame = CGRect.init(x: 10, y: 20, width: 250, height: 0)
        alertView.view.addSubview(progressView)
 
        
        alertView.addAction(UIAlertAction.init(title: "Abbrechen", style: .cancel, handler: { (action) in
            webservice.cancelUploadFromUser()
            alertView.dismiss(animated: true, completion: nil)
        }))
        
        
  
        
        self.present(alertView, animated: true, completion: nil)
        */
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "LoadingAlertVC") as! LoadingAlertViewController
        
        vc.loadView() // god's function
        let progressView = vc.progressView
        vc.webservice = webservice
        //vc.session = session
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
        
        // former times: alertView instead of vc
        return (progressView!, vc)
    }
    
    
    func infromUserAboutWebserviceFailure(webservicestatus: WebServiceStatus) {

            var reasonString: String? = nil
            
            switch webservicestatus {
            case .systemCancelled:
                reasonString = "Wir können leider unsere Server nicht erreichen. Falls du über eine funktionierende Internetverbindung verfügst, liegt das Problem bei uns. Versuche es später bitte erneut."
            case .timeout:
                reasonString = "Deine Internetverbindung ist leider zu langsam. Verbinde dich nach Möglichkeit mit einem schnelleren WLAN oder suche einen besseren Standort auf, um deinen Empfang zu verbessern."
            default:
                break
            }
            
            let alertView = UIAlertController.init(title: "Fehler bei der Internetverbindung", message: reasonString, preferredStyle: .alert)
            alertView.addAction(UIAlertAction.init(title: "Okay", style: .default, handler: { (action) in
                self.session?.startRunning()
            }))
            
            self.present(alertView, animated: true, completion: nil)
    }
}
