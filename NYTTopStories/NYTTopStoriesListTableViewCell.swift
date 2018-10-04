//
//  NYTTopStoriesListTableViewCell.swift
//  NYTTopStories
//
//  Created by Sanooj on 04/10/2018.
//  Copyright © 2018 Sanooj. All rights reserved.
//

import UIKit

protocol NYTTopStoriesListTableViewCellBaseViewModelInterface {
}

protocol NYTTopStoriesListTableViewCellConfigurationInterface {
    
    associatedtype TableViewCell:UITableViewCell
    associatedtype ViewModel:NYTTopStoriesListTableViewCellBaseViewModelInterface
    
    func configure(
        cell:TableViewCell ,
        withModel viewModel:ViewModel
    )
}

struct NYTTopStoriesListTableViewCellViewModel:NYTTopStoriesListTableViewCellBaseViewModelInterface {
    let title: String
    let author: String
    let thumbNailImage: String
}

class NYTTopStoriesListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.textLabel?.text =
        ""
        self.detailTextLabel?.text =
        ""
        self.imageView?.image =
        nil
    }

}

extension NYTTopStoriesListTableViewCell: CQClassIdentifier {}

extension NYTTopStoriesListTableViewCell: NYTTopStoriesListTableViewCellConfigurationInterface
{
    
    typealias TableViewCell = NYTTopStoriesListTableViewCell
    typealias ViewModel = NYTTopStoriesListTableViewCellViewModel
    
    func configure(cell: NYTTopStoriesListTableViewCell, withModel viewModel: NYTTopStoriesListTableViewCellViewModel) {
        
        cell.textLabel?.text =
        viewModel.title
        
        cell.detailTextLabel?.text =
        viewModel.author
        
        guard let imageView = cell.imageView else {
            return
        }
    
        self.imageView?.image =
            NYTConstants.nytPlaceHolderImage
        
        NYTConstants.assignImageFromUrl(
            viewModel.thumbNailImage,
            toView: imageView
        )
        
        cell.layoutIfNeeded()
    }
    
}
