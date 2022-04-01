//
//  ImageAnalyzer.swift
//  SwiftScanner
//
//  Created by Anil Santo on 01/08/21.
//

import Foundation
#if canImport(Vision)
import Vision

protocol ImageAnalyzerProtocol: AnyObject {
    func didFinishSuccess<T>(with result: T)
    func didFinishFailure(with result: ScannerError)
}

@available(iOS 13, *)
final class ImageAnalyzer {
    enum Candidate: Hashable {
        case number(String), name(String)
        case expireDate(DateComponents)
    }

    typealias PredictedCount = Int

    private var predictedCardInfo: [Candidate: PredictedCount] = [:]
    private var scannerMode: ScannerMode = .card
    private var scannedCard: CreditCard?
    private var scannedMrzCode: MRZData?
    private weak var delegate: ImageAnalyzerProtocol?
    init(mode: ScannerMode,delegate: ImageAnalyzerProtocol,scannedCard: CreditCard? = nil,scannedMrzCode: MRZData? = nil) {
        self.delegate = delegate
        self.scannerMode = mode
        self.scannedCard = scannedCard
        self.scannedMrzCode = scannedMrzCode
    }

    // MARK: - Vision-related

    public lazy var request: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: requestHandler)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "en-GB"]
        request.usesLanguageCorrection = false
        return request
    }()
    
    func analyze(image: CGImage) {
        let requestHandler = VNImageRequestHandler(
            cgImage: image,
            orientation: .up,
            options: [:]
        )

        do {
            try requestHandler.perform([request])
        } catch {
            let e = ScannerError(kind: .photoProcessing, underlyingError: error)
            self.delegate?.didFinishFailure(with: e)
            delegate = nil
        }
    }

    lazy var requestHandler: ((VNRequest, Error?) -> Void)? = { [weak self] request, _ in
        guard let strongSelf = self else { return }
        
        switch strongSelf.scannerMode {
        case .card:
            strongSelf.parseCardDetails(request: request)
        case .MRZcode:
            strongSelf.parseMRZDetails(request: request)
        default:
            break
        }
    }
    
    func parseCardDetails(request: VNRequest){
        guard let results = request.results as? [VNRecognizedTextObservation],!results.isEmpty else { return }

        var creditCard = CreditCard(number: nil, name: nil, expireDate: nil)
        creditCard.parse(results: results)
        
        var selectedCard = scannedCard
        // Name
        if let name = creditCard.name {
            let count = self.predictedCardInfo[.name(name), default: 0]
            self.predictedCardInfo[.name(name)] = count + 1
            if count > 2 {
                selectedCard?.name = name
            }
        }
        // ExpireDate
        if let date = creditCard.expireDate,let year = date.year,let month = date.month {
            let count = self.predictedCardInfo[.expireDate(date), default: 0]
            self.predictedCardInfo[.expireDate(date)] = count + 1
            let comps = Calendar.current.dateComponents([.year, .month], from: Date())
            if count > 2,comps.year! <= year,month >= comps.month! {
                selectedCard?.expireDate = date
            }
        }

        // Number
        if let number = creditCard.number {
            let count = self.predictedCardInfo[.number(number), default: 0]
            print("+++++++")
            print(number)
            self.predictedCardInfo[.number(number)] = count + 1
            if count > 2,creditCard.checkDigits(number) {
                selectedCard?.number = number
            }
        }

        if selectedCard?.number != nil {
            self.delegate?.didFinishSuccess(with: selectedCard)
            self.delegate = nil
        }
    }
    
    func parseMRZDetails(request: VNRequest){
        guard let results = request.results as? [VNRecognizedTextObservation],!results.isEmpty else { return }
        
        var codes: [String] = []
        let maxCandidates = 1
        let mrzScanData = MRZScanData()
        for result in results {
            guard
                let candidate = result.topCandidates(maxCandidates).first,
                candidate.confidence > 0.1
            else { continue }
            
            let string = candidate.string
            mrzScanData.checkMrz(string: string)
        }
        if !mrzScanData.captureFirst.isEmpty {
            codes.append(mrzScanData.captureFirst)
        }
        else{
            codes.append("")
        }
        if !mrzScanData.captureSecond.isEmpty {
            codes.append(mrzScanData.captureSecond)
        }
        else{
            if !codes.first!.isEmpty {
                codes.append("")
            }
            else{
                codes = []
            }
        }
        if !mrzScanData.captureThird.isEmpty {
            codes.append(mrzScanData.captureThird)
        }
        if !codes.isEmpty {
            var data = MRZData(mrzFormat: nil, documentCode: nil, issuingCountry: nil, lastName: nil, firstName: nil, documentNumber: nil, nationality: nil, dateOfBirth: nil, sex: nil, dateOfExpiry: nil)
            data.parse(results: codes)
            
            if data.hasData() {
                self.delegate?.didFinishSuccess(with: data)
                self.delegate = nil
            }
        }
    }
}
#endif
