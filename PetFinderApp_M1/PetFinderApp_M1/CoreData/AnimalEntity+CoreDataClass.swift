//
//  AnimalEntity+CoreDataClass.swift
//  PetFinderApp_M1
//
//  Created by user254923 on 1/3/26.
//
//

import Foundation
import CoreData

@objc(AnimalEntity)
public class AnimalEntity: NSManagedObject {
    var imageURL: URL? {
            	
            guard let urlString = self.photoURLs, !urlString.isEmpty else {
                return nil
            }
            return URL(string: urlString)
        }
        
        
        var locationString: String {
            return self.location ?? "Localização desconhecida"
        }
}
