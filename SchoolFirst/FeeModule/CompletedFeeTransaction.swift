//
//  CompletedFeeTransaction.swift
//  SchoolFirst
//
//  Created by vamshi krishna on 05/08/26.
//

//
//  CompletedFeeModels+Extension.swift
//  SchoolFirst

import Foundation

// MARK: - CompletedFeeTransaction Helpers
extension CompletedFeeTransaction {

    /// "2026-07-22T07:42:11.650446Z"  →  "22 Jul 2026, 07:42 AM"
    var formattedPaymentDateTime: String {

        let outputFormatter        = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy, hh:mm a"
        outputFormatter.locale     = Locale(identifier: "en_US_POSIX")

        // 1️⃣ Try with microseconds  (.650446Z)
        let f1        = DateFormatter()
        f1.locale     = Locale(identifier: "en_US_POSIX")
        f1.timeZone   = TimeZone(secondsFromGMT: 0)
        f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        if let date = f1.date(from: paymentDate) {
            return outputFormatter.string(from: date)
        }

        // 2️⃣ Try with milliseconds  (.650Z)
        let f2        = DateFormatter()
        f2.locale     = Locale(identifier: "en_US_POSIX")
        f2.timeZone   = TimeZone(secondsFromGMT: 0)
        f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = f2.date(from: paymentDate) {
            return outputFormatter.string(from: date)
        }

        // 3️⃣ Try without fractional seconds
        let f3        = DateFormatter()
        f3.locale     = Locale(identifier: "en_US_POSIX")
        f3.timeZone   = TimeZone(secondsFromGMT: 0)
        f3.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = f3.date(from: paymentDate) {
            return outputFormatter.string(from: date)
        }

        // 4️⃣ ISO8601 fallback
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: paymentDate) {
            return outputFormatter.string(from: date)
        }

        let iso2 = ISO8601DateFormatter()
        iso2.formatOptions = [.withInternetDateTime]
        if let date = iso2.date(from: paymentDate) {
            return outputFormatter.string(from: date)
        }

        // 5️⃣ Give up — return raw string
        return paymentDate
    }

    /// Returns a parsed Date object (used for sorting latest transaction)
    var paymentDateObject: Date? {

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]

        for format in formats {
            let df        = DateFormatter()
            df.locale     = Locale(identifier: "en_US_POSIX")
            df.timeZone   = TimeZone(secondsFromGMT: 0)
            df.dateFormat = format
            if let date = df.date(from: paymentDate) {
                return date
            }
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: paymentDate)
    }

    /// Comma-separated fee types  →  "Tuition Fee, Transport Fee"
    var feeTypesJoined: String {
        let types = fees.map { $0.feeType }.filter { !$0.isEmpty }
        return types.isEmpty ? "--" : types.joined(separator: ", ")
    }

    /// Best available transaction identifier for display
    var displayTransactionId: String {
        if !transactionId.isEmpty        { return transactionId }
        if !gatewayTransactionId.isEmpty { return gatewayTransactionId }
        if !referenceNumber.isEmpty      { return referenceNumber }
        if !gatewayOrderId.isEmpty       { return gatewayOrderId }
        return "--"
    }
}
