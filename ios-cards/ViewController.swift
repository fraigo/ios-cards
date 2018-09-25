//
//  ViewController.swift
//  ios-cards
//
//  Created by Francisco on 2018-09-24.
//  Copyright © 2018 franciscoigor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cards = [ "🥑" , "🌽" , "🥕" , "🥒"]
    var values = [ "" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        values.removeAll()
        values.append(cards[0])
        values.append(cards[0])
        values.append(cards[1])
        values.append(cards[1])
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        let label : String! = values[sender.tag-1]
        NSLog("TAG \(sender.tag) : \(label)")
        sender.setTitle( label, for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

