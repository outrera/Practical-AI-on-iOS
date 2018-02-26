//
//  SentimentClassifierViewController.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 26/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit

class SentimentClassifierViewController: UIViewController, UITextViewDelegate {
    
    // A sentiment. Either positive, negative, or unknown.
    enum Sentiment {
        case unknown, positive, negative
        
        // Sentiments can provide a string containing an emoji.
        var emojiRepresentation : String {
            switch self {
            case .unknown:
                return "😐"
            case .positive:
                return "😃"
            case .negative:
                return "☹️"
            }
        }
        
        // Sentiments can be created with a string. (These strings are the possible
        // values that the SentimentPolarity model can produce.)
        
        init(classString: String) {
            switch classString {
            case "Pos":
                self = .positive
            case "Neg":
                self = .negative
            default:
                self = .unknown
            }
        }
    }
    
    // Prepare our model.
    let model = SentimentPolarity()

    // The label that we'll show our results in.
    @IBOutlet weak var resultLabel: UILabel!
    
    // The text view that contains the string we're analysing.
    @IBOutlet weak var textView: UITextView!
    
    // Options for configuring the tagger.
    let taggingOptions: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    
    // The NSLinguisticTagger can break apart a string based on its semantic information.
    // (It's a better method than just splitting based on strings.)
    lazy var tagger: NSLinguisticTagger = NSLinguisticTagger(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: Int(taggingOptions.rawValue)
    )
    
    // When the screen appears, empty the text view, ensure that the results
    // show neutral, and start editing the text view.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = ""
        
        self.textViewDidChange(self.textView)
        
        self.textView.becomeFirstResponder()
    }
    
    // Extract a feature vector from the string by counting the number of times
    // a word appears in the text.
    func extractFeatures(from text: String) -> [String:Double] {
        
        // We'll end up returning this dictionary.
        var result : [String: Double] = [:]
        
        // Start tagging the string
        tagger.string = text
        
        let range = NSRange(location: 0, length: text.count)
        
        tagger.enumerateTags(in: range, scheme: .nameType, options: taggingOptions) { _, tokenRange, _, _ in
            
            // Get the word
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            
            // Skip any word smaller than 3 characters
            guard token.count >= 3 else {
                return
            }
            
            // Add it to the results
            result[token, default: 0] += 1
        }
        
        return result
        
        
    }
    
    // Given a string, use the CoreML model to detect its overall sentiment.
    func detectSentiment(from text: String) -> Sentiment {
        
        // Get the features from the string - a dictionary containing word counts.
        let features = extractFeatures(from: text)
        
        // If we didn't have any, report neutral
        if features.count == 0 {
            return Sentiment.unknown
        }
        
        // Perform the prediction and return the detected sentiment.
        do {
            let result = try model.prediction(input: features)
            
            return Sentiment(classString: result.classLabel)
        } catch {
            return .unknown
        }
        
        
    }
    
    // Called when the text view changes.
    func textViewDidChange(_ textView: UITextView) {
        
        // Detect the sentiment from the text.
        let sentiment = detectSentiment(from: textView.text)
        
        // Update the result label with the appropriate emoji.
        resultLabel.text = sentiment.emojiRepresentation
        
    }

}
