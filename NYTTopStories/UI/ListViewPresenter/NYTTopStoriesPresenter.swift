//
//  NYTTopStoriesPresenter.swift
//  NYTTopStories
//
//  Created by Sanooj on 04/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import Foundation

protocol NYTTopStoriesPresenterViewBaseInterface:class
{
    
}

protocol NYTTopStoriesPresenterViewInterface: NYTTopStoriesPresenterViewBaseInterface
{
    func topStoriesList(_ stories:[NYTTopStoriesListViewModel]?,
                    forSection sectionName: String,
                    withError error: NYTTopStoriesPresenter.Errors?)
    
}

struct NYTTopStoriesListViewModel
{
    let thumbnailImage: String
    let subsection: String
    let largeImage: String
    let title: String
    let abstractDescription: String
    let author: String
    let seeMoreLinkUrl: String
}

protocol NYTTopStoriesPresenterBaseInterface
{
    func attachPresenterView(_ presenterView: NYTTopStoriesPresenterViewBaseInterface)
    func detachPresenterView()
}

protocol NYTTopStoriesPresenterInterface: NYTTopStoriesPresenterBaseInterface
{
    func initiateTopStoriesFetchForSection(
    _ sectionName: NetworkInteractionsManager.NYTAPI.Sections)
}

class  NYTTopStoriesPresenter: NYTTopStoriesPresenterInterface {
    
    enum Errors: Error
    {
        case invalidURL
        case requestFailed
        case jsonParsingFailed
        
    }
    
    func attachPresenterView(_ presenterView: NYTTopStoriesPresenterViewBaseInterface) {
        self.presenterView = presenterView as? NYTTopStoriesPresenterViewInterface
    }
    
    func detachPresenterView() {
        self.presenterView = nil
    }

    let networkManager = NetworkInteractionsManager()
    
    weak var presenterView : NYTTopStoriesPresenterViewInterface?
    
    func initiateTopStoriesFetchForSection(
        _ sectionName: NetworkInteractionsManager.NYTAPI.Sections = .home
        )
    {
        //call WS
        
        let format: String =
            sectionName.rawValue +
                "." +
                NetworkInteractionsManager.NYTAPI.Formats.json.rawValue
        
        let finalURL =
            networkManager.urlBuilder
                .baseUrl("https://api.nytimes.com")
                .addPathComponents(
                    [
                        "svc",
                        "topstories",
                        "v2",
                        format
                        ]
                )
                .addQueries([
                    "api-key" : "e04d485b35f24b938d89d39784680cea",
                    ])
                .build()
        
        guard let url = finalURL else
        {
            presenterView?.topStoriesList(
                nil,
                forSection: sectionName.rawValue,
                withError: NYTTopStoriesPresenter.Errors.invalidURL)
            
            return
        }
        
        let urlRequest: URLRequest! =
            networkManager.urlRequestBuilder
                .requestUrl(url)
                .requestType(HTTPMethod.get.rawValue)
                .build()
        
        networkManager.urlSessionBuilder
            .urlSession(URLSessionType.shared)
            .addConfiguration(URLSessionConfiguration.default)
            .addTasks([
                URLSessionConfigurableTask
                    .init(request: urlRequest!)
                    .taskType(URLSessionTaskType.data)
                    .callBack({ (data:Data?, response:URLResponse?, error:Error?) in
                        
                    
                        self.handleTopStoriesForSection(
                            sectionName,
                            fetchResponse: response,
                            data: data,
                            error: error
                        )
                        
                        
                    })
                ])
            .launch()
    }
    
    func handleTopStoriesForSection(
        _ sectionName: NetworkInteractionsManager.NYTAPI.Sections,
        fetchResponse response:URLResponse?,
        data:Data?,
        error:Error?
        )
    {
        // parse JSON
        guard let jsonData = data else {
            presenterView?.topStoriesList(
                nil,
                forSection: sectionName.rawValue,
                withError: NYTTopStoriesPresenter.Errors.requestFailed
            )
            return 
        }
        
        guard let  nYTTopStories =
            try? JSONDecoder().decode(NYTTopStories.self, from: jsonData)
            else
        {
            presenterView?.topStoriesList(
                nil,
                forSection: sectionName.rawValue,
                withError: NYTTopStoriesPresenter.Errors.jsonParsingFailed
            )
            return
        }
        
        //print(nYTTopStories as Any)
        
        /// make viewModel class
        let topStoriesViewModels =
        self.makeViewModelFromTopStories(nYTTopStories)
        
        //send to View controller
        presenterView?.topStoriesList(
            topStoriesViewModels,
            forSection: sectionName.rawValue,
            withError: nil
        )
    }
    
    fileprivate func getLargeThumbnailImageUrl(_ result: (Result)) -> String {
        return result.multimedia.lazy.filter({ (multimedia:Multimedia) -> Bool in
            return multimedia.format == .thumbLarge
        }).first?.url ?? ""
    }
    
    fileprivate func getLargeImageUrl(_ result: (Result)) -> String {
        return result.multimedia.lazy.filter({ (multimedia:Multimedia) -> Bool in
            return multimedia.format == .mediumThreeByTwo210
        }).first?.url ?? ""
    }
    
    fileprivate func getImageUrl(
        _ result: (Result),
        types: Set<Format> = [.mediumThreeByTwo210,.thumbLarge]) ->
        [String:String]
    {
        var urlsMap: [String: String] = [:]
        
        result.multimedia.lazy.forEach { (multimedia:Multimedia) in
            if types.contains(multimedia.format) {
                urlsMap[multimedia.format.rawValue] = multimedia.url
            }
        }
        
        return urlsMap
    }
    
    
    fileprivate func makeViewModelFromTopStories(_ topStories: NYTTopStories) -> [NYTTopStoriesListViewModel]
    {
        let viewModels: [NYTTopStoriesListViewModel] =
            topStories.results.map { (result:Result) -> NYTTopStoriesListViewModel in
                
                let thumbnailImage =
                    getLargeThumbnailImageUrl(result)
                
                let subsection =
                result.subsection
                
                let largeImage =
                    getLargeImageUrl(result)
                
                let title =
                result.title
                
                let abstractDescription =
                result.abstract
                
                let author =
                result.byline
                
                let seeMoreLinkUrl =
                result.url
                
                return NYTTopStoriesListViewModel.init(
                    thumbnailImage: thumbnailImage,
                    subsection: subsection,
                    largeImage: largeImage,
                    title: title,
                    abstractDescription: abstractDescription,
                    author: author,
                    seeMoreLinkUrl: seeMoreLinkUrl
                )
                
        }
        
        return viewModels
    }
    
}
