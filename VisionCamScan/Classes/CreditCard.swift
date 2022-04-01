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
    
    func checkDigits(_ digits: String) -> Bool {
        guard digits.count == 16, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: digits)) else {
            return false
        }
        var digits = digits
        let checksum = digits.removeLast()
        let sum = digits.reversed()
            .enumerated()
            .map({ (index, element) -> Int in
                if (index % 2) == 0 {
                   let doubled = Int(String(element))!*2
                   return doubled > 9
                       ? Int(String(String(doubled).first!))! + Int(String(String(doubled).last!))!
                       : doubled
                } else {
                    return Int(String(element))!
                }
            })
            .reduce(0, { (res, next) in res + next })
        let checkDigitCalc = (sum * 9) % 10
        return Int(String(checksum))! == checkDigitCalc
    }
}
#endif
