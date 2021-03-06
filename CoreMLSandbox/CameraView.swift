//
//  CameraView.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 23/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit
import AVKit
import Accelerate
import CoreImage

class CameraView: UIView {
    
    
    // A capture session. This coordinates the flow of media, from the inputs
    // (the camera) to the outputs (the video handler, which is this class)
    let session = AVCaptureSession()
    
    // The size that incoming pixel buffers should be resized to
    // Defaults to 299x299 because that's the size that Inceptionv3 expects
    var pixelBufferSize : (width: Int, height: Int) = (299,299)
    
    // A preview layer. The output of the capture session will
    // appear in it.
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        
        // Remove any existing inputs
        let inputs = session.inputs
        
        for i in inputs {
            session.removeInput(i)
        }
        
        let deviceTypes = [AVCaptureDevice.DeviceType.builtInWideAngleCamera]
        
        let mediaType = AVMediaType.video
        
        let position = position
        
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: mediaType,
            position: position).devices.first else {
                fatalError("No usable device found.")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            session.addInput(input)
            
        } catch let error {
            fatalError("Failed to connect camera input: \(error)")
        }
    }
    
    func prepareLayer() {
        
        // Default to the rear camera
        setCameraPosition(.back)
        
        // Tell the preview layer to use this session
        previewLayer.session = session
        
        // Make the layer fill the screen
        previewLayer.frame = self.bounds
        
        // Add the layer and make it visible
        self.layer.insertSublayer(previewLayer, at: 0)
        
        // Start the session running
        session.startRunning()
        
        // We get the video data via this AVCaptureVideoDataOutput.
        let captureOutput = AVCaptureVideoDataOutput()
        
        // Tell it that we want to receive the samples as they come in from
        // the session
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(captureOutput)
        
        // Configure the connection between the input and output to make it
        // deliver frames in the right orientation (otherwise the CoreML models
        // get confused)
        let connection = captureOutput.connection(with: .video)
        connection?.videoOrientation = .portrait
        
    }
    
    // Called when this view is created from code.
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        prepareLayer()
    }
    
    // Called when this view is loaded from a nib.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLayer()
    }
    
    // When touched, switch between the rear and front cameras.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Get the current camera position
        let currentCamera = session.inputs.first as? AVCaptureDeviceInput
        let currentPosition = currentCamera?.device.position
        
        // Swap it for the alternative
        switch currentPosition {
        case .front?:
            setCameraPosition(.back)
        case .back?:
            setCameraPosition(.front)
        default:
            // Fall back to the rear camera if we don't know
            setCameraPosition(.back)
        }
        
        // Update the connection to ensure that the video orientation is correct
        let captureOutput = session.outputs.first as? AVCaptureVideoDataOutput
        
        let connection = captureOutput?.connection(with: .video)
        connection?.videoOrientation = .portrait
        
        
    }
    
    // We'll deliver pixel buffers to this delegate every time we get a new frame
    @IBOutlet var delegate : CameraViewDelegate?
    
}

@objc protocol CameraViewDelegate {
    func handle(pixelBuffer: CVPixelBuffer)
}

extension CameraView : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Called when a new frame comes in off the camera.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // We've received a CMSampleBuffer; we want to get its pixel buffer, and
        // produce a scaled version if it
        
        guard let originalPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            fatalError("Failed to convert a sample buffer to a pixel buffer!")
        }
        
        // Deliver it to our delegate
        self.delegate?.handle(pixelBuffer: originalPixelBuffer)
    
    }
}

