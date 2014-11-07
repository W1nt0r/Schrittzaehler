//
//  AccelerometerStepCounter.swift
//  Schatzsuche
//
//  Created by Sebastian Hunkeler on 18/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import CoreMotion

class AccelerometerStepCounter: StepCounter
{
    private let frameRate = 50
    private var accelerating = false
    private let shortBuffer = RingBuffer(capacity: 4)
    private let longBuffer = RingBuffer(capacity: 35)
    private let quantisationStep = 0.25
    
    var onAccelerationMeasured:(Double,Double,Double,Double) -> () = {value in}
    
    let accelerometer = CMMotionManager()
    
    override func start() {
        reset()
        accelerometer.accelerometerUpdateInterval = 1.0 / Double(frameRate)
        accelerometer.startAccelerometerUpdatesToQueue(stepQueue, withHandler: {
            data, error in
            let acceleration:CMAcceleration = data.acceleration
            
            let x = acceleration.x
            let y = acceleration.y
            let z = acceleration.z
            
            let magnitude = sqrt( pow(x, 2) + pow(y, 2) + pow(z, 2) )
            let adjustedAmplifiedMagnitude = pow(magnitude, 5) - 1 //Substract 1 to align vertically on x-axis
            let roundedValue = round(adjustedAmplifiedMagnitude / self.quantisationStep) * self.quantisationStep
            
            //println("Magnitude: \(magnitude) shortAvg: \(shortAverage) longAvg: \(longAverage) Acc.: \(self.accelerating)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.onAccelerationMeasured(x,y,z,roundedValue)
            })
            
            self.shortBuffer.put(magnitude);
            self.longBuffer.put(magnitude);
            
            let shortAverage = self.shortBuffer.getAverage()
            let longAverage = self.longBuffer.getAverage()
            
            
            if (!self.accelerating && (shortAverage > longAverage * 1.1)) {
                self.accelerating = true
                self.steps++
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.onStep()
                })
            }
            
            if (self.accelerating && shortAverage < longAverage * 0.9) {
                self.accelerating = false;
            }
            
        })
    }
    
    override func stop() {
        accelerometer.stopAccelerometerUpdates()
        stepQueue.cancelAllOperations()
    }
}
