#!/usr/bin/env xcrun swift

//
//  L10NVerifier.swift
//  L10NVerifier
//
//  Created by Tadeas Kriz on 03/09/15.
//  Copyright (c) 2015 Brightify. All rights reserved.
//

import Foundation

let Bold = "\u{001B}[0;1m"
let Black = "\u{001B}[0;30m"
let Red = "\u{001B}[0;31m"
let Green = "\u{001B}[0;32m"
let Yellow = "\u{001B}[0;33m"
let Blue = "\u{001B}[0;34m"
let Magenta = "\u{001B}[0;35m"
let Cyan = "\u{001B}[0;36m"
let White = "\u{001B}[0;37m"
let Reset = "\u{001B}[0m"

if Process.arguments.count != 3 {
    println(Red + "L10NCheck requires exactly two parameters, first one is swift file to check and second is the strings file to check" + Reset)
    exit(1)
}

var l10nSwiftPath = Process.arguments[1]
var localizablePath = Process.arguments[2]

let l10nSwift = String(contentsOfFile: l10nSwiftPath, encoding: NSUTF8StringEncoding, error: nil)!
let localizable = String(contentsOfFile: localizablePath, encoding: NSUTF8StringEncoding, error: nil)!

let l10nSwiftRange = NSMakeRange(0, count(l10nSwift.unicodeScalars))
let localizableRange = NSMakeRange(0, count(localizable.unicodeScalars))

let regex = NSRegularExpression(pattern: "NSLocalizedString\\(\"([^\"]+)\"[^\\)]*\\)", options: nil, error: nil)!
let matches = regex.matchesInString(l10nSwift, options: NSMatchingOptions.ReportProgress, range: l10nSwiftRange) as! [NSTextCheckingResult]

let result = matches.map { match -> String in
    let groupRange = match.rangeAtIndex(1)
    let location = advance(l10nSwift.startIndex, groupRange.location)
    let matchedRange = location ..< advance(location, groupRange.length)
    return l10nSwift.substringWithRange(matchedRange)
} .map { token -> (String, Int) in
    let expression = NSRegularExpression(pattern: "\"\(token)\" ?= ?\"([^\"]*)\";", options: nil, error: nil)!
    let numberOfMatches = expression.numberOfMatchesInString(localizable, options: NSMatchingOptions.ReportProgress, range: localizableRange)
    return (token, numberOfMatches)
} .map { token, matchedTimes -> Int in
    if matchedTimes == 1 {
        print(Green + "✔ ")
    } else {
        print(Red + "✘ ")
    }
    print(Reset + "\(token)")
    if matchedTimes == 0 {
        print(" (missing translation)")
    } else if matchedTimes > 1 {
        print(" (translated more than once - \(matchedTimes) times")
    }
    println()
    return matchedTimes
} .reduce((0, 0)) { (stats: (Int, Int), matchedTimes: Int) -> (Int, Int) in
        (stats.0 + 1, stats.1 + (matchedTimes == 1 ? 0 : 1))
}

println()
print("Verification completed.")
if result.1 > 0 {
    println("Missing \(Bold)\(result.1)\(Reset) strings from \(Bold)\(result.0)\(Reset) total.")
} else {
    println("All \(Bold)\(result.0)\(Reset) strings are translated.")
}
println()