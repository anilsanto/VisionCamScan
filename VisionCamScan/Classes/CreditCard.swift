//
//  CreditCard.swift
//  swift_scanner
//
//  Created by Anil Santo on 01/08/21.
//

import Foundation
#if canImport(Vision)
import Vision

public struct CreditCard {
    ///
    public var number: String?
    ///
    public var name: String?
    ///
    public var expireDate: DateComponents?
    
    @available(iOS 13, *)
    mutating func parse(results: [VNRecognizedTextObservation]){
        let creditCardNumber: Regex = #"(?:\d[ -]*?){13,16}"#
        let month: Regex = #"(\d{2})\/\d{2}"#
        let year: Regex = #"\d{2}\/(\d{2})"#
        let wordsToSkip = ["mastercard", "jcb", "visa", "express", "bank", "card", "platinum", "reward"]
        // These may be contained in the date strings, so ignore them only for names
        let invalidNames = ["expiration", "valid", "since", "from", "until", "month", "year"]
        let name: Regex = #"([A-z]{2,}\h([A-z.]+\h)?[A-z]{2,})"#
        
        let maxCandidates = 1
        for result in results {
            guard
                let candidate = result.topCandidates(maxCandidates).first,
                candidate.confidence > 0.1
            else { continue }

            let string = candidate.string
            let containsWordToSkip = wordsToSkip.contains { string.lowercased().contains($0) }
            if containsWordToSkip { continue }
            print(string)
            if let cardNumber = creditCardNumber.firstMatch(in: string)?
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: ""),self.number == nil {
                self.number = cardNumber
                // the first capture is the entire regex match, so using the last
            } else if let month = month.captures(in: string).last.flatMap(Int.init),
                // Appending 20 to year is necessary to get correct century
                let year = year.captures(in: string).last.flatMap({ Int("20" + $0) }) {
                self.expireDate = DateComponents(year: year, month: month)

            } else if let name = name.firstMatch(in: string) {
                let containsInvalidName = invalidNames.contains { name.lowercased().contains($0) }
                if containsInvalidName { continue }
                self.name = name

            } else {
                continue
            }
        }
    }
}
#endif
