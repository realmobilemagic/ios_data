//
//  String+Extensions.swift
//  
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/21.
//

import Foundation

public extension String {
    func log(_ title: String = "") {
        if title.isEmpty {
            print(self)
        } else {
            print("[\(title)] \(self)")
        }
    }
    
    var url: URL? { URL(string: self) }
    
    func maxLength(length: Int) -> String {
        var str = self
        let nsString = str as NSString
        if nsString.length >= length {
            str = nsString.substring(with:
                                        NSRange(
                                            location: 0,
                                            length: nsString.length > length ? length : nsString.length)
            )
        }
        return str
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    func satisfiesRegexp(_ regexp: String) -> Bool {
        return range(of: regexp, options: .regularExpression) != nil
    }
    
    var cleanForCommenting: String {
        self.trimmingCharacters(in: .newlines)
            .replacingOccurrences(of: "\n", with: " ")
    }
}

public extension String {
    var isValidEmail: Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    var isValidPassword: Bool { count >= 6 }
    
    var isValidName: Bool { count >= 2 }
}

public extension String {
    var links: [URL] {
        let types: NSTextCheckingResult.CheckingType = .link
        
        do {
            let detector = try NSDataDetector(types: types.rawValue)
            let matches = detector.matches(in: self, options: .reportCompletion, range: NSMakeRange(0, count))
            return matches.compactMap({
                guard let httpContent = $0.url?.absoluteString.components(separatedBy: "http").last else { return nil }
                return "http\(httpContent)".url
            })
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        return []
    }
}

