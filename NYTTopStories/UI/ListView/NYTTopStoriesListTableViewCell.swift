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

    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.titleLabel?.text =
        ""
        self.descriptionLabel?.text =
        ""
        self.largeImageView?.image =
        nil
    }

}

extension NYTTopStoriesListTableViewCell: CQClassIdentifier {}

extension NYTTopStoriesListTableViewCell: NYTTopStoriesListTableViewCellConfigurationInterface
{
    
    typealias TableViewCell = NYTTopStoriesListTableViewCell
    typealias ViewModel = NYTTopStoriesListTableViewCellViewModel
    
    func configure(cell: NYTTopStoriesListTableViewCell, withModel viewModel: NYTTopStoriesListTableViewCellViewModel) {
        
        cell.titleLabel?.text =
        viewModel.title
        
        cell.descriptionLabel?.text =
        viewModel.author
        
        guard let imageView = cell.largeImageView else {
            return
        }
    
        self.largeImageView?.image =
            NYTConstants.nytPlaceHolderImage
        
        NYTConstants.assignImageFromUrl(
            viewModel.thumbNailImage,
            toView: imageView
        )

    }
    
}
