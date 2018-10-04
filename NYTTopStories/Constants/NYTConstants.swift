//
//  NYTConstants.swift
//  NYTTopStories
//
//  Created by Sanooj on 04/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import Foundation
import UIKit.UIImage
import SafariServices

protocol CQClassIdentifier
{
    static var identifier:String {get}
}

extension CQClassIdentifier
{
    private static var className: String
    {
        return String.init(describing: self)
    }
    
    static var identifier: String
    {
        return self.className + "ID"
    }
    
    static var trimmedIdentifier: String
    {
        return self.className
    }
}

struct NYTConstants
{
    static let imageCache: NSCache<NSString,UIImage> = NSCache.init()
    
    static let nytPlaceHolderImage: UIImage? =
    UIImage.init(named: "NYTPlaceholder.png")
    
    fileprivate static func downloadImage(
        imageUrl: String,
        completionHandler:@escaping ((UIImage?)->())
        )
    {
        
        // download image
        let networkManager =
            NetworkInteractionsManager()
        
        guard let url: URL =
            networkManager.urlBuilder
                .baseUrl(imageUrl)
                .build()
            else
        {
            completionHandler(nil)
            return
        }
        
        guard let request: URLRequest =
            networkManager.urlRequestBuilder
                .requestType(HTTPMethod.get.rawValue)
                .requestUrl(url)
                .build()
            else
        {
            completionHandler(nil)
            return
        }
        
        networkManager.urlSessionBuilder
            .addTasks([
                URLSessionConfigurableTask
                    .init(request: request)
                    .callBack({ (imageData:Data?, response:URLResponse?, error:Error?) in
                        
                        guard let data = imageData,
                            let image = UIImage.init(data: data) else {
                                completionHandler(nil)
                                return
                        }
                        
                        completionHandler(image)
                        
                    })
                ]
            )
            .launch()
    }
    
    
    static func assignImageFromUrl(_ imageUrl:String, toView imageView:UIImageView)
    {
        // check in cache
        if let image = self.imageCache.object(forKey: imageUrl as NSString) {
            DispatchQueue.main.async {
                imageView.image =
                image
            }
        }
        else
        {
            // if not assign placeholder
            DispatchQueue.main.async {
                imageView.image =
                    self.nytPlaceHolderImage
            }
            
            downloadImage(imageUrl: imageUrl) { (image:UIImage?) in
                
                guard let image = image else {
                    return
                }
                
                // add to cache
                self.imageCache.setObject(
                    image,
                    forKey: imageUrl as NSString
                )
                
                // assign image
                DispatchQueue.main.async {
                    imageView.image =
                    image
                }
                
            } //completion
        }
    }
}


extension NYTConstants
{
    private static let activityIndicator: UIActivityIndicatorView =
    {
        let activityView =
        UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.whiteLarge)
        
        activityView.color =
        UIColor.gray

        return activityView
        
    }()

    private static let activityContainerView: UIView =
    {
        let activityContainerView = UIView()
        
        activityContainerView.backgroundColor =
           UIColor.init(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        
        activityContainerView.layer.cornerRadius =
        10.0
        
        return activityContainerView
        
    }()

    static func showActivityIndicatorOnView(_ parentView: UIView)
    {
        
        parentView.addSubview(self.activityContainerView)
        
        self.activityContainerView.translatesAutoresizingMaskIntoConstraints =
        false
        
        self.activityContainerView.centerXAnchor.constraint(
            equalTo: parentView.centerXAnchor
            ).isActive = true
        
        self.activityContainerView.centerYAnchor.constraint(
            equalTo: parentView.centerYAnchor
            ).isActive = true
        
        self.activityContainerView.heightAnchor.constraint(
            equalToConstant: 88.0
            ).isActive = true
        
        self.activityContainerView.widthAnchor.constraint(
            equalToConstant: 88.0
            ).isActive = true
        
        self.activityContainerView.addSubview(self.activityIndicator)
        
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints =
            false
        
        self.activityIndicator.centerXAnchor.constraint(
            equalTo: self.activityContainerView.centerXAnchor
            ).isActive = true
        
        self.activityIndicator.centerYAnchor.constraint(
            equalTo: self.activityContainerView.centerYAnchor
            ).isActive = true

        self.activityIndicator.heightAnchor.constraint(
            equalToConstant: 44.0
            ).isActive = true
        
        self.activityIndicator.widthAnchor.constraint(
            equalToConstant: 44.0
            ).isActive = true
        
        self.activityIndicator.startAnimating()
    }
    
    static func hideActivityIndicatorOnView()
    {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        self.activityContainerView.removeFromSuperview()
    }
}

extension NYTConstants
{
    struct StoryBoards {
        private init() {}
        
        struct NYTList {
        private init() {}
            static let name: String = "Main"
            static let listViewID = NYTTopStoriesListTableViewController.identifier
            static let detailsViewID = NYTTopStoriesListDetailsViewController.identifier
        }
        
        
        
    }
}

extension NYTConstants {
    
    static func launchSafari(withUrl url: URL ,usingPresenter controller: UIViewController) {
        let safari = SFSafariViewController.init(url: url)
        controller.present(safari, animated: true, completion: nil)
    }
    
}
