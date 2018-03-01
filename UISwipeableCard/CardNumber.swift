//
//  CardAlphabet.swift
//  UISwipeableCard
//
//  Created by Balaji M on 3/1/18.
//  Copyright © 2018 Balaji M. All rights reserved.
//

import UIKit

class CardNumber: Card {

    // Modal
    private var number: String?
    
    // Outlets
    @IBOutlet weak var label: UILabel!
   
    static func loadNib() -> CardNumber {
        return UINib(nibName: "CardNumber", bundle: nil).instantiate(withOwner: nil, options: [:]).first! as! CardNumber
    }

    func update(_ number: Int) {
        label.text = "Card number \(number)"
    }
}
