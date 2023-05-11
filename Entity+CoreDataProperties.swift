//
//  Entity+CoreDataProperties.swift
//  Diary
//
//  Created by 박소연 on 2023/05/11.
//
//

import Foundation
import CoreData

extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var body: String?
    @NSManaged public var date: Double
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var iconName: String?

}

extension Entity: Identifiable {

}
