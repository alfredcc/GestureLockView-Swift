//
//  ViewController.swift
//  GestureLockView-Swift
//
//  Created by race on 15/12/1.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let lockView = GestureLockView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat(400)))
    view.backgroundColor = UIColor.blackColor()
    view.addSubview(lockView)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

