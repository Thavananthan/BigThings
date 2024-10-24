//
//  BigThingEntity+CoreDataProperties.swift
//  BigThings
//
//  Created by Thavananthan Nanthu on 2024-10-23.
//
//

import Foundation
import CoreData


extension BigThingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BigThingEntity> {
        return NSFetchRequest<BigThingEntity>(entityName: "BigThingEntity")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isVisited: Bool
    @NSManaged public var latitude: String?
    @NSManaged public var location: String?
    @NSManaged public var longitude: String?
    @NSManaged public var name: String?
    @NSManaged public var rating: String?

}

extension BigThingEntity : Identifiable {

}
