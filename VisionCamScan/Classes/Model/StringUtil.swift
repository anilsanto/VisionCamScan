//
//  StringUtil.swift
//  VisionCamScan
//
//  Created by Anil Santo on 02/08/21.
//

import Foundation

//var captureFirst = ""
//var captureSecond = ""
//var captureThird = ""
//var mrz = ""
//var temp_mrz = ""
//
extension String {
//
//    func resetMrz(){
//        captureFirst = ""
//        captureSecond = ""
//        captureThird = ""
//        mrz = ""
//        temp_mrz = ""
//    }
//
//    func checkMrz() -> (String)? {
//
//        let tdOneFirstRegex = "(I|C|A).[A-Z0<]{3}[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0-9<]{14,22}"
//        let tdOneSecondRegex = "[0-9O]{7}(M|F|<)[0-9O]{7}[A-Z0<]{3}[A-Z0-9<]{11}[0-9O]"
//        let tdOneThirdRegex = "([A-Z0]+<)+<([A-Z0]+<)+<+"
//        let tdOneMrzRegex = "(I|C|A).[A-Z0<]{3}[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0-9<]{14,22}\n[0-9O]{7}(M|F|<)[0-9O]{7}[A-Z0<]{3}[A-Z0-9<]{11}[0-9O]\n([A-Z0]+<)+<([A-Z0]+<)+<+"
//
//        let tdThreeFirstRegex = "P.[A-Z0<]{3}([A-Z0]+<)+<([A-Z0]+<)+<+"
//        let tdThreeSecondRegex = "[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0<]{3}[0-9]{7}(M|F|<)[0-9O]{7}[A-Z0-9<]+"
//        let tdThreeMrzRegex = "P.[A-Z0<]{3}([A-Z0]+<)+<([A-Z0]+<)+<+\n[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0<]{3}[0-9]{7}(M|F|<)[0-9O]{7}[A-Z0-9<]+"
//
//        let tdOneFirstLine = self.range(of: tdOneFirstRegex, options: .regularExpression, range: nil, locale: nil)
//        let tdOneSecondLine = self.range(of: tdOneSecondRegex, options: .regularExpression, range: nil, locale: nil)
//        let tdOneThirdLine = self.range(of: tdOneThirdRegex, options: .regularExpression, range: nil, locale: nil)
//
//        let tdThreeFirstLine = self.range(of: tdThreeFirstRegex, options: .regularExpression, range: nil, locale: nil)
//        let tdThreeSeconddLine = self.range(of: tdThreeSecondRegex, options: .regularExpression, range: nil, locale: nil)
//
//        if(tdOneFirstLine != nil){
//            if(self.count == 30){
//                captureFirst = self
//            }
//        }
//        if(tdOneSecondLine != nil){
//            if(self.count == 30){
//                captureSecond = self
//            }
//        }
//        if(tdOneThirdLine != nil){
//            if(self.count == 30){
//                captureThird = self
//            }
//        }
//
//        if(tdThreeFirstLine != nil){
//            if(self.count == 44){
//                captureFirst = self
//            }
//        }
//
//        if(tdThreeSeconddLine != nil){
//            if(self.count == 44){
//                captureSecond = self
//            }
//        }
//
//
//        if(captureFirst.count == 30 && captureSecond.count == 30 && captureThird.count == 30){
//            temp_mrz = (captureFirst.stripped + "\n" + captureSecond.stripped + "\n" + captureThird.stripped).replacingOccurrences(of: " ", with: "<")
//
//            let checkMrz = temp_mrz.range(of: tdOneMrzRegex, options: .regularExpression, range: nil, locale: nil)
//            if(checkMrz != nil){
//                mrz = temp_mrz
//            }
//        }
//
//        if(captureFirst.count == 44 && captureSecond.count == 44){
//            temp_mrz = (captureFirst.stripped + "\n" + captureSecond.stripped).replacingOccurrences(of: " ", with: "<")
//
//            let checkMrz = temp_mrz.range(of: tdThreeMrzRegex, options: .regularExpression, range: nil, locale: nil)
//            if(checkMrz != nil){
//                mrz = temp_mrz
//            }
//        }
//
//        if(mrz == ""){
//            return nil
//        }
//        return mrz
//    }
//
    var stripped: String {
        let okayChars = Set("ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890<")
        return self.filter {okayChars.contains($0) }
    }
}

class MRZScanData {
    var captureFirst = ""
    var captureSecond = ""
    var captureThird = ""
    var mrz = ""
    var temp_mrz = ""
    
    func checkMrz(string: String) {

        let tdOneFirstRegex = "(I|C|A).[A-Z0<]{3}[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0-9<]{14,22}"
        let tdOneSecondRegex = "[0-9O]{7}(M|F|<)[0-9O]{7}[A-Z0<]{3}[A-Z0-9<]{11}[0-9O]"
        let tdOneThirdRegex = "([A-Z0]+<)+<([A-Z0]+<)+<+"
        let tdOneMrzRegex = "(I|C|A).[A-Z0<]{3}[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0-9<]{14,22}\n[0-9O]{7}(M|F|<)[0-9O]{7}[A-Z0<]{3}[A-Z0-9<]{11}[0-9O]\n([A-Z0]+<)+<([A-Z0]+<)+<+"
        
        let tdThreeFirstRegex = "P.[A-Z0<]{3}([A-Z0]+<)+<([A-Z0]+<)+<+"
        let tdThreeSecondRegex = "[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0<]{3}[0-9]{7}(M|F|<)[0-9O]{7}[A-Z0-9<]+"
        let tdThreeMrzRegex = "P.[A-Z0<]{3}([A-Z0]+<)+<([A-Z0]+<)+<+\n[A-Z0-9]{1,9}<?[0-9O]{1}[A-Z0<]{3}[0-9]{7}(M|F|<)[0-9O]{7}[A-Z0-9<]+"
        
        let tdOneFirstLine = string.range(of: tdOneFirstRegex, options: .regularExpression, range: nil, locale: nil)
        let tdOneSecondLine = string.range(of: tdOneSecondRegex, options: .regularExpression, range: nil, locale: nil)
        let tdOneThirdLine = string.range(of: tdOneThirdRegex, options: .regularExpression, range: nil, locale: nil)

        let tdThreeFirstLine = string.range(of: tdThreeFirstRegex, options: .regularExpression, range: nil, locale: nil)
        let tdThreeSeconddLine = string.range(of: tdThreeSecondRegex, options: .regularExpression, range: nil, locale: nil)
        
        if(tdOneFirstLine != nil){
            if(string.count == 30){
                captureFirst = string
            }
        }
        if(tdOneSecondLine != nil){
            if(string.count == 30){
                captureSecond = string
            }
        }
        if(tdOneThirdLine != nil){
            if(string.count == 30){
                captureThird = string
            }
        }

        if(tdThreeFirstLine != nil){
            if(string.count == 44){
                captureFirst = string
            }
        }
        
        if(tdThreeSeconddLine != nil){
            if(string.count == 44){
                captureSecond = string
            }
        }
        
        
//        if(captureFirst.count == 30 && captureSecond.count == 30 && captureThird.count == 30){
//            temp_mrz = (captureFirst.stripped + "\n" + captureSecond.stripped + "\n" + captureThird.stripped).replacingOccurrences(of: " ", with: "<")
//
//            let checkMrz = temp_mrz.range(of: tdOneMrzRegex, options: .regularExpression, range: nil, locale: nil)
//            if(checkMrz != nil){
//                mrz = temp_mrz
//            }
//        }
//
//        if(captureFirst.count == 44 && captureSecond.count == 44){
//            temp_mrz = (captureFirst.stripped + "\n" + captureSecond.stripped).replacingOccurrences(of: " ", with: "<")
//
//            let checkMrz = temp_mrz.range(of: tdThreeMrzRegex, options: .regularExpression, range: nil, locale: nil)
//            if(checkMrz != nil){
//                mrz = temp_mrz
//            }
//        }
//
//        if(mrz == ""){
//            return nil
//        }
//        return mrz
    }
}