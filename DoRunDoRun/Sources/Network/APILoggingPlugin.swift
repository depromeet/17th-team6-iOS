//
//  APILoggingPlugin.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/31/25.
//


import Moya
import Foundation

final class APILoggingPlugin: PluginType {
    /// API를 보내기 직전에 호출
    func willSend(_ request: RequestType, target: TargetType) {

        let headers = request.request?.allHTTPHeaderFields ?? [:]
        let url = request.request?.url?.host ?? "domain nil"
        let path = request.request?.url?.path ?? "path nil"
        let fullURL = request.request?.url?.absoluteString ?? "fullURL nil"

        let bodyString: String = if let body = request.request?.httpBody {
            String(bytes: body, encoding: String.Encoding.utf8) ?? "nil"
        } else {
            "nil"
        }

        print(
      """
      url: \(fullURL)
      headers: \(headers)
      body: \(bodyString)
      """
        )
    }

    /// API Response
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        var response: Response?
        var error: MoyaError?
        switch result {
            case .success(let moyaResponse):
                response = moyaResponse
            case .failure(let moyaError):
                response = moyaError.response
                error = moyaError
        }

        let request = response?.request
        let url = request?.url?.absoluteString ?? "nil"
        let method = request?.httpMethod ?? "nil"
        let statusCode = response?.statusCode ?? 0
        var bodyString = "nil"
        if let data = request?.httpBody, let string = String(bytes: data, encoding: String.Encoding.utf8) {
            bodyString = string
        }
        var responseString = "nil"
        if let data = response?.data, let reString = String(bytes: data, encoding: String.Encoding.utf8) {
            responseString = reString
        }

        let logMessage = """
                        <didReceive - \(method) statusCode: \(statusCode)>
                        url: \(url)
                        body: \(bodyString)
                        error: \(error?.localizedDescription ?? "nil")
                        response: \(responseString)
                        """
        
        switch result {
            case .success:
                print("SUCCESS" + logMessage)
            case .failure:
                print("FAIL" + logMessage)
        }
    }
}
