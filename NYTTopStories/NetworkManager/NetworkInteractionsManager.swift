//
//  NetworkInteractionsManager.swift
//  MVPDemo
//
//  Created by Sanooj on 22/09/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import Foundation
enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}



protocol URLBuilderInterface {
    
    var pathComponents: [String] {get}
    var queries: [URLQueryItem] {get}
    var baseUrl: String {get}
    var percentEncodedUrl: String {get}
    var url: URL? {get}
    
    func baseUrl(_ baseUrl:String) -> Self
    func addQueries(_ queries:[String:String]) -> Self
    func addPathComponents(_ componets: [String]) -> Self
    func applyPercentEncoding() -> Self
    func build() -> URL?
    
}

protocol URLRequestBuilderInterface {
    
    var httpMethod: String {get}
    var httpBody: Data? {get}
    var allHTTPHeaderFields: [String:String] {get}
    var requestUrl: URL? {get}
    
    func requestUrl(_ requestUrl:URL) -> Self
    func requestType(_ httpMethod:String) -> Self
    func addBody(_ httpBody:Data?) -> Self
    func addHTTPHeaderFields(_ httpHeaderFields: [String:String]) -> Self
    func build() -> URLRequest?
    
}

protocol URLEndPointsInterface {
    var baseURL: String {get}
    var apiVersion: String? {get}
    var apiKey: String? {get}
    var endpointPaths: [String] {get}
}

class NetworkInteractionsManager {

    class URLBuilder: URLBuilderInterface {
        private(set) var pathComponents: [String] = []
        private(set) var queries: [URLQueryItem] = []
        private(set) var baseUrl: String = ""
        private(set) var percentEncodedUrl: String = ""
        private(set) var url: URL? = nil
    }
    
    class URLRequestBuilder: URLRequestBuilderInterface {
        private(set) var requestUrl: URL? = nil
        private(set) var httpMethod: String = HTTPMethod.get.rawValue
        private(set) var httpBody: Data?
        private(set) var allHTTPHeaderFields: [String:String] = [:]
    }
    
    class URLSessionBuilder: URLSessionBuliderInterface {

        typealias TaskCompletionHandler = (Data?, URLResponse?, Error?) -> Void
        
        private(set) var session: URLSession =
            URLSession.shared
        
        private(set) var sessionConfig: URLSessionConfiguration =
            URLSessionConfiguration.default
        
        private(set) var tasks :
            [URLSessionTask] = []
        
        private(set) var response: URLResponse?
        
        private(set) var error: Error?
        
        private(set) var data: Data?
        
    }
    
    let urlBuilder: URLBuilder
    let urlRequestBuilder: URLRequestBuilder
    let urlSessionBuilder: URLSessionBuilder
    let urlEndPointsInterface: URLEndPointsInterface?
    init(_ urlEndPointsInterface:URLEndPointsInterface?=nil) {
        self.urlBuilder = URLBuilder()
        self.urlRequestBuilder = URLRequestBuilder()
        self.urlSessionBuilder = URLSessionBuilder()
        self.urlEndPointsInterface = urlEndPointsInterface
    }
    
}

//MARK: URLBuilderInterface
extension NetworkInteractionsManager.URLBuilder
{
    func baseUrl(_ baseUrl:String) -> Self {
        self.baseUrl = baseUrl
        return self
    }
    
    func addQueries(_ queries: [String:String]) -> Self {
        
        let queryItems: [URLQueryItem] =
            queries.map { (pair:(key: String, value: String)) -> URLQueryItem in
                return URLQueryItem(name: pair.key, value: pair.value)
        }
        
        self.queries = queryItems
        return self
        
    }
    
    func addPathComponents(_ components: [String]) -> Self {
        self.pathComponents = components
        return self
    }
    
    func applyPercentEncoding() -> Self {
        return self
    }
    
    func build() -> URL? {
        
        guard var urlComponents: URLComponents =
            URLComponents(string: self.baseUrl) else {
                return nil
        }
        
        if self.pathComponents.count > 0 {
            let path: String =
                self.makePath(from: self.pathComponents)
            
            urlComponents.path =
            path
        }
        
        if self.queries.count > 0 {
            urlComponents.queryItems =
                self.queries
        }
      
        let url: URL? =
            urlComponents.url
        
        self.url =
        url
        
        return url
    }
    
    private func makePath(from components: [String]) -> String {
        
        let path =
            components.reduce("/") { (result:String, next:String) -> String in
                return (result as NSString).appendingPathComponent(next)
        }
        
        return path
    }
    
}

extension NetworkInteractionsManager.URLRequestBuilder
{
    func requestUrl(_ requestUrl:URL) -> Self
    {
        self.requestUrl = requestUrl
        return self
    }
    
    func requestType(_ httpMethod:String) -> Self
    {
        self.httpMethod = httpMethod
        return self
    }
    
    func addBody(_ httpBody: Data?) -> Self {
        self.httpBody = httpBody
        return self
    }
    
    func addHTTPHeaderFields(_ httpHeaderFields: [String:String]) -> Self {
        self.allHTTPHeaderFields = httpHeaderFields
        return self
    }
    
    func build() -> URLRequest? {
        
        guard let requestUrl = self.requestUrl else {
            return nil
        }
        
        var urlRequest =
            URLRequest.init(url: requestUrl)
        
        urlRequest.httpMethod =
            self.httpMethod
        
        urlRequest.httpBody =
            self.httpBody
        
        urlRequest.allHTTPHeaderFields =
            self.allHTTPHeaderFields
        
        return urlRequest
    }
    
    
}

enum URLSessionType: String {
    case shared
    case ephemeral
    case background
}

enum URLSessionTaskType: String {
    case data
    case upload
    case download
}

class URLSessionConfigurableTask {

    typealias TaskCompletionHandler =
        NetworkInteractionsManager.URLSessionBuilder.TaskCompletionHandler
    
    private(set) var taskType: URLSessionTaskType
    private(set) var taskRequest: URLRequest
    private(set) var taskData: Data?
    private(set) var taskCompletionHandler: TaskCompletionHandler
    
    init(request: URLRequest)
    {
        self.taskType = .data
        self.taskRequest = request
        self.taskData = nil
        self.taskCompletionHandler = { (data:Data?, urlResponse:URLResponse?, error:Error? ) in }
    }
    
    func taskType(_ type: URLSessionTaskType) -> URLSessionConfigurableTask
    {
        self.taskType = type
        return self
    }

    func addData(_ taskData: Data?) -> URLSessionConfigurableTask
    {
        self.taskData = taskData
        return self
    }
    
    func callBack(_ taskCompletionHandler: @escaping TaskCompletionHandler) -> URLSessionConfigurableTask
    {
        self.taskCompletionHandler = taskCompletionHandler
        return self
    }
    
//    func sample()
//    {
//        URLSessionConfigurableTask
//            .init(request: URLRequest.init(url: URL.init(string: "")!))
//            .taskType(URLSessionTaskType.data)
//            .addData(nil)
//            .callBack { (data:Data?, response:URLResponse?, error:Error?) in
//        }
//    }
}

protocol URLSessionBuliderInterface
{
    var session: URLSession {get}
    var sessionConfig: URLSessionConfiguration {get}
    var tasks: [URLSessionTask] {get}
    var sessionIdentifier: String {get}
    var data: Data? {get}
    var response: URLResponse? {get}
    var error: Error? {get}
    
    func urlSession(_ session: URLSessionType) -> Self
    func addConfiguration(_ sessionConfig: URLSessionConfiguration) -> Self
    func addTasks(_ sessionTasks: [URLSessionConfigurableTask])-> Self
}

//MARK: URLSessionBuliderInterface
extension NetworkInteractionsManager.URLSessionBuilder {
    
    var sessionIdentifier: String {
        return self.session.configuration.identifier ?? ""
    }
    
    func urlSession(_ session: URLSessionType) -> Self {
        switch session
        {
            
        case .ephemeral:
            let sessionConfig = URLSessionConfiguration.ephemeral
            self.session = URLSession.init(configuration: sessionConfig)
            break
            
        case .background:
            let sessionConfig = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
            self.session = URLSession.init(configuration: sessionConfig)
            break
            
        default:
            break
        }
        
        return self
    }
    
    func addConfiguration(_ sessionConfig: URLSessionConfiguration) -> Self {
        self.session = URLSession.init(configuration: sessionConfig)
        return self
    }
    
    func addTasks(_ sessionTasks: [URLSessionConfigurableTask]) -> Self {
    
        sessionTasks.forEach { (sessionTask:URLSessionConfigurableTask) in
            
            switch sessionTask.taskType {
            case .data:
                
                let completionHandler: TaskCompletionHandler =
                {[weak self](data:Data?, response:URLResponse?, error: Error?) -> Void in
                    
                    self?.data = data
                    self?.response = response
                    self?.error = error
                    
                    sessionTask.taskCompletionHandler(data,response,error)
                }
                
                let dataTask: URLSessionDataTask =
                    self.session.dataTask(
                        with: sessionTask.taskRequest, completionHandler: completionHandler)
                
                self.tasks.append(dataTask)
                
                break
                
            case .download:
                
                let completionHandler: TaskCompletionHandler = sessionTask.taskCompletionHandler
                
                let downloadCompletionHandler: (URL?, URLResponse?, Error?) -> Void = {
                    [weak self](url:URL?, response:URLResponse?, error: Error?) -> Void in
                    
                    let data: Data?  = (url != nil) ? (try? Data.init(contentsOf: url!)) : nil
                    
                    self?.data = data
                    self?.response = response
                    self?.error = error
                    
                    completionHandler(data,response,error)
                    
                }
                
                let downloadTask: URLSessionDownloadTask =
                    self.session.downloadTask(
                        with: sessionTask.taskRequest,
                        completionHandler: downloadCompletionHandler
                )
                
                self.tasks.append(downloadTask)
                
                break
                
            case.upload:
                
                let completionHandler: TaskCompletionHandler =
                {[weak self](data:Data?, response:URLResponse?, error: Error?) -> Void in
                    
                    self?.data = data
                    self?.response = response
                    self?.error = error
                    
                    sessionTask.taskCompletionHandler(data,response,error)
                }
                
                let uploadTask: URLSessionUploadTask =
                    self.session.uploadTask(
                        with: sessionTask.taskRequest,
                        from: sessionTask.taskData,
                        completionHandler: completionHandler
                )
                
                self.tasks.append(uploadTask)
                
                break
            }
            
        }
        
        return self
    }
    
    func launch() {
        DispatchQueue.concurrentPerform(iterations: self.tasks.count) { (index:Int) in
            let task: URLSessionTask = self.tasks[index] // since this is mutating
            task.resume()
        }
    }
    
}
