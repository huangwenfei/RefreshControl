//
//  RefreshLocalizable.swift
//  Xiaosuimian
//
//  Created by windy on 2025/7/19.
//

import Foundation

public struct RefreshLocalizable {
    
    // MARK: Class
    public static var shared: Self = .init()
    
    public static let languageNotifiName: Notification.Name = .init(rawValue: "refresh.control.language.name")
    
    // MARK: Properites
    public private(set) var languageCode: String? = nil
    
    public var i18nFileName: String? = nil
    public var i18nBundle: Bundle? = nil
    
    // MARK: Init
    public init() { }
    
    // MARK: Update
    public mutating func update(languageCode code: String?) {
        
        guard languageCode != code else { return }
        
        self.languageCode = code
        
        RefreshLocalizableBundle.shared.reset()
        
        NotificationCenter.default.post(
            name: Self.languageNotifiName,
            object: RefreshLocalizable.shared
        )
        
    }
    
    // MARK: Reset
    public mutating func reset() {
        i18nBundle = nil
        i18nFileName = nil
    }
    
}

public struct RefreshLocalizableBundle {
    
    // MARK: Class
    public static var shared: Self = .init()
    
    // MARK: Properties
    public var defaultI18nBundle: Bundle? = nil
    public var systemI18nBundle: Bundle? = nil
    
    // MARK: Init
    public init() { }
    
    // MARK: Reset
    public mutating func reset() {
        defaultI18nBundle = nil
        systemI18nBundle = nil
    }
    
    // MARK: Bundles
    public mutating func localizedString(for key: String) -> String {
        localizedString(for: key, value: nil)
    }
    
    public mutating func localizedString(for key: String, value: String? = nil) -> String {
        
        let table = RefreshLocalizable.shared.i18nFileName
    
        if defaultI18nBundle == nil {
            
            var language = RefreshLocalizable.shared.languageCode
            if language == nil { language = Locale.preferredLanguages.first }
            let bundle = RefreshLocalizable.shared.i18nBundle ?? .main
            let i18nFolderPath = bundle.path(forResource: language, ofType: "lproj") ?? ""
            defaultI18nBundle = Bundle(path: i18nFolderPath) ?? .main
            
            if systemI18nBundle == nil {
                systemI18nBundle = defaultI18nBundle(language: language)
            }
        }
        
        var value = systemI18nBundle?.localizedString(forKey: key, value: value, table: nil)
        value = defaultI18nBundle?.localizedString(forKey: key, value: value, table: table)
        
        return value ?? key
    }
    
    public func defaultI18nBundle(language: String?) -> Bundle? {
        
        var language = language ?? "en"
        
        if language.hasPrefix("en") {
            language = "en"
        }
        else if language.hasPrefix("zh") {
            if language.range(of: "Hans") != nil {
                language = "zh-Hans" // 简体中文
            } else {
                // zh-Hant\zh-HK\zh-TW
                language = "zh-Hant" // 繁體中文
            }
        }
        else if language.hasPrefix("ko") {
            language = "ko"
        }
        else if language.hasPrefix("ru") {
            language = "ru"
        }
        else if language.hasPrefix("uk") {
            language = "uk"
        }
        
        let path = Bundle.srBundle?.path(forResource: language, ofType: "lproj") ?? ""
        return Bundle(path: path)
        
    }
    
}
