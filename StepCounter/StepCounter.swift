//
//  StepCounter.swift
//  Schatzsuche
//
//  Created by Sebastian Hunkeler on 13/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import CoreMotion

let stepQueueConcurrentOperationCount = 1

public class StepCounter: NSObject
{
    var steps:Int = 0 {
        didSet {
            if(steps > 0){
                dispatch_sync(dispatch_get_main_queue(), {
                    self.onStep()
                })

                if stepTarget != nil && steps >= stepTarget {
                    stepTarget = nil
                    dispatch_sync(dispatch_get_main_queue(), {
                        self.onStepTargetReached()
                    })
                }
            }
        }
    }
    var stepQueue:NSOperationQueue = NSOperationQueue()
    var stepTarget:Int?
    var onStepTargetReached:() -> () = {}
    var onStep:() -> () = {}
    
    override init() {
        stepQueue.maxConcurrentOperationCount = stepQueueConcurrentOperationCount
    }
    
    public func start(){}
    
    public func stop() {}
    
    public func reset(){
        stop();
        steps = 0
    }
}
