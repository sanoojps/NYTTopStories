//
//  NYTTopStoriesListTableViewController.swift
//  NYTTopStories
//
//  Created by Sanooj on 04/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import UIKit

class NYTTopStoriesListTableViewController: UITableViewController {

    var presenter: NYTTopStoriesPresenterInterface?
    
    var viewModels: [NYTTopStoriesListViewModel] = []
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //create and attach to presenter
        presenter = NYTTopStoriesPresenter()
        presenter?.attachPresenterView(self)
        
        //activity
        NYTConstants.showActivityIndicatorOnView(self.tableView)
        
        // initiate
        presenter?.initiateTopStoriesFetchForSection(
            NetworkInteractionsManager.NYTAPI.Sections.home
        )
        
        self.title = "Top Stories" + " - " +  NetworkInteractionsManager.NYTAPI.Sections.home.rawValue
    }
    
    deinit {
        self.presenter?.detachPresenterView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView?.setNeedsDisplay()
        self.tableView?.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: NYTTopStoriesListTableViewCell =
            tableView.dequeueReusableCell(
                withIdentifier: NYTTopStoriesListTableViewCell.identifier,
                for: indexPath) as? NYTTopStoriesListTableViewCell else {
                    return UITableViewCell()
        }

        let viewModel:NYTTopStoriesListViewModel = self.viewModels[indexPath.row]
        let cellViewModel: NYTTopStoriesListTableViewCellViewModel =
            NYTTopStoriesListTableViewCellViewModel.init(
                title: viewModel.title,
                author: viewModel.author,
                thumbNailImage: viewModel.thumbnailImage
        )
        
        // Configure the cell...
        cell.configure(
            cell: cell,
            withModel: cellViewModel
        )

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel:NYTTopStoriesListViewModel = self.viewModels[indexPath.row]
        let detailsViewModel: NYTTopStoriesListDetailsViewViewModel =
            NYTTopStoriesListDetailsViewViewModel.init(
                subsection: viewModel.subsection,
                title: viewModel.title,
                largeImage: viewModel.largeImage,
                abstractDescription: viewModel.abstractDescription,
                author: viewModel.author,
                seeMoreUrl: viewModel.seeMoreLinkUrl
        )
        
        guard let storyBoard = self.storyboard else {
            return
        }
        
        guard let  detailsView =
            storyBoard.instantiateViewController(
                withIdentifier: NYTConstants.StoryBoards.NYTList.detailsViewID
        ) as? NYTTopStoriesListDetailsViewController else
        {
            return
        }
        
        detailsView.viewModel =
        detailsViewModel
        
        self.navigationController?.pushViewController(detailsView, animated: true)
    }
 
}

extension NYTTopStoriesListTableViewController : NYTTopStoriesPresenterViewInterface
{
    func topStoriesList(_ stories: [NYTTopStoriesListViewModel]?, forSection sectionName: String, withError error: NYTTopStoriesPresenter.Errors?) {
        
        if let stories = stories {
            self.viewModels =
            stories
            
            let indexpaths: [IndexPath] =
                self.viewModels.lazy.indices.map { (index:Int) -> IndexPath in
                    return IndexPath.init(row: index, section: 0)
            }
            
            DispatchQueue.main.async {
                NYTConstants.hideActivityIndicatorOnView()
            }
            
            DispatchQueue.main.async {
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: indexpaths, with: UITableView.RowAnimation.automatic)
                self.tableView?.endUpdates()
            }
            
        }
        
       self.handleError(error)
        
    }
    
    
    fileprivate func handleError(_ error: NYTTopStoriesPresenter.Errors?)
    {
        guard let error = error else {
            return
        }
        
        switch error {
            
        case .invalidURL  :
            NYTConstants.presentAnAlert(
                title: NYTConstants.LocalizableKeys.invalidURLAlertTitle.localized,
                message: nil,
                presenter: self
            )
            break
            
        case .jsonParsingFailed:
            NYTConstants.presentAnAlert(
                title: NYTConstants.LocalizableKeys.jsonParsingFailureAlertTitle.localized,
                message: nil,
                presenter: self
            )
            break
            
        case .requestFailed:
            NYTConstants.presentAnAlert(
                title: NYTConstants.LocalizableKeys.networkRequestFailureAlertTitle.localized,
                message: nil,
                presenter: self
            )
            break
            
        }
    }
    

}

extension NYTTopStoriesListTableViewController: CQClassIdentifier {}
