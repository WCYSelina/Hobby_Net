//
//  PageViewTableViewCell.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 28/5/2023.
//

import UIKit

class PageViewTableViewCell: UITableViewCell{
    var downloadTask: URLSessionDataTask?
    var containerView: UIView!
    var pageViewControlObj: PageContainerViewController!
    var imageViewContainer = UIView()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        print("cell reused")
    }

}
