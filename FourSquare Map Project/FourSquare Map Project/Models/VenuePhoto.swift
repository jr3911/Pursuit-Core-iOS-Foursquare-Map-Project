//
//  VenuePhoto.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/17/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import Foundation

struct VenuePhotoResponseWrapper: Codable {
    let response: PhotoWrapper
}

struct PhotoWrapper: Codable {
    let photos: ItemWrapper
}

struct ItemWrapper: Codable {
    let items: [VenuePhoto]
}

struct VenuePhoto: Codable {
    let prefix: String
    let suffix: String
}
