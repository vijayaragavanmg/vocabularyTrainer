//
//  AppDelegate.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Setting Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationBarAppearance.barTintColor = UIColor(red: 232.0/255, green: 123.0/255, blue: 20.0/255.0, alpha: 1.0)
        
        
        //Initiate to preload vocabularies
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            CoreDataManager.loadVocabularyData(lessonNumber: 1, completion: { (status,error) in
                if status == true {
                    defaults.set(true, forKey: "isPreloaded")
                }else {
                    Utility.showAlertWithTitle("Error", alertMessage: error?.localizedDescription, dismissButtonsTitle: "Ok", inController: nil, andActions: nil)
                }
            })
            
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        
        let managedObjectContext = CoreDataManager.shared.managedObjectContext
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}

