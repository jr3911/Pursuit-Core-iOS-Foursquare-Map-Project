//
//  VenueFetchingService.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/15/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import Foundation

class VenueFetchingService {
    private init() {}
    static let manager = VenueFetchingService()
    
    func getVenues(lat: Double, long: Double, query: String, completionHandler: @escaping (Result<[Venue], AppError>) -> () ){
        //TODO: Change limit after confirmed working
        let urlString = "https://api.foursquare.com/v2/venues/explore?client_id=\(Secrets().clientId)&client_secret=\(Secrets().clientSecret)&v=20191106&limit=5&ll=\(lat),\(long)&query=\(query)"
        
        guard let url = URL(string: urlString)  else {
            completionHandler(.failure(.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
            case .failure:
                completionHandler(.failure(.noDataReceived))
            case .success(let data):
                do {
                    let decodedData = try JSONDecoder().decode(LocationResultsWrapper.self, from: data)
                    if let retrievedVenues = decodedData.response?.groups?.first?.items {
                        completionHandler(.success(retrievedVenues))
                    } else {
                        completionHandler(.failure(.invalidJSONResponse))
                    }
                    
                } catch {
                    completionHandler(.failure(.couldNotParseJSON(rawError: error)))
                }
            }
        }
        
    }
}
