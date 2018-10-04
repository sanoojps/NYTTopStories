//
//  NYTAPIConstants.swift
//  NYTTopStories
//
//  Created by Sanooj on 03/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import Foundation

extension NetworkInteractionsManager  {
    
    struct NYTAPI: URLEndPointsInterface {
        
        private init() {}
        
        /**
         * https://api.nytimes.com/svc/topstories/v2/home.json?api-key=e04d485b35f24b938d89d39784680cea
         
         */
        
        enum Sections: String {
            case home
            case opinion
            case world
            case national
            case politics
            case upshot
            case nyregion
            case business
            case technology
            case science
            case health
            case sports
            case arts
            case books
            case movies
            case theater
            case sundayreview
            case fashion
            case tmagazine
            case food
            case travel
            case magazine
            case realestate
            case automobiles
            case obituaries
            case sinsider
        }
        
        enum Formats: String {
            case json
            case jsonp
        }
        
        var baseURL: String
        {
           return "https://api.nytimes.com"
        }
        
        var apiVersion: String?
        {
            return "v2"
        }
        
        var apiKey: String? {
            return  "e04d485b35f24b938d89d39784680cea"
        }
        
        var endpointPaths: [String] {
            return [
                "svc",
                "topstories",
                "v2"
            ]
        }
        
    }
    
}
