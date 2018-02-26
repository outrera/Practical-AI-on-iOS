//
//  FaceDetectionViewController.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 26/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit
import Vision
import CoreVideo

class FaceDetectionViewController: UIViewController, CameraViewDelegate {
    
    var layers : [CALayer] = []
    
    // We create the request once, and use it multiple times.
    lazy var request : VNDetectFaceLandmarksRequest = {
        
        let request : VNDetectFaceLandmarksRequest
        
        request = VNDetectFaceLandmarksRequest() { (request, error) in
            
            guard let observations = request.results as? [VNFaceObservation] else {
                // No observations
                return
            }
            
            DispatchQueue.main.async {
                
                for layer in self.layers {
                    layer.removeFromSuperlayer()
                }
                
                self.layers = []
                
                for face in observations {
                    
                    let boxLayer = self.createBoundingBoxLayer(for: face)
                    
                    self.view.layer.addSublayer(boxLayer)
                    
                    self.layers.append(boxLayer)
                }
                
            }
            
            
        }
        
        return request
    }()
    
    func createBoundingBoxLayer(for face: VNFaceObservation) -> CALayer{
        let size = self.view.frame.size
        
        let transform = CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
        
        let box = face.boundingBox.applying(translate).applying(transform)
        
        let boxLayer = CALayer()
        
        boxLayer.frame = box
        boxLayer.borderColor = UIColor.red.cgColor
        boxLayer.backgroundColor = UIColor.clear.cgColor
        boxLayer.borderWidth = 2
        
        return boxLayer
    }
    
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
