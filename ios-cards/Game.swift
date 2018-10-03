//
//  Game.swift
//  ios-cards
//
//  Created by Francisco on 2018-10-02.
//  Copyright © 2018 franciscoigor. All rights reserved.
//

import UIKit

class Game: NSObject {
    
    var decks: [[ String ]] = [[String]]()
    var cards = [ String ]()
    var currentDeck = [ String ]()
    
    let cardsHorizontalLevel = [2, 2, 3, 4, 4, 5]
    let cardsVerticalLevel =   [2, 3, 4, 4, 5, 6]
    let EMPTY_CARD = "🃏"
    
    var cardsHorizontal = 2
    var cardsVertical = 2
    
    var values = [String]()
    var level = 0
    
    var cardsLeft = 0
    var openedCards = 0
    var flippedCards = 0
    var seconds = 0
    var timerIncrement = 0
    var totalSeconds = 0
    var opened = false
    
    var totalCardsOpened = 0
    var totalGameSeconds = 0

    
    
    override init() {
        super.init()
        createDecks()
    }
    
    
    func createDecks(){
        decks = [[String]]()
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
        
        flippedCards = 0
        timerIncrement = 1
        seconds = 0
    }
    
    func counter(timerLabel : UILabel){
        seconds += timerIncrement
        timerLabel.text = "⏱ \(seconds)s"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.counter(timerLabel: timerLabel)
        }
    }
    
    func getLabel(_ index: Int) -> String{
        return values[index]
    }
    
    func getLevel() -> Int {
        return level+1
    }
    
    func isGameFinished() -> Bool{
        return self.level == self.cardsHorizontalLevel.count - 1 && self.cardsLeft == 0
    }
    
    func isLevelFinished() -> Bool{
        return self.cardsLeft == 0
    }
    
    func collect(){
        totalGameSeconds += seconds
        totalCardsOpened += flippedCards
    }
    
    func nextLevel(){
        collect()
        level += 1
        timerIncrement = 0
        
    }
    
    func restartGame(){
        collect()
        level = 0
        timerIncrement = 0
        totalGameSeconds = 0
        totalCardsOpened = 0
    }
    

}