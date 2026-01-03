//
//  AnimalData.swift
//  PetFinderApp_M1
//
//  Created by user254923 on 1/3/26.
//


import Foundation

struct APIResponse: Codable {
    let status: String?
    let pets: [APIAnimal]?
}


struct APIAnimal: Codable {
    let pet_id: String?
    let pet_name: String?
    let sex: String?
    let age: String?
    let size: String?
    let primary_breed: String?
    let addr_city: String?
    let addr_state_code: String?
    
    
    let results_photo_url: String?
    let large_results_photo_url: String?
    
    
    let description: String?
}

