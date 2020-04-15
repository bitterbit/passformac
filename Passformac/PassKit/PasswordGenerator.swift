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
    private static let PUNCT : [String] = ".?!,:;-?()[]{}".map { String($0) }
    
    private let punctChance = 4
    private let numberChance = 3
    private let maxRandomNumber = 99
    
    // Settings
    var numWords : Int = 4
    var minWordLength : Int = 4 { didSet { potentialWords = filterWords() } }
    var maxWordLength : Int = 8 { didSet { potentialWords = filterWords() } }
    var separator: String = ""
    var capitalizeFirst : Bool = true
    
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
        var words = self.words(numWords)
        
        if self.capitalizeFirst {
            let caps = words.dropFirst().map { self.capFirstLetter($0) }
            words = [words.first!] + caps
        }
        
        return words.joined()
    }
    
    private func filterWords() -> [String] {
        return words.filter { word in
            word.utf8.count >= minWordLength && word.utf8.count <= maxWordLength
        }
    }
    
    private func words(_ count: Int) -> [String] {
        var words = [String]()
        for i in 0...count {
            if i > 0 && i < count  {
                if randomOneOutOf(numberChance) {
                    words.append("\(Int.random(in:0...maxRandomNumber))")
                }
                if randomOneOutOf(punctChance) {
                    words.append(getRandomPunct(1))
                }
            }
            
            words.append(potentialWords.randomElement()!)
        }
        return words
    }
    
    private func capFirstLetter(_ str: String) -> String {
        return str.prefix(1).capitalized + str.dropFirst()
    }
    
    private func getRandomPunct(_ num: Int) -> String {
        let puncts = (1...num).compactMap {_ in
            MemorablePasswordGenerator.PUNCT.randomElement()
        }
        return puncts.joined()
    }
    
    /*
     1 - 100%, 2 - 50%, 3 - 33%, etc...
     */
    private func randomOneOutOf(_ num: Int) -> Bool {
        return Int.random(in: 1...num) == 1
    }
}
