//
//  KILabelDelegate.swift
//  
//
//  Created by Kimun Kwon on 2021/11/25.
//

import Foundation

public protocol KILabelDelegate {
    func didSelected(_ type: KILinkType, _ label: KILabel, _ string: String, _ range: NSRange)
}
