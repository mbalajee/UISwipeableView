//
//  ViewController.swift
//  UISwipeableCard
//
//  Created by Balaji M on 3/1/18.
//  Copyright © 2018 Balaji M. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISwipeableCardSelectionDelegate {

    @IBOutlet weak var swipeableView: UISwipeableView! {
        didSet {
            swipeableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initSwipeableView()
        self.view.layoutIfNeeded()
    }

    private func initSwipeableView()  {
        
        var cards = [Card] ()
        
        // Create card 
        for i in 1...10 {
            let card = CardNumber.loadNib()
            card.update(i)
            cards.append(card)
        }
        
        // Add cards to swipeable view
        swipeableView.add(cards: cards)
    }
    
    
    func didSelect(card: Card, atIndex index: Int) {
        print("Card selected at \(index)")
    }
    
    func onCardSwiped(visibleCardIndex: Int) {
        print("Card swiped at \(visibleCardIndex)")
    }
}

