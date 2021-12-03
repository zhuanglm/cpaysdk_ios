//
//  NextViewController.swift
//  CPaySDK
//
//  Created by Raymond Zhuang on 2021-12-02.
//

import UIKit
import SwiftUI

class NextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nextView = NextView()
        let nextViewController = UIHostingController(rootView: nextView)
        let subView = nextViewController.view
        
        subView?.backgroundColor = .clear
        
        nextViewController.view.frame = view.bounds
        addChild(nextViewController)
        nextViewController.didMove(toParent: self)
        view.addSubview(nextViewController.view)

        
    }

}
