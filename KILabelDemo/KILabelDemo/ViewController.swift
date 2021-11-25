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
        // Do any additional setup after loading the view.
        label.userHandleLinkTapHandler = { label, string, range in
            print(string)
        }
        
        label.urlLinkTapHandler = { label, string, range in
            print(string)
        }
        
        label.hashtagLinkTapHandler = { label, string, range in
            print(string)
        }
    }


}

