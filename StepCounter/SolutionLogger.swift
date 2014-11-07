//
//  SolutionLogger.swift
//  Logbuch
//
//  Created by Sebastian Hunkeler on 08/09/14.
//  Copyright (c) 2014 HSR. All rights reserved.
//

import UIKit
import AVFoundation

let logbookScheme = "appquest"

public class SolutionLogger: NSObject {
    
    var taskName: String!
    var solution: String!
    var viewController:UIViewController!
    
    public required init(viewController:UIViewController) {
        self.viewController = viewController
    }
    
    private func urlEncode(string:String) -> String? {
        return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
    }
    
    public func logSolution(solution:String, taskName:String){
        let path = "\(logbookScheme)://\(urlEncode(taskName)!)/\(urlEncode(solution)!)"
        UIApplication.sharedApplication().openURL(NSURL(string: path)!)
    }
    
    public func logSolutionFromQRCode(taskName:String){
        logSolutionFromQRCode(taskName, solution: nil)
    }
    
    public func logSolutionFromQRCode(taskName:String, solution:String?){
        self.solution = solution
        self.taskName = taskName
        let reader = QRCodeReaderViewController(nibName: nil,bundle: nil)
        reader.onCodeDetected = { code in
            
            self.solution = self.urlEncode( solution == nil ? code : "\(code):" + solution! )
            
            reader.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.logSolution(self.solution, taskName: self.taskName)
            })
        }
        viewController.presentViewController(reader, animated: true, completion: nil)
    }
    
    internal class QRCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
    {
        var session: AVCaptureSession
        var device:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var input:AVCaptureDeviceInput?
        var output:AVCaptureMetadataOutput
        var previewLayer:AVCaptureVideoPreviewLayer
        var highlightView:UIView
        var qrCodeContent:String?
        var onCodeDetected:((String) -> ())? = nil
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
            highlightView = UIView()
            highlightView.layer.borderColor = UIColor.greenColor().CGColor
            highlightView.layer.borderWidth = 3
            session = AVCaptureSession()
            
            let preset = AVCaptureSessionPresetHigh
            if(session.canSetSessionPreset(preset)) {
                session.sessionPreset = preset
            }
            
            output = AVCaptureMetadataOutput()
            previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as AVCaptureVideoPreviewLayer
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        required convenience init(coder aDecoder: NSCoder) {
            self.init(nibName: nil,bundle: nil)
        }
        
        override func viewDidLayoutSubviews() {
            previewLayer.frame = view.bounds
        }
        
        override func viewDidLoad()
        {
            super.viewDidLoad()
            
            self.view.addSubview(highlightView)
            var error:NSError?
            
            input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput
            
            if let captureInput = input {
                session.addInput(captureInput)
            } else {
                println("Error: \(error?.description)")
            }
            
            output.setMetadataObjectsDelegate(self, queue:dispatch_get_main_queue())
            session.addOutput(output)
            
            output.metadataObjectTypes = output.availableMetadataObjectTypes
            
            previewLayer.frame = self.view.bounds;
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            view.layer.addSublayer(previewLayer)
            session.startRunning()
            
            self.view.bringSubviewToFront(highlightView)
        }
        
        
        func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
            
            var highlightViewRect = CGRectZero
            var barCodeObject: AVMetadataMachineReadableCodeObject
            var detectionString:String?
            highlightView.frame = highlightViewRect
            
            for metadata in metadataObjects {
                if let metadataObject = metadata as? AVMetadataObject {
                    
                    if (metadataObject.type == AVMetadataObjectTypeQRCode) {
                        barCodeObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject) as AVMetadataMachineReadableCodeObject
                        highlightViewRect = barCodeObject.bounds
                        
                        if let machineReadableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                            detectionString = machineReadableObject.stringValue
                            highlightView.frame = highlightViewRect
                        }
                    }
                    
                    if (detectionString != nil) {
                        self.qrCodeContent = detectionString
                        self.session.stopRunning()
                        onCodeDetected?(self.qrCodeContent!)
                        return
                    }
                }
            }
        }
        
        override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
            switch toInterfaceOrientation {
            case UIInterfaceOrientation.Portrait :
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                break
            case UIInterfaceOrientation.PortraitUpsideDown :
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
                break
            case UIInterfaceOrientation.LandscapeLeft :
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                break
            case UIInterfaceOrientation.LandscapeRight :
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                break
            default:
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            }
        }
    }
}