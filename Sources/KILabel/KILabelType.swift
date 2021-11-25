//
//  KILabelType.swift
//  
//
//  Created by Kimun Kwon on 2021/11/25.
//

import Foundation

public enum KILinkType: Int {
    case userHandle
    case hashTag
    case url
}

public struct KILinkTypeOption: OptionSet {
    public let rawValue: Int
    
    /**
     *  No links
     */
    public static let none = KILinkTypeOption(rawValue: 1 << 0)
    /**
     *  Specifies to include userHandle links
     */
    public static let userHandle = KILinkTypeOption(rawValue: 1 << 1)
    /**
     *  Specifies to include hashtag links
     */
    public static let hashTag = KILinkTypeOption(rawValue: 1 << 2)
    /**
     *  Specifies to include URL links
     */
    public static let url = KILinkTypeOption(rawValue: 1 << 3)
    
    /**
     *  Convenience contstant to include all link types
     */
    static let all: KILinkTypeOption = [.none, .userHandle, .hashTag, .url]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public enum LinkRangeKey: String {
    /// a TDLinkType that identifies the type of link.
    case type
    /// the range of the link within the label text.
    case range
    /// the link text. This could be an URL, handle or hashtag depending on the linkType value.
    case link
}
