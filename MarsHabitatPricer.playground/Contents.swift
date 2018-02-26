//: Playground - noun: a place where people can play

import UIKit
import CoreML

// Create the model
let model = MarsHabitatPricer()

do {
    
    // Make a prediction, get a result
    let result = try model.prediction(solarPanels: 4, greenhouses: 4, size: 750)
    
    // Get a value from the result
    let price = result.price
    
    // Print it out
    print("The Mars habitat will cost $\(price.rounded()) million.")
    
} catch let error {
    print("Error: \(error)")
}

