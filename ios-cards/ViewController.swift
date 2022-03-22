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

    
    
    var emptyButton = UIButton()
    var lastButton = UIButton()
    
    let background = UIColor.gray
    
    var buttons = [UIButton]()
    
    var game : Game = Game()
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cardCounter: UILabel!
    @IBOutlet weak var appView: UIScrollView!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var audioSwitch: UISwitch!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var currentMarks: UILabel!
    @IBOutlet weak var bestMarks: UILabel!
    
    required init(coder decoder: NSCoder) {
       super.init(coder: decoder)!
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastButton.setTitle(game.EMPTY_CARD, for: .normal)
        bigLabel.text = ("Memory Cards")
        bigLabel.isHidden = false
        self.gameButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.gameButton.isHidden = false
        }
        game.counter(timerLabel: timerLabel)
        
    }
    
    
    
    func resizeButtons(){
        
        let padding = 10
        let screenSize = appView.bounds
        let screenWidth = screenSize.width.toPixels()
        let screenHeight = screenSize.height.toPixels()
        
        let width = (screenWidth - (padding * (game.cardsHorizontal+1))) / game.cardsHorizontal
        let height = (screenHeight - (padding * (game.cardsVertical+1))) / game.cardsVertical
        
        NSLog("size \(screenWidth) x \(screenHeight) => \(width) x \(height) ")
        var x = 0, y = 0
        for button in buttons {
            x = button.tag % game.cardsHorizontal
            y = Int(floor(Double(button.tag) / Double(game.cardsHorizontal)))
            let rect = CGRect(x: x * (width + padding) + padding, y: y * (height + padding) + padding, width: width, height: height)
            button.frame = rect
            button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!,
                                             size: CGFloat( min(width,height)))!
        }
    }
    
    func createButtons(){
        game.shuffleCards()
        
        self.gameButton.setTitle("Restart Level \(game.getLevel())"
                                 , for: UIControlState.normal)
        self.gameButton.isSelected = false
        self.bigLabel.text = ("")
        cardCounter.text = "🃏 \(game.flippedCards)"
        
        
        for x in 0..<game.cardsHorizontal{
            for y in 0..<game.cardsVertical{
                var button : UIButton
                let rect = CGRect(x: x * 50, y: y * 50, width: 50, height: 50)
                
                button = UIButton(frame: rect)
                button.backgroundColor = background
                button.setTitle(game.EMPTY_CARD, for: .normal)
                button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
                button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!,
                                                 size: CGFloat( min(50,50)))!
                button.tag = x + y * game.cardsHorizontal
                appView.addSubview(button)
                buttons.append(button)
                
                
            }
        }
        
        resizeButtons()
        self.currentMarks.isHidden = true
        self.bestMarks.isHidden = true
        
        
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
            if (![bigLabel, bestMarks, currentMarks].contains(subview)){
                subview.removeFromSuperview()
            }
            
        }
        self.currentMarks.isHidden = false
        self.bestMarks.isHidden = false
        buttons.removeAll()
        createButtons()
    }
    
    
    @IBAction func buttonClick(_ currentCard: UIButton) {
        let label  = game.getLabel(currentCard.tag)
        if (currentCard.currentTitle != game.EMPTY_CARD){
            NSLog("Opened!")
            return
        }
        game.openedCards += 1
        game.flippedCards += 1
        cardCounter.text = "🃏 \(game.flippedCards)"
        
        
        currentCard.setTitle( label, for: UIControlState.normal)
        if (game.openedCards == 2){
            animate(currentCard)
            game.opened = true
            let button1 = self.lastButton
            let button2 = currentCard
            NSLog("Second!")
            game.openedCards = 0
            
            if (label != lastButton.currentTitle){
                NSLog("Missed!")
                button1.backgroundColor = UIColor.orange
                button2.backgroundColor = UIColor.orange
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    button1.setTitle(self.game.EMPTY_CARD, for: UIControlState.normal)
                    button2.setTitle(self.game.EMPTY_CARD, for: UIControlState.normal)
                    button1.backgroundColor = self.background
                    button2.backgroundColor = self.background
                    self.game.opened = false
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
                    self.game.opened = false
                    self.game.cardsLeft -=  2
                    if (self.game.isGameFinished()){
                        self.bigLabel.text = ("You finished !! 🎉")
                        self.gameButton.isSelected = true
                        self.playSound()
                        self.currentMarks.isHidden = false
                        self.bestMarks.isHidden = false
                        self.game.nextLevel()
                        self.currentMarks.text = "Level ⏱ \(self.game.seconds) sec. 🃏 \(self.game.flippedCards) cards"
                        self.bestMarks.text = "Best  ⏱ \(self.game.bestLevelSeconds) sec. 🃏 \(self.game.bestLevelCards) cards"
                        if (self.game.seconds == self.game.bestLevelSeconds || self.game.flippedCards == self.game.bestLevelCards){
                            self.bigLabel.text = ("New Record !!")
                        }
                        self.game.restartGame()
                        
                        self.gameButton.setTitle("Start Again", for: UIControlState.normal)
                        
                    }
                    else if (self.game.isLevelFinished()){
                        self.bigLabel.text = ("Good Job !!")
                        self.gameButton.isSelected = true
                        
                        self.game.nextLevel()
                        
                        self.currentMarks.isHidden = false
                        self.bestMarks.isHidden = false
                        self.currentMarks.text = "Level ⏱ \(self.game.seconds) sec. 🃏 \(self.game.flippedCards) cards"
                        self.bestMarks.text = "Best  ⏱ \(self.game.bestLevelSeconds) sec. 🃏 \(self.game.bestLevelCards) cards"
                        if (self.game.seconds == self.game.bestLevelSeconds || self.game.flippedCards == self.game.bestLevelCards){
                            self.bigLabel.text = ("New Record !!")
                        }
                        self.gameButton.setTitle("Next Level", for: UIControlState.normal)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            if (!self.currentMarks.isHidden){
                                self.gameClick(self)
                            }
                        }
                    }
                }
                playSound()
                
            }
            lastButton = emptyButton
            return
        }else{
            lastButton = currentCard
            animate(currentCard)
        }
        
    }
    
    func animate(_ currentCard: UIButton){
        UIView.animate(withDuration: 0.1, animations: {
            currentCard.frame.origin.x += currentCard.frame.width/4
            currentCard.frame.size = CGSize(width: currentCard.frame.width/2, height: currentCard.frame.height)
            
        }){ (completed) in
            
            
            UIView.animate(withDuration: 0.1, animations: {
                currentCard.frame.size = CGSize(width: currentCard.frame.width * 2, height: currentCard.frame.height)
                currentCard.frame.origin.x -= currentCard.frame.width/4
            })
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

