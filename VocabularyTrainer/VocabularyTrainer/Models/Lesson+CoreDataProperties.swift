//
//  Lesson+CoreDataProperties.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan on 6/8/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//
//

import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var level: Int64
    @NSManaged public var german: String?
    @NSManaged public var english: String?
    @NSManaged public var count: Int64

}
