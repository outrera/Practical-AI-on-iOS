//
//  ObjectDetectionViewController.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 26/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit
import Vision

class ObjectDetectionViewController: UIViewController, CameraViewDelegate {
    
    // The label we're showing our predictions in.
    @IBOutlet weak var resultLabel: UILabel!
    
    // The Inceptionv3 CoreML model.
    let model = Inceptionv3()
    
    // We create the request once, and use it multiple times.
    lazy var request : VNCoreMLRequest = {
        
        let request : VNCoreMLRequest
        
        guard let visionModel = try? VNCoreMLModel(for: model.model) else {
            fatalError("Failed to create VNCoreMLModel for MLModel")
        }
        
        request = VNCoreMLRequest(model: visionModel) { request, error in
            
            // Ensure that this is an array of results
            guard let observations = request.results as? [VNClassificationObservation] else {
                // Not the right type
                return
            }
            
            // Ensure that we have at least one observation
            guard let observation = observations.first else {
                // No observations
                return
            }
            
            // This callback will happen on a background thread, and we can only
            // update the UI on the main thread, so we fix that
            
            DispatchQueue.main.async {
                
                let name = observation.identifier
                let confidencePercent = Int(observation.confidence * 100)
                
                let label = "\(name) (\(confidencePercent)%)"
                
                self.resultLabel.text = label
            }
        }
        
        return request
    }()
    
    func handle(pixelBuffer: CVPixelBuffer) {
        // We've received a pixel buffer from the camera view. Use it to
        // ask Vision to classify its contents.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        do {
            try handler.perform([request])
        } catch let error {
            print("Error perfoming request: \(error)")
        }
    }

}
