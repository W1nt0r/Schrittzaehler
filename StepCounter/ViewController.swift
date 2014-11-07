//
//  ViewController.swift
//  Schatzsuche
//
//  Created by Sebastian Hunkeler on 13/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!
    
    let speechSynthesizer = SpeechSynthesizer()
    var solutionLogger:SolutionLogger!
    var stepCounter: AccelerometerStepCounter!
    var actions:Array<String> = []
    var startStation:Int?
    

    override func viewDidLoad() {
        solutionLogger = SolutionLogger(viewController: self)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "viewTapped:"))
        setupGraph()
    }
    
    /**
    When the background view is tapped we would like to show the QR code reader
    **/
    func viewTapped(sender:UITapGestureRecognizer) {
        stepCounter?.stop()
        actions = []
        self.performSegueWithIdentifier("qrcodeReader", sender: self)
    }
    
    /**
    Initializes the graph view
    **/
    func setupGraph () {
        graphView.backgroundColor = UIColor.lightGrayColor()
    }
    
    func startStepCounterWithSteptarget(steps:Int)
    {
        stepCounter.stepTarget = steps
        stepCounter.onStepTargetReached = {
            self.stepCounter.stop()
            self.nextStep()
        }
        stepCounter.onStep = {
            println(toString(self.stepCounter.steps))
            //self.speechSynthesizer.speak("\(self.stepCounter.steps)", onComplete: {})
        }
        stepCounter.start()
    }
    
    /**
    Starts the nexts step such as walking x steps or turning left/right
    **/
    func nextStep()
    {
        println(actions)
        //TODO
        if let item = actions.first {
            self.actions = Array(dropFirst(self.actions))
            
            if let schritte = item.toInt() {
                self.startStepCounterWithSteptarget(schritte)
                
                self.speechSynthesizer.speak("Gehen Sie nun \(schritte) Schritte geradeaus.", onComplete: {
                })
            } else {
                println(item)
                self.speechSynthesizer.speak("Drehen Sie sich nun nach: \(item).", onComplete: { () -> () in
                    self.nextStep()
                })
            }
        } else {
            //println("Ende")
            self.speechSynthesizer.speak("Sie haben Ihr Ziel erreicht.", onComplete: { () -> () in
                self.stepCounter?.stop()
                self.actions = []
                self.performSegueWithIdentifier("qrcodeReader", sender: self)
            })
        }
    }
    
    /**
    Starts the treasure hunt
    **/
    func start(){
        stepCounter = AccelerometerStepCounter()

        stepCounter.onAccelerationMeasured = {
            (x,y,z,power) -> () in
            self.graphView.addX(0, y: 0, z: power )
        }
        
        nextStep()
    }
    
    @IBAction func unwindFromQRCodeScanner(unwindSegue: UIStoryboardSegue)
    {
        let controller = unwindSegue.sourceViewController as QRCodeReaderViewController
        let dict = controller.contentAsDictionary()
        
        if let input = dict!.objectForKey("input") as? Array<String> {
            self.actions = input
            self.startStation = dict!.objectForKey("startStation") as? Int
            start()
        }
        
        if let endStation = dict!.objectForKey("endStation") as? Int {
            //TODO
            
            if let startStation = self.startStation {
                let result = "{ \"startStation\": \(startStation), \"endStation\": \(endStation) }"
                self.solutionLogger.logSolution(result, taskName: "Schrittzähler")
            } else {
                println("Keine Startstation")
            }
        }
    }
    
}

