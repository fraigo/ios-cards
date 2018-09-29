//
//  ViewController.swift
//  ios-cards
//
//  Created by Francisco on 2018-09-24.
//  Copyright © 2018 franciscoigor. All rights reserved.
//

import UIKit
import AVFoundation


extension CGFloat {
    func toPixels(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Int {
        let scale: CGFloat = 1.0 / UIScreen.main.scale
        return Int(scale * (self / scale).rounded(rule))
    }
}

class ViewController: UIViewController {

    
    var decks: [[ String ]] = [[String]]()
    var currentDeck = [ String ]()
    var cards = [ String ]()
    let emptyCard = "🃏"
    var values = [String]()
    var level = 0
    let cardsHorizontalLevel = [2, 2, 3, 4, 4, 5]
    let cardsVerticalLevel =   [2, 3, 4, 4, 5, 6]
    
    
    var emptyButton = UIButton()
    var lastButton = UIButton()
    
    
    var opened = false
    var cardsHorizontal = 3
    var cardsVertical = 4
    let background = UIColor.gray
    var cardsLeft = 0
    var openedCards = 0
    var flippedCards = 0
    var seconds = 0
    var incr = 0
    var totalSeconds = 0
    var loaded = false
    var buttons = [UIButton]()
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cardCounter: UILabel!
    
    @IBOutlet weak var appView: UIScrollView!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var audioSwitch: UISwitch!
    
    @IBOutlet weak var bigLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastButton.setTitle(emptyCard, for: .normal)
        
        decks.append([
            "🥑" ,"🌽" , "🌶" ,"🥕" ,
            "🥒" ,"🍆" , "🥔" ,"🍋" ,
            "🍎" ,"🍊" , "🍉" ,"🍏" ,
            "🍓" ,"🍒" , "🥝" ,"🍍"
        ])
        decks.append([
            "😍" ,"😜" , "😎" ,"😰" ,
            "😃" ,"😴" , "😱" ,"🤔" ,
            "😵" ,"🤠" , "🤮" ,"🤕" ,
            "😭" ,"😐" , "🤧" ,"🤯"
        ])
        counter()
        
    }
    
    func counter(){
        seconds += incr
        timerLabel.text = "⏱ \(seconds)s"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.counter()
        }
    }
    
    func shuffleCards(){
        
        let deckNum = Int(arc4random_uniform(UInt32(decks.count)))
        currentDeck = decks[deckNum]
        cardsHorizontal = cardsHorizontalLevel[level]
        cardsVertical = cardsVerticalLevel[level] 
        cardsLeft = cardsHorizontal*cardsVertical
        cards.removeAll()
        for x in 0..<(cardsLeft/2){
            cards.append(currentDeck[x])
            cards.append(currentDeck[x])
        }
        values = cards
        for idx in 0..<values.count
        {
            let rand = Int(arc4random_uniform(UInt32(cards.count)))
            
            values[idx] = (cards[rand])
            
            cards.remove(at: rand)
        }
    }
    
    func resizeButtons(){
        
        let padding = 10
        let screenSize = appView.bounds
        let screenWidth = screenSize.width.toPixels()
        let screenHeight = screenSize.height.toPixels()
        
        let width = (screenWidth - (padding * (cardsHorizontal+1))) / cardsHorizontal
        let height = (screenHeight - (padding * (cardsVertical+1))) / cardsVertical
        
        NSLog("size \(screenWidth) x \(screenHeight) => \(width) x \(height) ")
        var x = 0, y = 0
        for button in buttons {
            x = button.tag % cardsHorizontal
            y = Int(floor(Double(button.tag) / Double(cardsHorizontal)))
            let rect = CGRect(x: x * (width + padding) + padding, y: y * (height + padding) + padding, width: width, height: height)
            button.frame = rect
            button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!,
                                             size: CGFloat( min(width,height)))!
        }
    }
    
    func createButtons(){
        self.shuffleCards()
        self.gameButton.setTitle("Restart Level \(level+1)", for: UIControlState.normal)
        self.gameButton.isSelected = false
        self.bigLabel.text = ("")
        self.flippedCards = 0
        cardCounter.text = "🃏 \(flippedCards)"
        
        
        for x in 0..<cardsHorizontal{
            for y in 0..<cardsVertical{
                var button : UIButton
                let rect = CGRect(x: x * 50, y: y * 50, width: 50, height: 50)
                
                button = UIButton(frame: rect)
                button.backgroundColor = background
                button.setTitle(emptyCard, for: .normal)
                button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
                button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!,
                                                 size: CGFloat( min(50,50)))!
                button.tag = x + y * cardsHorizontal
                appView.addSubview(button)
                buttons.append(button)
                
                
            }
        }
        
        resizeButtons()
        
        loaded = true
        incr = 1
        
    }
    
    func playSound(){
        if (!audioSwitch.isOn){
            return
        }
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1016
        // to play sound
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    @IBAction func gameClick(_ sender: Any) {
        let subViews = appView.subviews
        for subview in subViews{
            if (subview != bigLabel){
                subview.removeFromSuperview()
            }
            
        }
        buttons.removeAll()
        createButtons()
        seconds = 0
    }
    
    
    @IBAction func buttonClick(_ currentCard: UIButton) {
        let label  = values[currentCard.tag]
        if (currentCard.currentTitle != emptyCard){
            NSLog("Opened!")
            return
        }
        openedCards += 1
        flippedCards += 1
        cardCounter.text = "🃏 \(flippedCards)"
        
        
        currentCard.setTitle( label, for: UIControlState.normal)
        if (openedCards == 2){
            self.opened = true
            let button1 = self.lastButton
            let button2 = currentCard
            NSLog("Second!")
            openedCards = 0
            
            if (label != lastButton.currentTitle){
                NSLog("Missed!")
                button1.backgroundColor = UIColor.orange
                button2.backgroundColor = UIColor.orange
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    button1.setTitle(self.emptyCard, for: UIControlState.normal)
                    button2.setTitle(self.emptyCard, for: UIControlState.normal)
                    button1.backgroundColor = self.background
                    button2.backgroundColor = self.background
                    self.opened = false
                }
                lastButton = emptyButton
                return
            }else{
                NSLog("Great!")
                button1.backgroundColor = UIColor.yellow
                button2.backgroundColor = UIColor.yellow
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    button1.isHidden = true
                    button2.isHidden = true
                    self.opened = false
                    self.cardsLeft -=  2
                    if (self.level == self.cardsHorizontalLevel.count - 1){
                        self.bigLabel.text = ("You finished !!")
                        self.gameButton.isSelected = true
                        self.playSound()
                        self.level = 0
                        self.incr = 0
                        self.gameButton.setTitle("Start Again", for: UIControlState.normal)
                        
                    }
                    else if (self.cardsLeft == 0){
                        self.bigLabel.text = ("Good Job !!")
                        self.gameButton.isSelected = true
                        self.level += 1
                        self.incr = 0
                        self.gameButton.setTitle("Next Level", for: UIControlState.normal)
                    }
                }
                playSound()
                
            }
            lastButton = emptyButton
            return
        }else{
            lastButton = currentCard
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.resizeButtons()
        }
    }


}

