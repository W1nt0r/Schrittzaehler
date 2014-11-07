//
//  QRCodeReaderViewController.swift
//  Schatzsuche
//
//  Created by Sebastian Hunkeler on 18/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var session: AVCaptureSession
    var device:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var input:AVCaptureDeviceInput?
    var output:AVCaptureMetadataOutput
    var previewLayer:AVCaptureVideoPreviewLayer
    var highlightView:UIView
    var qrCodeContent:String?
    
    required init(coder aDecoder: NSCoder) {
        highlightView = UIView()
        highlightView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin
        highlightView.layer.borderColor = UIColor.greenColor().CGColor
        highlightView.layer.borderWidth = 3
        session = AVCaptureSession()

        let preset = AVCaptureSessionPresetHigh
        if(session.canSetSessionPreset(preset)) {
            session.sessionPreset = preset
        }
        
        output = AVCaptureMetadataOutput()
        previewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as AVCaptureVideoPreviewLayer
        super.init(coder: aDecoder)
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
        self.view.layer.addSublayer(previewLayer)
        session.startRunning()
        
        self.view.bringSubviewToFront(highlightView)
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRectZero
        var barCodeObject: AVMetadataMachineReadableCodeObject
        var detectionString:String?
        self.highlightView.frame = highlightViewRect
        
        for metadata in metadataObjects {
            if let metadataObject = metadata as? AVMetadataObject {

                if (metadataObject.type == AVMetadataObjectTypeQRCode) {
                    barCodeObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject) as AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    
                    if let machineReadableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                        detectionString = machineReadableObject.stringValue
                    }
                }
                
                if (detectionString != nil) {
                    self.qrCodeContent = detectionString
                    self.session.stopRunning()
                    self.performSegueWithIdentifier("unwindToMainScreen", sender: self)
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
    
    func contentAsDictionary() -> NSDictionary? {
        let inputData = qrCodeContent!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var error:NSError?
        var dict: NSDictionary? = NSJSONSerialization.JSONObjectWithData(inputData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as? NSDictionary
        return dict
    }
}
