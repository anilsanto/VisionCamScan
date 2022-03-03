//
//  StringUtil.swift
//  VisionCamScan
//
//  Created by Anil Santo on 02/08/21.
//

import Foundation

class MRZScanData {
    var captureFirst = ""
    var captureSecond = ""
    var captureThird = ""
    var mrz = ""
    var temp_mrz = ""
    
    func checkMrz(string: String) {

        let tdOneFirstRegex: Regex = "(I|C|A).[A-Z0<]{3}[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0-9<]{14,22}"
        let tdOneSecondRegex: Regex = "[0-9O]{7}(M|F|<)[0-9O]{7}[A-Z0<]{3}[A-Z0-9<]{11}[0-9O]"
        let tdOneThirdRegex: Regex = "([A-Z0]+<)+<([A-Z0]+<)+<+"
        _ = "(I|C|A).[A-Z0<]{3}[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0-9<]{14,22}\n[0-9O]{7}(M|F|<)[0-9O]{7}[A-Z0<]{3}[A-Z0-9<]{11}[0-9O]\n([A-Z0]+<)+<([A-Z0]+<)+<+"
        
        let tdThreeFirstRegex: Regex = "P.[A-Z0<]{3}([A-Z0]+<)+<([A-Z0]+<)+<+"
        let tdThreeSecondRegex: Regex = "[A-Z0-9<]{1,9}[0-9]{1}[A-Z0<]{3}[0-9]{7}[A-Z<]{1}[0-9]{7}[A-Z0-9<]+"
        _ = "P.[A-Z0<]{3}([A-Z0]+<)+<([A-Z0]+<)+<+\n[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0<]{3}[0-9]{7}(M|F|<)[0-9O]{7}[A-Z0-9<]+"
        
//        let tdOneFirstLine = string.range(of: tdOneFirstRegex, options: .regularExpression, range: nil, locale: nil)
//        let tdOneSecondLine = string.range(of: tdOneSecondRegex, options: .regularExpression, range: nil, locale: nil)
//        let tdOneThirdLine = string.range(of: tdOneThirdRegex, options: .regularExpression, range: nil, locale: nil)

//        let tdThreeFirstLine = string.range(of: tdThreeFirstRegex, options: .regularExpression, range: nil, locale: nil)
//        let tdThreeSeconddLine = string.range(of: tdThreeSecondRegex, options: .regularExpression, range: nil, locale: nil)
        
        if tdOneFirstRegex.firstMatch(in: string) != nil,captureFirst.isEmpty {
            if string.count == 30{
                captureFirst = string
            }
        }
        else if tdOneSecondRegex.firstMatch(in: string) != nil,captureSecond.isEmpty {
            if string.count == 30{
                captureSecond = string
            }
        }
        else if tdOneThirdRegex.firstMatch(in: string) != nil,captureThird.isEmpty {
            if string.count == 30{
                captureThird = string
            }
        }
        if tdThreeFirstRegex.firstMatch(in: string) != nil,captureFirst.isEmpty {
            if string.count == 44{
                captureFirst = string
            }
        }
        else if tdThreeSecondRegex.firstMatch(in: string) != nil,captureSecond.isEmpty {
            if string.count == 44{
                captureSecond = string
            }
        }
    }
}
