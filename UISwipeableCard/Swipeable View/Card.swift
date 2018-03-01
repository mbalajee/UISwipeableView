//
//  Card.swift
//  UISwipeableCard
//
//  Created by Balaji M on 3/1/18.
//  Copyright © 2018 Balaji M. All rights reserved.
//

import UIKit

class Card: UIView {

    var cornerRadius: CGFloat = 5
    var shadowOffsetWidth: Int = 0
    var shadowOffsetHeight: Int = 3
    var shadowColor: UIColor? = UIColor.lightGray
    var shadowOpacity: Float = 0.5
    
    
    override func layoutSubviews() {
        
        layer.cornerRadius = cornerRadius
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }

}
