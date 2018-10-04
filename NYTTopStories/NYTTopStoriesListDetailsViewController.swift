//
//  NYTTopStoriesListDetailsViewController.swift
//  NYTTopStories
//
//  Created by Sanooj on 04/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import UIKit

protocol NYTTopStoriesListDetailsViewConfigurationInterface {
    
    associatedtype ListDetailsView:UIViewController
    associatedtype ViewModel:NYTTopStoriesListTableViewCellBaseViewModelInterface
    
    func configure(
        view:ListDetailsView ,
        withModel viewModel:ViewModel
    )
}

struct NYTTopStoriesListDetailsViewViewModel:NYTTopStoriesListTableViewCellBaseViewModelInterface {
    let subsection: String
    let title: String
    let largeImage: String
    let abstractDescription: String
    let author: String
    let seeMoreUrl: String
}


class NYTTopStoriesListDetailsViewController: UIViewController {

    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    
    var viewModel: NYTTopStoriesListDetailsViewViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let viewModel = viewModel else {
            return
        }
        
        self.configure(
            view: self,
            withModel: viewModel
        )
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onSeeMoreButtonTapped(_ sender: UIButton) {
    }
    
}


extension NYTTopStoriesListDetailsViewController: NYTTopStoriesListDetailsViewConfigurationInterface
{
    typealias ListDetailsView = NYTTopStoriesListDetailsViewController
    
    typealias ViewModel = NYTTopStoriesListDetailsViewViewModel
    
    func configure(
        view:ListDetailsView ,
        withModel viewModel:ViewModel
    )
    {
        self.title =
        viewModel.subsection
        
        NYTConstants.assignImageFromUrl(
            viewModel.largeImage,
            toView: self.largeImageView
        )
        
        self.titleLabel.text =
        viewModel.title
        
        self.descriptionLabel.text =
            viewModel.abstractDescription
        
        self.authorLabel.text =
        viewModel.author
        
        self.seeMoreButton.setTitle("See more ...", for: UIControl.State.normal)
    }
    
}

extension NYTTopStoriesListDetailsViewController: CQClassIdentifier {}
