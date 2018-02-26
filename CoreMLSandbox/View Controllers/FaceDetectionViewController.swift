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
    
    // A list of layers, each of which draws a box around a detected face.
    var layers : [CALayer] = []
    
    // We create the request once, and use it multiple times.
    lazy var request : VNDetectFaceRectanglesRequest = {
        
        // Create a request to detect faces.
        let request = VNDetectFaceRectanglesRequest() { (request, error) in
            
            guard let observations = request.results as? [VNFaceObservation] else {
                // No observations
                return
            }
            
            DispatchQueue.main.async {
                
                // Remove all rectangles that were previously found.
                for layer in self.layers {
                    layer.removeFromSuperlayer()
                }
                
                // Clear the list of rectangles.
                self.layers = []
                
                // For each face, add a box around it.
                for face in observations {
                    
                    // Create a layer that draws a box around a face.
                    let boxLayer = self.createBoundingBoxLayer(for: face)
                    
                    // Add it to the view, and also add it to the list of layers
                    // so that we can remove it later.
                    self.view.layer.addSublayer(boxLayer)
                    
                    self.layers.append(boxLayer)
                }
            }
        }
        
        return request
    }()
    
    // Creates a layer that's positioned around a face.
    func createBoundingBoxLayer(for face: VNFaceObservation) -> CALayer{
        
        // The VNFaceObservation reports its size and position in ranges of
        // 0 to 1, while the view's coordinate system uses 0 to (screen width/height.)
        // Additionally, the face's coordinates are flipped. We'll need to convert
        // these for it to be positioned correctly.
        
        let size = self.view.frame.size
        
        let transform = CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height)
        
        let translate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
        
        let box = face.boundingBox.applying(translate).applying(transform)
        
        // Now we can create the box!
        
        let boxLayer = CALayer()
        
        boxLayer.frame = box
        boxLayer.borderColor = UIColor.red.cgColor
        boxLayer.backgroundColor = UIColor.clear.cgColor
        boxLayer.borderWidth = 2
        
        return boxLayer
    }
    
    func handle(pixelBuffer: CVPixelBuffer) {
        // We've received a pixel buffer from the camera view. Use it to
        // ask Vision to detect faces.
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        do {
            try handler.perform([request])
        } catch let error {
            print("Error perfoming request: \(error)")
        }
    }

}
