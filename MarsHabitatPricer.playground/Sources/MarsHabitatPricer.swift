//
// MarsHabitatPricer.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML

/// Model Prediction Input Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class MarsHabitatPricerInput : MLFeatureProvider {

    /// Number of solar panels as double value
    public var solarPanels: Double

    /// Number of greenhouses as double value
    public var greenhouses: Double

    /// Size in acres as double value
    public var size: Double
    
    public var featureNames: Set<String> {
        get {
            return ["solarPanels", "greenhouses", "size"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
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
    
    public init(solarPanels: Double, greenhouses: Double, size: Double) {
        self.solarPanels = solarPanels
        self.greenhouses = greenhouses
        self.size = size
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class MarsHabitatPricerOutput : MLFeatureProvider {

    /// Price of the habitat (in millions) as double value
    public let price: Double
    
    public var featureNames: Set<String> {
        get {
            return ["price"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "price") {
            return MLFeatureValue(double: price)
        }
        return nil
    }
    
    public init(price: Double) {
        self.price = price
    }
}


/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public class MarsHabitatPricer {
    var model: MLModel

    /**
        Construct a model with explicit path to mlmodel file
        - parameters:
           - url: the file url of the model
           - throws: an NSError object that describes the problem
    */
    public init(contentsOf url: URL) throws {

        self.model = try MLModel(contentsOf: url)
    }

    /// Construct a model that automatically loads the model from the app's bundle
    public convenience init() {
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
    public func prediction(input: MarsHabitatPricerInput) throws -> MarsHabitatPricerOutput {
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
    public func prediction(solarPanels: Double, greenhouses: Double, size: Double) throws -> MarsHabitatPricerOutput {
        let input_ = MarsHabitatPricerInput(solarPanels: solarPanels, greenhouses: greenhouses, size: size)
        return try self.prediction(input: input_)
    }
}
