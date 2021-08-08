//
//  MRZCode.swift
//  VisionCamScan
//
//  Created by Anil Santo on 02/08/21.
//

import Foundation


#if canImport(Vision)
import Vision

public enum MRZFormat {
    case td1
    case td2
    case td3
}


public struct MRZData {
    public var mrzFormat: MRZFormat?
    
    public var documentCode: String?
    
    public var issuingCountry: String?
    
    public var lastName: String?
     
    public var firstName: String?
    
    public var documentNumber: String?
    
    public var nationality: String?
    
    public var dateOfBirth: DateComponents?
    
    public var sex: String?
    
    public var dateOfExpiry: DateComponents?
    
    
    func hasData()->Bool{
        return self.mrzFormat == nil ? false : true
    }
    
    mutating func parse(results: [String]){
        mrzFormat = findDocFormatType(results: results)
        
        if let format = mrzFormat {
            switch format {
            case .td1:
                //3 Line MRZ   - I.D. documents
                parseTD1Document(results: results)
                break
            case .td2:
                //2 Line MRZ   - I.D. documents
                parseTD3Document(results: results)
                break
            case .td3:
                //2 Line MRZ   - Passport
                parseTD3Document(results: results)
            }
        }
    }
    
    func findDocFormatType(results: [String])-> MRZFormat?{
        if results.count == 2 {
            if results[0].count == 44 || results[1].count == 44 {
                return .td3
            }
            else if results[0].count == 36 || results[1].count == 36{
                return .td2
            }
        }
        else if results.count == 3 {
            if results[0].count == 30 || results[1].count == 30 || results[2].count == 30 {
                return .td1
            }
        }
        return nil
    }
    
    mutating func parseTD1Document(results: [String]){
        let first = results[0]
        if !first.isEmpty {
            //Document Code
            let docCode = getDataFromRange(string: first, start: 0, end: 2)
            if docCode.count > 0,["A","I","C"].contains(docCode.first) {
                self.documentCode = String(docCode.first ?? "I")
                
                //Issuing Country
                let issState = getDataFromRange(string: first, start: 2, end: 5)
                self.issuingCountry = issState
                
                //Document Number
                let docNum = getDataFromRange(string: first, start: 5, end: 14)
                let str = docNum.replacingOccurrences(of: "<", with: "")
                self.documentNumber = str
            }
            else{
                
            }
        }
        let second = results[1]
        if !second.isEmpty {
            //Date Of Dirth
            let dob = getDataFromRange(string: second, start: 0, end: 6)
            self.dateOfBirth = parseDate(date: dob)
            
            //Sex
            let sex = getDataFromRange(string: second, start: 7, end: 8)
            self.sex = sex
            
            //Date Of Expiry
            let dox = getDataFromRange(string: second, start: 8, end: 14)
            self.dateOfExpiry = parseDate(date: dox)
            
            //Nationality
            let nat = getDataFromRange(string: second, start: 15, end: 18)
            self.nationality = nat
        }
        
        let thrid = results[2]
        if !thrid.isEmpty {
            //Name
            let name = getDataFromRange(string: thrid, start: 0, end: 30)
            let names = parseName(name: name)
            if names.count > 1 {
                self.firstName = names[1]
                self.lastName = names.first
            }
        }
    }
    
    mutating func parseTD3Document(results: [String]){
        let first = results[0]
        if !first.isEmpty {
            //Document Code
            let docCode = getDataFromRange(string: first, start: 0, end: 2)
            if docCode.count > 0 {
                self.documentCode = String(docCode.first ?? "P")
            }
            
            //Issuing Country
            let issState = getDataFromRange(string: first, start: 2, end: 5)
            self.issuingCountry = issState
            
            //Name
            let name = getDataFromRange(string: first, start: 5, end: 44)
            let names = parseName(name: name)
            if names.count > 1 {
                self.firstName = names[1]
                self.lastName = names.first
            }
        }
        let second = results[1]
        if !second.isEmpty {
            //Document Number
            let docNum = getDataFromRange(string: second, start: 0, end: 9)
            let str = docNum.replacingOccurrences(of: "<", with: "")
            self.documentNumber = str
            
            //Nationality
            let nat = getDataFromRange(string: second, start: 10, end: 13)
            self.nationality = nat
            
            //Date Of Dirth
            let dob = getDataFromRange(string: second, start: 13, end: 19)
            self.dateOfBirth = parseDate(date: dob)
            
            let sex = getDataFromRange(string: second, start: 20, end: 21)
            self.sex = sex
            
            //Date Of Expiry
            let dox = getDataFromRange(string: second, start: 21, end: 27)
            self.dateOfExpiry = parseDate(date: dox)
        }
    }
    
    func parseDate(date: String)->DateComponents? {
        let year = getDataFromRange(string: date, start: 0, end: 2)
        let month = getDataFromRange(string: date, start: 2, end: 4)
        let day = getDataFromRange(string: date, start: 4, end: 6)
        
        return DateComponents(year: Int(year),month: Int(month),day: Int(day))
    }
    
    func parseName(name: String)->[String] {
        let components = name.components(separatedBy: "<<")
        var nameComponents: [String] = []
        for component in components {
            if !component.isEmpty {
                let str = component.replacingOccurrences(of: "<", with: " ")
                nameComponents.append(str)
            }
        }
        return nameComponents
    }
    
    
    
    func getDataFromRange(string: String,start: Int,end: Int)->String {
        let start = string.index(string.startIndex, offsetBy: start)
        let end = string.index(string.startIndex, offsetBy: end)
        let range = start..<end
        return String(string[range])
    }
    
}


#endif
