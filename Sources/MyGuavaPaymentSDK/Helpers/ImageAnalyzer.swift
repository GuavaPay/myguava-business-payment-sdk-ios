//
// MyGuava
// Copyright © MyGuava. All rights reserved.
//

import Foundation
#if canImport(Vision)
    import Vision

    protocol ImageAnalyzerProtocol: AnyObject {
        func didFinishAnalyzation(with result: Result<CardScannerModel, CardScannerError>)
    }

    @available(iOS 13, *)
    final class ImageAnalyzer {
        enum Candidate: Hashable {
            case number(String)
            case name(String)
            case expireDate(DateComponents)
        }

        typealias PredictedCount = Int

        private var selectedCard = CardScannerModel()
        private var predictedCardInfo: [Candidate: PredictedCount] = [:]

        private weak var delegate: ImageAnalyzerProtocol?

        /// Recognition queue
        private let textRecognitionWorkQueue = DispatchQueue(
            label: "TextRecognitionQueue",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .workItem
        )

        private lazy var request = VNRecognizeTextRequest(completionHandler: requestHandler)

        init(delegate: ImageAnalyzerProtocol) {
            self.delegate = delegate
            request.usesLanguageCorrection = false
            request.minimumTextHeight = 0.02 // Lower = better quality
            request.recognitionLevel = .accurate
        }

        // MARK: - Vision-related

        func analyze(image: CGImage) {
            textRecognitionWorkQueue.async {
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try requestHandler.perform([self.request])
                } catch {
                    let e = CardScannerError(kind: .photoProcessing, underlyingError: error)
                    self.delegate?.didFinishAnalyzation(with: .failure(e))
                    self.delegate = nil
                }
            }
        }

        lazy var requestHandler: ((VNRequest, Error?) -> Void)? = { [weak self] request, _ in
            guard let self else {
                return
            }
            // For cards with digits structure = :::: ::::
            let squareCardNumberDigits: ScannerRegex = #"(?:\d[ -]*?){8,12}"#
            // For cards with horizontal and vertical digits structure
            let cardNumberDigits: ScannerRegex = #"(?:\d[ -]*?){4}"#
            let CardNumber: ScannerRegex = #"(?:\d[ -]*?){13,19}"#
            let month: ScannerRegex = #"(\d{2})\/\d{2}"#
            let year: ScannerRegex = #"\d{2}\/(\d{2})"#
            let wordsToSkip = ["mastercard", "jcb", "visa", "express", "bank", "card", "platinum", "reward"]
            // These may be contained in the date strings, so ignore them only for names
            let invalidNames = ["expiration", "valid", "since", "from", "until", "month", "year"]
            let name: ScannerRegex = #"([A-z]{2,}\h([A-z.]+\h)?[A-z]{2,})"#

            guard let results = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            var Card = CardScannerModel(number: nil, name: nil, expireDate: nil)

            let maxCandidates = 1
            for result in results {
                guard
                    let candidate = result.topCandidates(maxCandidates).first,
                    candidate.confidence > 0.1 else {
                    continue
                }

                let string = candidate.string
                let containsWordToSkip = wordsToSkip.contains { string.lowercased().contains($0) }
                if containsWordToSkip {
                    continue
                }

                if let cardNumber = CardNumber.firstMatch(in: string)?
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: "") {
                    Card.number = cardNumber

                    // the first capture is the entire regex match, so using the last
                } else if let cardNumber = squareCardNumberDigits.firstMatch(in: string)?
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: ""),
                    !CardNumber.hasMatch(in: Card.number ?? "") {
                    var enteredCardNumber: String = Card.number ?? ""
                    enteredCardNumber += cardNumber
                    Card.number = enteredCardNumber
                } else if let cardNumber = cardNumberDigits.firstMatch(in: string)?
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: ""),
                    !CardNumber.hasMatch(in: Card.number ?? "") {
                    var enteredCardNumber: String = Card.number ?? ""
                    enteredCardNumber += cardNumber
                    Card.number = enteredCardNumber
                } else if let month = month.captures(in: string).last.flatMap(Int.init),
                          // Appending 20 to year is necessary to get correct century
                          let year = year.captures(in: string).last.flatMap({ Int("20" + $0) }) {
                    Card.expireDate = DateComponents(year: year, month: month)
                } else if let name = name.firstMatch(in: string) {
                    let containsInvalidName = invalidNames.contains { name.lowercased().contains($0) }
                    if containsInvalidName {
                        continue
                    }
                    Card.name = name
                } else {
                    continue
                }
            }

            if let name = Card.name {
                let count = self.predictedCardInfo[.name(name), default: 0]
                self.predictedCardInfo[.name(name)] = count + 1
                if count > 2 {
                    self.selectedCard.name = name
                }
            }

            if let dateFromMilliseconds = Card.expireDate {
                let count = self.predictedCardInfo[.expireDate(dateFromMilliseconds), default: 0]
                self.predictedCardInfo[.expireDate(dateFromMilliseconds)] = count + 1
                if count > 2 {
                    self.selectedCard.expireDate = dateFromMilliseconds
                }
            }

            if let number = Card.number {
                let count = self.predictedCardInfo[.number(number), default: 0]
                self.predictedCardInfo[.number(number)] = count + 1
                if count > 2 {
                    self.selectedCard.number = number
                }
            }

            if let selectedCardNumber = self.selectedCard.number, selectedCardNumber.count >= 13 {
                self.delegate?.didFinishAnalyzation(with: .success(self.selectedCard))
                self.delegate = nil
            }
        }
    }
#endif
