//
//  SpeechSynthesizer.swift
//  Schatzsuche
//
//  Created by Sebastian Hunkeler on 13/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import AVFoundation

let languageCode = "de-DE"


class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate
{
    
    var speechSynthesizer: AVSpeechSynthesizer!
    var speechCompleted: () -> () = {}
    
    
    override init() {
        super.init()
        //TODO
        /*var mySpeechSynthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
        var myString:String = "Hallo, ich bin ein Testeintrag."
        var mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string:myString)
        
        println("\(mySpeechUtterance.speechString)")
        println("My string - \(myString)")
        
        mySpeechSynthesizer.speakUtterance(mySpeechUtterance)*/
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.speechSynthesizer.delegate = self
    }
    
    func speak(text:String, onComplete:()->()) {
        //TODO
        var speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = AVSpeechUtteranceMinimumSpeechRate
        self.speechSynthesizer.speakUtterance(speechUtterance)
        
        self.speechCompleted = onComplete
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        println("finish")
        self.speechCompleted()
    }
}
