//
//  MPScore.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/18/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import UIKit

class MPScore: NSObject, NSCoding{
    var playerName:String
    var score:Int
    var location:String
    
    // Memberwise initializer
    init(playerName: String, score: Int, location: String){
        self.playerName = playerName
        self.score = score
        self.location = location
    }
    
    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        self.init(
            playerName: decoder.decodeObjectForKey("MP_PLAYER_NAME_KEY") as! String,
            score: Int(decoder.decodeIntForKey("MP_PLAYER_SCORE_KEY")),
            location: decoder.decodeObjectForKey("MP_PLAYER_LOCATION_KEY") as! String
        )
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.playerName, forKey: "MP_PLAYER_NAME_KEY")
        coder.encodeInt(Int32(self.score), forKey: "MP_PLAYER_SCORE_KEY")
        coder.encodeObject(self.location, forKey: "MP_PLAYER_LOCATION_KEY")
    }
}
