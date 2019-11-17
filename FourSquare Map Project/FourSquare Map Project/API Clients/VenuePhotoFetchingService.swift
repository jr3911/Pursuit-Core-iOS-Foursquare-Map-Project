//
//  VenuePhotoFetchingService.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/17/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import Foundation
import UIKit

class VenuePhotoFetchingService {
    private init() {}
    static let manager = VenuePhotoFetchingService()
    
    func getVenuePhoto(venueID: String, completionHandler: @escaping (Result<UIImage, AppError>) -> () ) {
        
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/\(venueID)/photos?client_id=\(Secrets().clientId)&client_secret=\(Secrets().clientSecret)&v=20191106") else {
            completionHandler(.failure(.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
            case .failure:
                completionHandler(.failure(.noDataReceived))
            case .success(let data):
                do {
                    let venuePhotoInfo = try JSONDecoder().decode(VenuePhotoResponseWrapper.self, from: data)
                    guard let photoURLPrefix = venuePhotoInfo.response.photos.items.first?.prefix, let photoURLSuffix = venuePhotoInfo.response.photos.items.first?.suffix else {
                        completionHandler(.failure(.invalidJSONResponse))
                        return
                    }
                    
                    guard let url = URL(string: photoURLPrefix + "100x100" + photoURLSuffix) else {
                        completionHandler(.failure(.badURL))
                        return
                    }
                    ImageHelper.shared.getImage(url: url) { (result) in
                        switch result {
                        case .failure:
                            completionHandler(.failure(.notAnImage))
                        case .success(let venueImage):
                            completionHandler(.success(venueImage))
                        }
                    }
                    
                } catch {
                    completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        }
        
    }
}
