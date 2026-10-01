//
//  APIManager.swift
//  FPLTeamViewer
//
//  Created by Vivek Sadariya on 01/10/26.
//
import Foundation

protocol EndPointType {
    var baseURL: String { get }
    var path: String { get }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
}

protocol APIService {
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T
    /// Last successful response saved for `endpoint`, or `nil` if there is none.
    func cachedResponse<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) -> T?
}

final class APIManager: APIService {
    
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 300
        return URLSession(configuration: configuration)
    }
    
    private func getAPIUrl(endpoint: APIEndpoint) -> URL? {
        var url: URL?
        url = URL(string: endpoint.baseURL + endpoint.path)
        return url
    }
    
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let url = getAPIUrl(endpoint: endpoint) else {
            throw NetworkError.invalidURL
        }
       
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
       
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
           throw NetworkError.invalidResponse
        }
       
        guard (200...299).contains(httpResponse.statusCode) else {
           throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
       
        let decoded: T
        do {
           decoded = try JSONDecoder().decode(T.self, from: data)
       } catch {
           throw NetworkError.decodingError(error)
       }

        // Save only data that decoded successfully, so the cache is always usable.
        if let cacheURL = cacheFileURL(for: endpoint) {
            try? data.write(to: cacheURL, options: .atomic)
        }
        return decoded
    }

    func cachedResponse<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) -> T? {
        guard let cacheURL = cacheFileURL(for: endpoint),
              let data = try? Data(contentsOf: cacheURL) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func cacheFileURL(for endpoint: APIEndpoint) -> URL? {
        FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("\(endpoint).json")
    }
}

final class MockAPIManager: APIService {
    var isCaching: Bool = false
    var isThrowError: Bool = false
    
    init(isCaching: Bool, isThrowError: Bool) {
        self.isCaching = isCaching
        self.isThrowError = isThrowError
    }
    
    private func getAPIUrl(endpoint: APIEndpoint) -> URL? {
        var url: URL?
        url = URL(string: endpoint.baseURL + endpoint.path)
        return url
    }
    
    func request<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let url = getAPIUrl(endpoint: endpoint) else {
            throw NetworkError.invalidURL
        }
       
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
       
        guard let url = Bundle.main.url(forResource: "response", withExtension: "json") else {
            throw NetworkError.invalidURL
        }
       
        if isThrowError {
           throw NetworkError.httpError(statusCode: 250)
        }
       
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    func cachedResponse<T: Decodable>(endpoint: APIEndpoint, responseType: T.Type) -> T? {
        guard isCaching,
              let url = Bundle.main.url(forResource: "response", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
