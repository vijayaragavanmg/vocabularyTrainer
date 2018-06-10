//
//  Utility.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import UIKit
import CoreData

private struct Constants {
    
    static let coreDataFile             = "VocabularyTrainer"
    static let coreDataFileExtension    = "momd"
    static let sqlLiteFile              = "VocabularyTrainer.sqlite"
    static let localCSVFile             = "vocabulary"
    static let `extension`              = "csv"
    static let remoceCSVFileUrl         = "https://s3.us-east-2.amazonaws.com/vocabularytrainer/vocabulary"
    static let entityName               = "Lesson"
    
}


class CoreDataManager: NSObject {
    
    static let shared : CoreDataManager = {
        let instance = CoreDataManager()
        return instance
    }()
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: Constants.coreDataFile, withExtension: Constants.coreDataFileExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(Constants.sqlLiteFile)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.vocabularyTrainer", code: 4357, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // Load the CSV file and parse it
    class func parseCSV (contentsOfURL: URL, encoding: String.Encoding,completion: @escaping (_ status: Bool, _ error:NSError?,[(german:String, english:String, count: String)]?) -> ()) {
        
        let delimiter = ";"
        var items:[(german:String, english:String, count: String)]?
        
        do  {
            let content = try String(contentsOf: contentsOfURL)
            items = []
            
            let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
            
            for line in lines {
                var values:[String] = []
                if line != "" {
                    
                    if line.range(of: "\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:Scanner = Scanner(string: textToScan)
                        while textScanner.string != "" {
                            
                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpTo("\"", into: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpTo(delimiter, into: &value)
                            }
                            
                            if let value = value {
                                values.append(value as String)
                            }
                            
                            if textScanner.scanLocation < textScanner.string.count {
                                textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = Scanner(string: textToScan)
                        }
                        
                    } else  {
                        values = line.components(separatedBy: delimiter)
                    }
                    
                    let item = (german: values[0], english: values[1], count: values[2])
                    items?.append(item)
                }
            }
        }catch {
            let errorDesc = String(format: ErrorDescription.unableToReadRecord, contentsOfURL.absoluteString)
            let error = NSError(domain: errorDomain, code: ErrorType.ErrorUnbleReadRecord.rawValue, userInfo: [NSLocalizedDescriptionKey:errorDesc])
            completion(false, error, nil)
            
        }
        
        completion(true, nil, items)
    }
    
    
    //upload vocabularies to database
    class func loadVocabularyData (lessonNumber:Int, completion: @escaping (_ status: Bool, _ error:NSError?) -> ()) {
        
        // Retrieve data from the source file
        if let contentsOfURL = getSourceFileUrl(lessonNumber: lessonNumber) {
            
            //Remove all the vocabularies before preloading
            removeData()
            
            if lessonNumber > 1 {
                parseCSVFileInBackground(fileUrl: contentsOfURL, lessonNumber: lessonNumber, completion: { (status,error) in
                    completion(status, error)
                })
            }else {
                parseCSVFileInMain(fileUrl: contentsOfURL, lessonNumber: lessonNumber, completion: { (status,error) in
                    completion(status, error)
                })
            }
            
        }else {
            let error = NSError(domain:errorDomain, code: ErrorType.ErrorRetriveRecordFail.rawValue, userInfo: [NSLocalizedDescriptionKey:ErrorDescription.retriveRecordFail])
            completion(false, error)
        }
    }
    
    
    //Parsing CSV File in background thread
    class func parseCSVFileInBackground(fileUrl:URL,lessonNumber:Int, completion: @escaping (_ status: Bool, _ error:NSError?) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            parseCSV(contentsOfURL: fileUrl, encoding: .utf8, completion: { (status, error
                , items) in
                DispatchQueue.main.async {
                    if let items = items, status == true {
                        
                        for (index,item) in items.enumerated() {
                            if index > 0 {
                                
                                let managedObjectContext = CoreDataManager.shared.managedObjectContext
                                let menuItem = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: managedObjectContext) as! Lesson
                                menuItem.german = item.german.trimmingCharacters(in: .whitespacesAndNewlines)
                                menuItem.english = item.english.trimmingCharacters(in: .whitespacesAndNewlines)
                                menuItem.count = Int64((item.count as NSString).integerValue)
                                menuItem.level = Int64(lessonNumber)
                                do{
                                    try managedObjectContext.save()
                                    completion(true, nil)
                                }catch {
                                    completion(false, error as NSError)
                                }
                                
                            }
                        }
                        
                    }else {
                        completion(false, error)
                    }
                }
            })
            
        }
        
    }
    
    
    //Parsing CSV File in main thread
    class func parseCSVFileInMain(fileUrl:URL,lessonNumber:Int, completion: @escaping (_ status: Bool, _ error:NSError?) -> ()) {
        
        parseCSV(contentsOfURL: fileUrl, encoding: .utf8) { (status, error, items) in
            if let items = items,status == true {
                for (index,item) in items.enumerated() {
                    if index > 0 {
                        
                        let managedObjectContext = CoreDataManager.shared.managedObjectContext
                        let menuItem = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: managedObjectContext) as! Lesson
                        menuItem.german = item.german.trimmingCharacters(in: .whitespacesAndNewlines)
                        menuItem.english = item.english.trimmingCharacters(in: .whitespacesAndNewlines)
                        menuItem.count = Int64((item.count as NSString).integerValue)
                        menuItem.level = Int64(lessonNumber)
                        do{
                            try managedObjectContext.save()
                            completion(true, nil)
                        }catch {
                            completion(false, error as NSError)
                        }
                        
                    }
                }
            }else {
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "isPreloaded")
                completion(false, error)
            }
        }
        
    }
    
    
    //Returns csv file url
    class func getSourceFileUrl(lessonNumber:Int) -> URL? {
        
        if let contentsOfURL = Bundle.main.url(forResource: Constants.localCSVFile, withExtension: Constants.extension),lessonNumber == 1 {
            return contentsOfURL
        } else if lessonNumber > 1  {
            let url =  Constants.remoceCSVFileUrl+String(lessonNumber)+"."+Constants.extension
            if  let contentsOfURL = URL(string:url) {
                return contentsOfURL
            }
        }
        
        return nil
    }
    
    
    //Remove the existing items
    class func removeData () {
        // Remove the existing items
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entityName)
        
        let managedObjectContext = CoreDataManager.shared.managedObjectContext
        do {
            
            let menuItems =  try managedObjectContext.fetch(fetchRequest) as! [Lesson]
            for menuItem in menuItems {
                managedObjectContext.delete(menuItem)
            }
        }catch {
            print("Failed to retrieve record:")
        }
        
    }
    
    
    class func isNewLessonRequired(completion: @escaping (_ isRequired: Bool, _ completedLesson:Int) -> ()) {
        
        CoreDataManager.getLesson { (true, error, vocabularies) in
            
            if let vocabularies = vocabularies {
                var isRequred = true
                var level = 0
                for vocabulary in vocabularies {
                    if vocabulary.count < 4 {
                        isRequred = false
                    }
                    level = Int(vocabulary.level)
                }
                
                completion(isRequred, level)
                
            }
        }
        
    }
    
    
    //Retrives all vocabularies
    class func getLesson(completion: @escaping (_ status: Bool, _ error:NSError?, [Lesson]?) -> ()) {
        
        let managedObjectContext = CoreDataManager.shared.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entityName)
        do {
            let vocabularies = try managedObjectContext.fetch(fetchRequest) as! [Lesson]
            completion(true, nil, vocabularies)
        } catch {
            let error = NSError(domain: errorDomain, code: ErrorType.ErrorRetriveRecordFail.rawValue, userInfo: [NSLocalizedDescriptionKey:ErrorDescription.retriveRecordFail])
            completion(false, error, nil)
        }
        
    }
    
    
}
