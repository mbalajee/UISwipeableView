# UISwipeableView


Currently supports Portrait orientation only.

#### Usage

Drag and drop a UIView in Storyboard and make UISwipeableView as its custom class.  Make the view's width to match the ViewController's width for a cleaner swipe.

#### Creating Swipeable card

__Card__ class will be super class for all the swipeable card views.

```
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
```

#### Adding Swipeable card to UISwipeableView

```
var cards = [Card] ()

// Create card 
for i in 1...10 {
    let card = CardNumber.loadNib()
    card.update(i)
    cards.append(card)
}

// Add cards to swipeable view
swipeableView.add(cards: cards)
```

#### UISwipeableCardSelectionDelegate

```
func didSelect(card: Card, atIndex index: Int) {
    print("Card selected at \(index)")
}

func onCardSwiped(visibleCardIndex: Int) {
    print("Card swiped at \(visibleCardIndex)")
}
```

