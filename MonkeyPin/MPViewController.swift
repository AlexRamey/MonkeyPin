//
//  ViewController.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 3/18/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit
import SpriteKit

class MPViewController: UIViewController {

    var isPresentingScene:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let spriteView:SKView = self.view as? SKView{
            spriteView.showsDrawCount = true
            spriteView.showsNodeCount = true
            spriteView.showsFPS = true
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if (!isPresentingScene){
            let scene = MPHomeScene(size:self.view.frame.size)
            if let spriteView:SKView = self.view as? SKView{
                spriteView.presentScene(scene)
                isPresentingScene = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

