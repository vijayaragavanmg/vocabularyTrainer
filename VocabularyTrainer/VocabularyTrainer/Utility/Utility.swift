//
//  Utility.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit

class Utility:NSObject {
    
    class func showAlertWithTitle(_ title: String?, alertMessage message: String?, dismissButtonsTitle dismissTitle: String?, preferredStyle:UIAlertControllerStyle = .alert, inController controller: UIViewController?, andActions actions: [UIAlertAction]?) {
        
        let alertController = VTUIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if let alertActions = actions {
            for action in alertActions {
                alertController.addAction(action)
            }
        }
        
        if let dismissTitle = dismissTitle {
            let alertOkayAction = UIAlertAction(title: dismissTitle, style: .default) {
                (action) -> Void in
                
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(alertOkayAction)
        }
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    class VTUIAlertController: UIAlertController {
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            
            //set this to whatever color you like...
            self.view.tintColor = UIColor(red: 251/255, green: 127/255, blue: 29/255, alpha: 1.0)
        }
    }
}
