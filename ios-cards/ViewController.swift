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

    var cards = [ "🥑" , "🌽" ,"🥑" , "🌽" ,
                  "🥑" , "🌽" ,"🥑" , "🌽" ,
                  "🥑" , "🌽" ,"🥑" , "🌽" ,
                  "🥑" , "🌽" ,"🥑" , "🌽" ]
    var values = [String]()
    var emptyButton = UIButton()
    var lastButton = UIButton()
    var opened = false
    let cardsHorizontal = 4
    let cardsVertical = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        values = cards
        for idx in 0..<values.count
        {
            let rand = Int(arc4random_uniform(UInt32(cards.count)))
            
            values[idx] = (cards[rand])
            
            cards.remove(at: rand)
        }
        
        createButtons()
        
    }
    
    func createButtons(){
        let padding = 20
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width.toPixels()
        let screenHeight = screenSize.height.toPixels()
        let width = (screenWidth - (padding * cardsHorizontal)) / cardsHorizontal
        let height = (screenHeight - (padding * cardsVertical)) / cardsVertical
        
        
        for x in 0..<cardsHorizontal{
            for y in 0..<cardsVertical{
                var button : UIButton
                let rect = CGRect(x: x * (width + padding) + padding/2, y: y * (height + padding) + padding, width: width, height: height)
                if (view.subviews.count>=cardsHorizontal * cardsVertical){
                    button = view.subviews[x + y * cardsHorizontal] as! UIButton
                    button.frame = rect
                }
                else{
                    button = UIButton(frame: rect)
                    button.backgroundColor = UIColor.green
                    button.setTitle(nil, for: .normal)
                    button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
                    button.tag = x + y * cardsHorizontal
                    self.view.addSubview(button)
                }
                
            }
        }
    }
    
    
    @IBAction func buttonClick(_ sender: UIButton) {
        NSLog("TAG \(sender.tag)")
        let label  = values[sender.tag]
        if (sender.currentTitle != nil){
            return
        }
        sender.setTitle( label, for: UIControlState.normal)
        if (lastButton.currentTitle != nil){
            if (label != lastButton.currentTitle){
                self.opened = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.lastButton.setTitle(nil, for: UIControlState.normal)
                    sender.setTitle(nil, for: UIControlState.normal)
                    self.opened = false
                }
                
                return
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


}

