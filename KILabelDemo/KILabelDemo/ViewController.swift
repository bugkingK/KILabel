//
//  ViewController.swift
//  KILabelDemo
//
//  Created by Kimun Kwon on 2021/11/25.
//

import UIKit
import KILabel

class ViewController: UIViewController {
    @IBOutlet private weak var label: KILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        label.delegate = self
    }
}

extension ViewController: KILabelDelegate {
    func didSelected(_ type: KILinkType, _ label: KILabel, _ string: String, _ range: NSRange) {
        print(string)
    }
}

