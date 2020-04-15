//
//  PasswordGenerator.swift
//  Passformac
//
//  Created by Gal on 15/04/2020.
//  Copyright © 2020 galtashma. All rights reserved.
//

import Foundation
import AppKit

class MemorablePasswordGenerator {
    private static let RESOURCE_NAME = "google-10000-en"
    
    // Settings
    var numWords : Int = 4
    var minWordLength : Int = 4 { didSet { potentialWords = filterWords() } }
    var maxWordLength : Int = 8 { didSet { potentialWords = filterWords() } }
    var separator: String = "-"
    
    private let words: [String]
    private lazy var potentialWords = filterWords()
    
    init () {
        let asset = NSDataAsset(name: MemorablePasswordGenerator.RESOURCE_NAME)!
        let content = String(data: asset.data, encoding: .utf8)!
        self.words = content.components(separatedBy: "\n")
    }
    
    // Level of entropy for passphrases generated with current settings.
    // Approximate "bits of entropy," e.g. 2^N possibilities.
    var entropy: Double {
        log2(pow(Double(potentialWords.count), Double(numWords)))
    }
    
    func generate() -> String {
        return words(numWords).joined(separator: separator)
    }
    
    private func filterWords() -> [String] {
        return words.filter { word in
            word.utf8.count >= minWordLength && word.utf8.count <= maxWordLength
        }
    }
    
    private func words(_ count: Int) -> [String] {
        var words = [String]()
        for _ in 0...count {
            words.append(potentialWords.randomElement()!)
        }
        return words
    }
}
