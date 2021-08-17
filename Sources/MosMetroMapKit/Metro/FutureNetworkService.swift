//
//  FutureNetworkService.swift
//  PackageTester
//
//  Created by Кузин Павел on 17.08.2021.
//


import Foundation
import SwiftyJSON

extension Dictionary {
    var queryString: String {
        var output: String = ""
        forEach({ output += "\($0.key)=\($0.value)&"})
        output = String(output.dropLast())
        return output
    }
}


final class FutureNetworkService {

    static let baseURL = "45.89.225.49:9999"
    
    private func saveToken(data: JSON) -> Bool {
        if let token = data["accessToken"].string, let refresh = data["refreshToken"].string {
            if !token.isEmpty && !refresh.isEmpty {
                UserDefaults.standard.setValue(["token": token, "refresh": refresh], forKey: "auth.token")
                UserDefaults.standard.synchronize()
            }
            if let validSeconds = data["validSeconds"].double {

                //LKTokenService.shared.updateTokenAfter(validSeconds)
            }
            return true
        }
        return false
    }

    private func refresh(_ callback: @escaping (Result<Bool,FutureNetworkError>) -> ()) {
        if let tokenData = UserDefaults.standard.object(forKey: "auth.token") as? [String: String], let refreshToken = tokenData["refresh"] {
            let bodyDict = [
                "refreshToken": refreshToken
            ]
            let body = Request.Body(parameters: nil, body: bodyDict)
            let req = Request(httpMethod: .POST, httpProtocol: .HTTPS, contentType: .json, endpoint: .refreshToken, body: body, baseURL: "lk.mosmetro.ru", lastComponent: nil)
            self.request(req, includeHeaders: true, callback: { result in
                switch result {
                case .success(let response):
                    let json = JSON(response.data)
                    let err = FutureNetworkError(statusCode: nil, kind: .refreshFailed, errorDescription: "")
                    self.saveToken(data: json["data"]) ? callback(.success(true)) : callback(.failure(err))
                    return
                case .failure(let err):
                    callback(.failure(err))
                    return
                }

            })
        }
        let error = FutureNetworkError(statusCode: nil, kind: .refreshFailed, errorDescription: "")
        callback(.failure(error))
    }

    func request(_ request: Request, includeHeaders: Bool = false, includeClipHeaders: Bool = false, callback: @escaping (Result<Response,FutureNetworkError>) -> () ) {
        guard var req = request.request() else {
            let errData = FutureNetworkError(statusCode: nil, kind: .requestInit, errorDescription: "Failed to create reqeust")
            callback(.failure(errData))
            return }
        
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            if let error = error {
                let errData = FutureNetworkError(statusCode: nil, kind: .transport, errorDescription: error.localizedDescription)
                callback(.failure(errData))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = FutureNetworkError(statusCode: nil, kind: .invalidJSON, errorDescription: "No http response")
                callback(.failure(error))
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) && !includeClipHeaders {
                var error: FutureNetworkError!
                if let errMessage = JSON(data)["error"]["message"].string {
                    error = FutureNetworkError(statusCode: httpResponse.statusCode, kind: .serverError  , errorDescription: errMessage)
                } else {
                    error = FutureNetworkError(statusCode: httpResponse.statusCode, kind: .serverError  , errorDescription: "Wrong status code")
                }
                
                if includeHeaders {
                    if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                        self.refresh { result in
                            switch result {
                            case .success(_):
                                self.request(request, includeHeaders: true, callback: { result in
                                    switch result {
                                    case .success(let response):
                                        callback(.success(response))
                                        return
                                    case .failure(let err):
                                        callback(.failure(err))
                                        return
                                    }
                                })
                            case .failure(let refreshError):
                                let err = FutureNetworkError(statusCode: nil, kind: .refreshFailed, errorDescription: "Couldnt refresh tokeen")
                                callback(.failure(err))
                            }
                        }
                    }
                }
                
                callback(.failure(error))
                return
            }
            
            guard let _data = data else {
                let error = FutureNetworkError(statusCode: nil, kind: .invalidJSON, errorDescription: "")
                callback(.failure(error))
                return
            }
            
            let finalResponse = Response(data: _data, success: true)
            callback(.success(finalResponse))
        }.resume()
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum HTTPProtocol: String {
    case HTTP   = "http://"
    case HTTPS  = "https://"
}

enum Endpoint: String {
    //case video = "/user/add"
    case api        = "/api"
    case comp       = "tcompmm.ru/app_metro_moscow_api/api.php"
    case quests     = "/quests/v1.0/"
    case empty      = ""
    case schedule   = "/api/schedule-trains/v1.0/"
    case thread     = "/api/schedule-trains/v1.0/thead/"
    case hashes     = "/api/schema/v1.0/hash"
    case schema     = "/api/schema/v1.0/"
    case excursions = "/api/excursions/v1.0"
    case stories    = "/api/stories/v1.0/"
    case notif      = "/api/notifications/v2/"
    case parkingBalance = "/services/parking/accounts/v1/balance"
    case parkingStart = "/services/parking/v1/start"
    case parkingSession = "/services/parking/v1/check"
    case parkingStop = "/services/parking/v1/stop"
    case parkingExtend = "/services/parking/v1/extend"
    case parkingCars = "/services/parking/cars/v1"
    case parkingCreateOrder = "/services/parking/payment/v1/createOrder/"
    case parkingAddBalance = "/services/parking/accounts/v1/payment"
    
    case parkingOrderStatus = "/services/parking/payment/v1/getOrderStatus"
    case applePay = "/services/parking/payment/v1/applePay/"
    case refreshToken = "/api/authorization/v1.0/refresh"

}

struct FutureNetworkError: Error {

    enum ErrorKind {
        case serverError
        case invalidJSON
        case notFound
        case transport
        case refreshFailed
        case requestInit
        case clipError
        case paymentFailed
        case paymentCheckFailed
    }

    let statusCode: Int?
    let kind: ErrorKind
    var errorDescription: String
}

enum HTTPContentType: String {
    case json = "application/json"
    case formData = "multipart/form-data;"
    case urlEncoded = "application/x-www-form-urlencoded"
}
struct Response {
    let data: Any
    let success: Bool
}

struct Request {
    var httpMethod: HTTPMethod = .GET
    var httpProtocol: HTTPProtocol = .HTTPS
    var contentType: HTTPContentType = .json
    var endpoint: Endpoint
    var body: Body?
    var baseURL: String
    var lastComponent: String?
    
    private var url: String {
        return "\(httpProtocol.rawValue)\(baseURL)\(endpoint.rawValue)\(lastComponent ?? "")"
    }
    
    struct Body {
        var parameters: Dictionary<String,Any>?
        var body: Dictionary<String,Any>?
        
        func paramToString() -> String {
            var string = ""
            guard let params = parameters else { return string }
            for key in params.keys {
                let p = params[key]!
                if p is Array<Any> {
                    for value in (p as! Array<Any>) {
                        string += "\(key)=\(value)&"
                    }
                } else {
                    string += "\(key)=\(p)&"
                }
            }
            return string
        }
    }
}

extension Request {
    
    func request() -> URLRequest? {
        var url = self.url
        if let body = self.body {
            if let params = self.body?.parameters {
                url += "?\(params.queryString)"
            }
        }
        
        url = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!.replacingOccurrences(of: "+", with: "%2B")
        guard let _url = URL(string: url) else { return nil }
        print("🚧 MAKING URL REQUEST - \(self.httpMethod.rawValue) \(url)")
        var request = URLRequest(url: _url)
        request.httpMethod = self.httpMethod.rawValue
        if body?.body != nil && self.httpMethod != .GET {
            if contentType == .urlEncoded {
                let postString = body!.body!.queryString
                var str = postString.replacingOccurrences(of: "[", with: "{")
                str = str.replacingOccurrences(of: "]", with: "}")
                
                request.httpBody = str.data(using: .utf8)
                request.addValue(self.contentType.rawValue, forHTTPHeaderField: "Content-Type")
            } else {
                request.addValue(self.contentType.rawValue, forHTTPHeaderField: "Content-Type")
                request.httpBody = try! JSONSerialization.data(withJSONObject: body!.body!, options: [])
                print("REQUEST BODY - \(JSON(request.httpBody))")
            }
        }
        return request
    }
}

