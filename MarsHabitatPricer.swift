//
// MarsHabitatPricer.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MarsHabitatPricerInput : MLFeatureProvider {

    /// Number of solar panels as double value
    var solarPanels: Double

    /// Number of greenhouses as double value
    var greenhouses: Double

    /// Size in acres as double value
    var size: Double
    
    var featureNames: Set<String> {
        get {
            return ["solarPanels", "greenhouses", "size"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "solarPanels") {
            return MLFeatureValue(double: solarPanels)
        }
        if (featureName == "greenhouses") {
            return MLFeatureValue(double: greenhouses)
        }
        if (featureName == "size") {
            return MLFeatureValue(double: size)
        }
        return nil
    }
    
    init(solarPanels: Double, greenhouses: Double, size: Double) {
        self.solarPanels = solarPanels
        self.greenhouses = greenhouses
        self.size = size
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MarsHabitatPricerOutput : MLFeatureProvider {

    /// Price of the habitat (in millions) as double value
    let price: Double
    
    var featureNames: Set<String> {
        get {
            return ["price"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "price") {
            return MLFeatureValue(double: price)
        }
        return nil
    }
    
    init(price: Double) {
        self.price = price
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
class MarsHabitatPricer {
    var model: MLModel

    /**
        Construct a model with explicit path to mlmodel file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    convenience init() {
        let bundle = Bundle(for: MarsHabitatPricer.self)
        let assetPath = bundle.url(forResource: "MarsHabitatPricer", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }

    /**
        Make a prediction using the structured interface
        - parameters:
           - input: the input to the prediction as MarsHabitatPricerInput
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as MarsHabitatPricerOutput
    */
    func prediction(input: MarsHabitatPricerInput) throws -> MarsHabitatPricerOutput {
        let outFeatures = try model.prediction(from: input)
        let result = MarsHabitatPricerOutput(price: outFeatures.featureValue(for: "price")!.doubleValue)
        return result
    }

    /**
        Make a prediction using the convenience interface
        - parameters:
            - solarPanels: Number of solar panels as double value
            - greenhouses: Number of greenhouses as double value
            - size: Size in acres as double value
        - throws: an NSError object that describes the problem
        - returns: the result of the prediction as MarsHabitatPricerOutput
    */
    func prediction(solarPanels: Double, greenhouses: Double, size: Double) throws -> MarsHabitatPricerOutput {
        let input_ = MarsHabitatPricerInput(solarPanels: solarPanels, greenhouses: greenhouses, size: size)
        return try self.prediction(input: input_)
    }
}
