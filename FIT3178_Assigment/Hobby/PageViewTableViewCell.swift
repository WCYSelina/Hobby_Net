//
//  PageViewTableViewCell.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 28/5/2023.
//

import UIKit

class PageViewTableViewCell: UITableViewCell {

    var containerView: UIView!
    var pageViewControlObj: PageContainerViewController!
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Create the container view
//        containerView = UIView(frame: bounds)
//        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        contentView.addSubview(containerView)
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.addGestureRecognizer(swipeLeft)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
                pageViewControlObj.pageViewController(pageViewControlObj, viewControllerBefore: pageViewControlObj.currentViewController)
                
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
                pageViewControlObj.pageViewController(pageViewControlObj, viewControllerBefore: pageViewControlObj.currentViewController)
            default:
                break
            }
        }
    }
    
}
