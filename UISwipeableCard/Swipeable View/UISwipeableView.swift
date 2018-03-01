//
//  UISwipeableView.swift
//  UISwipeableCard
//
//  Created by Balaji M on 3/1/18.
//  Copyright © 2018 Balaji M. All rights reserved.
//

import UIKit

protocol UISwipeableCardSelectionDelegate {
    func didSelect(card: Card, atIndex index: Int)
    func onCardSwiped(visibleCardIndex: Int)
}

extension UISwipeableCardSelectionDelegate {
    // To make this method optional
    func onCardSwiped(visibleCardIndex: Int) { }
}

class UISwipeableView: UIView {

    var delegate: UISwipeableCardSelectionDelegate?
    
    private var swipe: Swipe?
    
    private var cardsIn  = [Card] ()
    private var cardsOut = [Card] ()
    
    private var viewPositionIndicator: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstants()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupConstants()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupConstants()
        
        createPositionIndicator(cardsIn.count + cardsOut.count)
    }
    
    private func setupConstants() {
        CONSTANT_HEIGHT =  frame.size.height
        CONSTANT_CENTER =  CGPoint(x: frame.size.width/2, y: frame.size.height/2)
    }
    
    
    func add(cards: [Card])  {
        
        guard cards.count > 0 else {
            return
        }
        
        let firstCard = cards.first!
        
        outOffsetX = (frame.size.width - firstCard.frame.size.width) / 4
        inOffsetX = outOffsetX - firstCard.frame.size.width
        
        createPositionIndicator(cards.count)
        
        removeAllCards()
        
        for card in cards {
            
            cardsIn.append(card)
            
            card.tag = cardsIn.count
            onSwiped(card: card, cardsCount: cards.count)
            addSubview(card)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            pan.delegate = self
            card.addGestureRecognizer(pan)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
            tap.delegate = self
            card.addGestureRecognizer(tap)
        }
    }
    
    func count() -> Int {
        return cardsIn.count + cardsOut.count
    }
    
    func removeAllCards() {
        
        let cards = cardsIn + cardsOut
        
        DispatchQueue.main.async {
            for card in cards {
                card.removeFromSuperview()
            }
        }
        
        cardsIn.removeAll()
        cardsOut.removeAll()
    }
    
    func swipeTo(index: Int, animation: Bool) {
        
        let cardsCount = cardsIn.count + cardsOut.count
        
        guard index < cardsCount else { return }
        
        // Swipe In
        if index < cardsIn.count {
            var tempIndex = cardsIn.count - index - 1
            while tempIndex > 0 {
                UIView.animate(withDuration: animation ? 0.2 : 0.0) { self.swipeOut() }
                tempIndex -= 1
            }
        } else {
            var outLastIndex = cardsOut.count - 1
            let swipeToIndex = outLastIndex - index
            while swipeToIndex <= outLastIndex {
                UIView.animate(withDuration: animation ? 0.2 : 0.0) { self.swipeIn() }
                outLastIndex -= 1
            }
        }
    }
    
    private func constructSwipeIn() -> Swipe? {
        return cardsOut.count > 0 ? Swipe.in(cardsOut.last!) : nil
    }
    
    private func constructSwipeOut() -> Swipe? {
        // Cannot swipe out last card
        return cardsIn.count > 1 ? Swipe.out(cardsIn.last!) : nil
    }
    
    private func reset(swipe: Swipe)  {
        switch swipe {
        case .in(let card):
            card.frame.origin.x = -card.frame.size.width
        case .out(let card):
            card.center = CONSTANT_CENTER
        }
    }
    
    private func resetCardOut(card: Card)  {
        card.frame.origin.x = -card.frame.size.width
    }
    
    private func swipeOut() {
        // Cannot swipe out last card
        guard cardsIn.count > 1 else { return }
        
        let cardOut = cardsIn.removeLast()
        cardsOut.append(cardOut)
        
        // Move the card out of the view
        cardOut.frame.origin.x = -(cardOut.frame.size.width + 10) // 10 -> To hide shadows if any
        
        notifyCards()
    }
    
    private func swipeIn() {
        guard cardsOut.count > 0 else { return }
        
        let cardIn = cardsOut.removeLast()
        cardsIn.append(cardIn)
        
        notifyCards()
    }
    
    private func notifyCards() {
        for card in cardsIn {
            onSwiped(card: card, cardsCount: cardsIn.count)
        }
        
        // Notify delegate
        delegate?.onCardSwiped(visibleCardIndex: cardsIn.count - 1)
    }
    
    private func onSwiped(card: UIView, cardsCount: Int) {
        
        let newX: CGFloat
        let height: CGFloat
        
        switch card.tag {
            
        case cardsCount:
            card.alpha  = 1.0
            height = CONSTANT_HEIGHT
            newX = CONSTANT_CENTER.x
            
        case cardsCount - 1:
            card.alpha  = 0.7
            height = CONSTANT_HEIGHT - OFFSET_H * 2
            newX   = CONSTANT_CENTER.x + OFFSET_X
            
        case cardsCount - 2:
            card.alpha  = 0.7
            height = CONSTANT_HEIGHT - OFFSET_H * 4
            newX   = CONSTANT_CENTER.x + OFFSET_X * 2
            
        default:
            card.alpha  = 0.0
            height = CONSTANT_HEIGHT - OFFSET_H * 6
            newX   = CONSTANT_CENTER.x + OFFSET_X * 3
        }
        
        // 10, 11, 10 -> Shadow and Position indicator heights, top space of position indictor to card
        card.frame.size = CGSize(width: card.frame.size.width, height: height - 10 - 15 - 10)
        card.center     = CGPoint(x: newX, y: CONSTANT_CENTER.y)
        
        updateIndicator()
    }
    
    private enum Swipe {
        case `in`(Card)
        case out (Card)
    }
    
    // Constants
    private var CONSTANT_HEIGHT: CGFloat!
    private var CONSTANT_CENTER: CGPoint!
    private let OFFSET_X: CGFloat = 8.0
    private let OFFSET_H: CGFloat = 8.0
    private var inOffsetX: CGFloat!
    private var outOffsetX: CGFloat!

}


// MARK:- Gesture handler

extension UISwipeableView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view === touch.view
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        
        if let card = gesture.view as? Card, let _ = delegate {
            delegate!.didSelect(card: card, atIndex: card.tag - 1)
        }
    }
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        
        let transalation = gesture.translation(in: self)
        
        func pan(card: UIView, condition: @escaping (CGFloat) -> Bool, swipeAction: @escaping () -> Void)
        {
            card.frame.origin.x += transalation.x
            
            if gesture.state == .ended
            {
                if condition(card.frame.origin.x) {
                    UIView.animate(withDuration: 0.3) { swipeAction() }
                }
                else {
                    reset(swipe: swipe!)
                }
                
                swipe = nil
            }
        }
        
        if swipe == nil {
            if gesture.state == .began {
                swipe = transalation.x >= 0 ? constructSwipeIn() : constructSwipeOut()
            }
        }
        
        guard swipe != nil else { return }
        
        switch swipe! {
        case .in(let card):
            pan(card: card, condition: { (x) in return x > self.inOffsetX }, swipeAction: swipeIn)
            
        case .out(let card):
            pan(card: card, condition: { (x) in return x < self.outOffsetX }, swipeAction: swipeOut)
        }
        
        gesture.setTranslation(CGPoint.zero, in: self)
    }
}




// MARK:- Position indicator

extension UISwipeableView {
    
    private func createPositionIndicator(_ cardCount: Int)  {
        
        if viewPositionIndicator != nil {
            viewPositionIndicator.removeFromSuperview()
            viewPositionIndicator = nil
        }
    
        viewPositionIndicator = UIStackView(frame: CGRect(x: 0, y: frame.size.height - 15, width: frame.size.width, height: 15))
        viewPositionIndicator.distribution = .fillEqually
        
        let currentCardPosition = UILabel()
        currentCardPosition.textColor = UIColor.black
        currentCardPosition.font      = UIFont.systemFont(ofSize: 12)
        currentCardPosition.text      = "1"
        currentCardPosition.textAlignment = .right
        viewPositionIndicator.addArrangedSubview(currentCardPosition)
        
        let totalCards = UILabel()
        totalCards.textColor = UIColor.gray
        totalCards.font      = UIFont.systemFont(ofSize: 12)
        totalCards.text      = "/\(cardCount)"
        viewPositionIndicator.addArrangedSubview(totalCards)
        addSubview(viewPositionIndicator)
    }
    
    private func updateIndicator() {
        let labelCurrentCardPosition  = viewPositionIndicator.arrangedSubviews[0] as! UILabel
        labelCurrentCardPosition.text = "\(cardsIn.count)"
    }
}
