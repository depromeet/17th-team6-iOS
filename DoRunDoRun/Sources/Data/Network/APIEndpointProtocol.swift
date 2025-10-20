//
//  APIEndpointProtocol.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 10/17/25.
//

import Alamofire

protocol APIEndpointProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}
