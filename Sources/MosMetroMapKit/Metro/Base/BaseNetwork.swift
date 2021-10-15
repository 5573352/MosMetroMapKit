//
//  Network.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 21.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreTelephony

enum APIMethod: String {
    case schema        = "https://prodapp.mosmetro.ru/api/schema/v1.0/"
    case emergency     = "https://prodapp.mosmetro.ru/api/notifications/v1.0/"
    case trainWorkload = "https://prodapp.mosmetro.ru/api/stations/v2/"
    case articles      = "https://prodapp.mosmetro.ru/api/news/v1.0"
    case tweets        = "https://prodapp.mosmetro.ru/api/tweets/v1.0/"
    case transferVideo = "https://prodapp.mosmetro.ru/api"
}

enum NetworkError: Error {
    case serverError
    case clientError
    case dataIsInvalid
    case errorParsingJSON
    case timeout
    case dataIsEmpty
}

extension NetworkError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .serverError:
            return NSLocalizedString("Unable to connect to server. Please check your internet connection and try again", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .clientError:
            return NSLocalizedString("Unable to connect to server. Please check your internet connection and try again", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .dataIsInvalid:
            return NSLocalizedString("Oops! Something went wrong", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .errorParsingJSON:
            return NSLocalizedString("Oops! Something went wrong", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .timeout:
            return NSLocalizedString("Oops! Something went wrong", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        case .dataIsEmpty:
            return NSLocalizedString("Data is empty", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        }
    }
}

class NetworkService {
    
    func trainsWorkload(by station: Station, all: [StationDTO], callback: @escaping (Result<TrainWorkload,Error>) -> Void) {
        guard let url = URL(string: "\(APIMethod.trainWorkload.rawValue)\(station.id)/wagons/") else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            if let error = error {
                callback(.failure(error))
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    callback(.failure(NetworkError.serverError))
                    return
            }
            
            guard let _data = data else {
                callback(.failure(NetworkError.dataIsInvalid))
                return
            }
            do {
                
                let json = try JSON(data: _data)
                if json["data"].isEmpty {
                    callback(.failure(NetworkError.dataIsEmpty))
                    return
                }
                guard let workload = TrainWorkload.map(json: json, station: station, all: all) else {
                    callback(.failure(NetworkError.errorParsingJSON))
                    return
                }
                callback(.success(workload))
            } catch {
                callback(.failure(NetworkError.errorParsingJSON))
            }
        }).resume()
    }
}
