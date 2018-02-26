//
//  SentimentClassifierViewController.swift
//  CoreMLSandbox
//
//  Created by Jon Manning on 26/2/18.
//  Copyright © 2018 Jon Manning. All rights reserved.
//

import UIKit

class SentimentClassifierViewController: UIViewController, UITextViewDelegate {
    
    enum Sentiment {
        case unknown, positive, negative
        
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
    
    let model = SentimentPolarity()

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = ""
        
        self.textViewDidChange(self.textView)
    }
    
    let taggingOptions: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther]
    
    lazy var tagger: NSLinguisticTagger = NSLinguisticTagger(
        tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"),
        options: Int(taggingOptions.rawValue)
    )
    
    func extractFeatures(from text: String) -> [String:Double] {
        
        var result : [String: Double] = [:]
        
        tagger.string = text
        
        let range = NSRange(location: 0, length: text.count)
        
        tagger.enumerateTags(in: range, scheme: .nameType, options: taggingOptions) { _, tokenRange, _, _ in
            
            let token = (text as NSString).substring(with: tokenRange).lowercased()
            
            // Skip any word smaller than 3 characters
            guard token.count >= 3 else {
                return
            }
            
            result[token, default: 0] += 1
        }
        
        return result
        
        
    }
    
    func detectSentiment(from text: String) -> Sentiment {
        
        let features = extractFeatures(from: text)
        
        if features.count == 0 {
            return Sentiment.unknown
        }
        
        do {
            let result = try model.prediction(input: features)
            
            return Sentiment(classString: result.classLabel)
        } catch {
            return .unknown
        }
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let sentiment = detectSentiment(from: textView.text)
        
        resultLabel.text = sentiment.emojiRepresentation
        
    }

}
