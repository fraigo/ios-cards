//
//  ViewController.swift
//  ios-cards
//
//  Created by Francisco on 2018-09-24.
//  Copyright © 2018 franciscoigor. All rights reserved.
//

import UIKit

extension CGFloat {
    func toPixels(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Int {
        let scale: CGFloat = 1.0 / UIScreen.main.scale
        return Int(scale * (self / scale).rounded(rule))
    }
}

class ViewController: UIViewController {

    var deck = [  "🥑" ,"🌽" ,
                  "🌶" ,"🥕" ,
                  "🥒" ,"🍆" ,
                  "🥔" ,"🍋" ]
    var cards = [ String ]()
    let emptyCard = "🃏"
    var values = [String]()
    var level = 0
    let cardsHorizontalLevel = [2, 2, 3, 4, 4, 5]
    let cardsVerticalLevel =   [2, 3, 4, 4, 6, 6]
    
    
    var emptyButton = UIButton()
    var lastButton = UIButton()
    
    var opened = false
    var cardsHorizontal = 3
    var cardsVertical = 4
    let background = UIColor.gray
    var cardsLeft = 0
    var loaded = false
    var buttons = [UIButton]()
    
    
    @IBOutlet weak var appView: UIScrollView!
    @IBOutlet weak var gameButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lastButton.setTitle(emptyCard, for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.createButtons()
        }
        
    }
    
    func shuffleCards(){
        cardsHorizontal = cardsHorizontalLevel[level]
        cardsVertical = cardsVerticalLevel[level] 
        cardsLeft = cardsHorizontal*cardsVertical
        cards.removeAll()
        for x in 0..<(cardsLeft/2){
            cards.append(deck[x])
            cards.append(deck[x])
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
        
        let padding = 10
        let screenSize = appView.bounds
        let screenWidth = screenSize.width.toPixels()
        let screenHeight = screenSize.height.toPixels()
        
        
        let width = (screenWidth - (padding * 5)) / cardsHorizontal
        let height = (screenHeight - (padding * 5)) / cardsVertical
        
        
        
        for x in 0..<cardsHorizontal{
            for y in 0..<cardsVertical{
                var button : UIButton
                let rect = CGRect(x: x * (width + padding) + padding, y: y * (height + padding) + padding, width: width, height: height)
                
                button = UIButton(frame: rect)
                button.backgroundColor = background
                button.setTitle(emptyCard, for: .normal)
                button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
                button.titleLabel?.font = UIFont(name: (button.titleLabel?.font.fontName)!,
                                                 size: CGFloat( min(width,height)))!
                button.tag = x + y * cardsHorizontal
                appView.addSubview(button)
                buttons.append(button)
                
                
            }
        }
        
        loaded = true
    }
    
    @IBAction func gameClick(_ sender: Any) {
        let subViews = appView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        buttons.removeAll()
        createButtons()
    }
    
    
    @IBAction func buttonClick(_ sender: UIButton) {
        NSLog("TAG \(sender.tag)")
        let label  = values[sender.tag]
        if (sender.currentTitle != emptyCard){
            NSLog("Opened!")
            return
        }
        sender.setTitle( label, for: UIControlState.normal)
        if (lastButton.currentTitle != emptyCard){
            self.opened = true
            let button1 = self.lastButton
            let button2 = sender
            NSLog("Second!")
            
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
                    if (self.cardsLeft == 0){
                        self.level += 1
                        self.gameButton.setTitle("Next Level", for: UIControlState.normal)
                    }
                }
                
            }
            lastButton = emptyButton
            return
        }else{
            lastButton = sender
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

