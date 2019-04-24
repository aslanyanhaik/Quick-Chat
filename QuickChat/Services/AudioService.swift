//
//  AudioService.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/24/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import AudioToolbox

class AudioService {
  
  func playSound()  {
    var soundID: SystemSoundID = 0
    let soundURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "newMessage", ofType: "wav")!)
    AudioServicesCreateSystemSoundID(soundURL, &soundID)
    AudioServicesPlaySystemSound(soundID)
  }
}
