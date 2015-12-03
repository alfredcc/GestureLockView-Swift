//
//  ViewController.swift
//  GestureLockView-Swift
//
//  Created by race on 15/12/1.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var passcode = ""
    private var firstPasscode = ""
    private var isFirstTime = true
    private var isPasscodeSetUp = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.blackColor()
        let lockView = GestureLockView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat(400)))
        lockView.normalNodeImage = UIImage(named: "node-normal")
        lockView.selectedNodeImage = UIImage(named: "node-selected")
        lockView.delegate = self
        view.addSubview(lockView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: GestureLockViewDelegate {
    func gestureLockView(gestureLockView: GestureLockView, didBeginWithPasscode passcode:String) {
        print("begin: " + passcode)
    }
    func gestureLockView(gestureLockView: GestureLockView, didEndWithPasscode passcode:String) {
        print("end: " + passcode)
        if isPasscodeSetUp {
            if passcode == self.passcode {
                print("解锁成功")
            } else {
                print("解锁失败")
            }
            return
        }
        
        if isFirstTime {
            isFirstTime = false
            firstPasscode = passcode
        }else {
            if firstPasscode == passcode {
                self.passcode = passcode
                isPasscodeSetUp = true
                print("手势设置成功")
            }else {
                print("手势设置失败")
            }
            isFirstTime = true
            firstPasscode = ""
        }
    }
    func gestureLockView(gestureLockView: GestureLockView, didCanceledWithPasscode passcode:String) {
        print("cancle: " + passcode)
    }
}

