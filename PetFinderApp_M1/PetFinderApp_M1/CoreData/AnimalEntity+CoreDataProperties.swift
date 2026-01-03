//
//  AnimalEntity+CoreDataProperties.swift
//  PetFinderApp_M1
//
//  Created by user254923 on 1/3/26.
//
//

import Foundation
import CoreData


extension AnimalEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnimalEntity> {
        return NSFetchRequest<AnimalEntity>(entityName: "AnimalEntity")
    }

    @NSManaged public var age: String?
    @NSManaged public var breed: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var gender: String?
    @NSManaged public var id: Int64
    @NSManaged public var isFollowing: Bool
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var photoURLs: String?
    @NSManaged public var savedDate: Date?
    @NSManaged public var species: String?

}

extension AnimalEntity : Identifiable {

}
