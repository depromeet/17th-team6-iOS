//
//  NetworkService.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 10/31/25.
//



import Foundation
import Moya

struct NetworkService {
    private let provider: CustomProvider
    let decoder: JSONDecoder
    init(type: CustomProvider.ProviderType = .live, decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.provider = CustomProvider(type: type, timeoutInterval: 60)
    }

    func request<T: Decodable>(target: TargetType) async throws -> T {
        let result = await provider.request(MultiTarget(target))
        try _Concurrency.Task.checkCancellation()
        switch result {
            case .success(let response):
                guard let parsed = try? decoder.decode(T.self, from: response.data) else { throw NetworkError.parsing }
                return parsed
            case .failure(let error):
                throw NetworkError.moya(error)
        }
    }
}

final class CustomProvider: MoyaProvider<MultiTarget> {
    enum ProviderType {
        case live
        case stubbing
    }

    convenience init(type: ProviderType = .live, plugins: [PluginType] = [], timeoutInterval: TimeInterval) {
        let stubClosure: MoyaProvider<MultiTarget>.StubClosure
        switch type {
            case .live:
                stubClosure = MoyaProvider.neverStub
            case .stubbing:
                stubClosure = MoyaProvider.immediatelyStub
        }

        let requestClosure = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = timeoutInterval
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }

        var unionPlugins: [PluginType] = [APILoggingPlugin()]
        unionPlugins.append(contentsOf: plugins)

        self.init(endpointClosure: MoyaProvider.defaultEndpointMapping,
                  requestClosure: requestClosure,
                  stubClosure: stubClosure,
                  callbackQueue: nil,
                  session: Session(configuration: URLSessionConfiguration.default),
                  plugins: unionPlugins,
                  trackInflights: false)
    }

    func request(_ target: Target) async -> Result<Response, MoyaError> {
        await withCheckedContinuation { continuation in
            self.request(target) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

enum NetworkError: Error {
    case parsing
    case moya(MoyaError)
}
