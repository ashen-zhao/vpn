//
//  ViewController.swift
//  ASVPN
//
//  Created by ashen on 16/4/20.
//  Copyright © 2016年 Ashen. All rights reserved.
//

import UIKit
import Alamofire

struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern,
                                        options: .CaseInsensitive)
    }
    
    func match(input: String) -> Bool {
        let matches = regex.matchesInString(input,
                                            options: [],
                                            range: NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}
infix operator =~ {
associativity none
precedence 130
}

func =~(lhs: String, rhs: String) -> Bool {
    do {
        return try RegexHelper(rhs).match(lhs)
    } catch _ {
        return false
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var lblIP: UILabel!
    @IBOutlet weak var lblPort: UILabel!
    @IBOutlet weak var lplPwd: UILabel!
    @IBOutlet weak var lblSytle: UILabel!
    
    var refreshCount = 0
    var vpns = [VPNModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVPN()
    }
    
    @IBAction func btnActionCopt(sender: AnyObject) {
        
        if vpns.count == 0 {
            return
        }
        let model = vpns[refreshCount];
        lblIP.text = model.ip
        lblPort.text = model.port
        lplPwd.text = model.pwd
        lblSytle.text = model.style
        UIPasteboard.generalPasteboard().string = model.pwd.stringByReplacingOccurrencesOfString("密码：", withString: "")
        refreshCount = refreshCount + 1
        if refreshCount > 2 {
            refreshCount = 0
        }
    }
    
    
    private func getVPN() {
        Alamofire.request(.GET, "http://www.ishadowsocks.net")
            .responseString { response in
                self.check(String(response.result.value))
        }
    }
    
    
    private func check(str: String) {
        
        do {
    
            let pattern = "([A-Za-z])服务器地址:(.*?)</h4>.*?端口:(.*?)</h4>.*?密码:(.*?)</h4>.*?加密方式:(.*?)</h4>"

            let regex = try NSRegularExpression(pattern: pattern, options:
                NSRegularExpressionOptions.CaseInsensitive)
            
            let res = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
        
            for checkingRes in res {
                let name = (str as NSString).substringWithRange(checkingRes.rangeAtIndex(1))
                let ip = (str as NSString).substringWithRange(checkingRes.rangeAtIndex(2))
                let port = (str as NSString).substringWithRange(checkingRes.rangeAtIndex(3))
                let pwd = (str as NSString).substringWithRange(checkingRes.rangeAtIndex(4))
                let style = (str as NSString).substringWithRange(checkingRes.rangeAtIndex(5))
                
                let vpnmodel = VPNModel()
                vpnmodel.ip = name + "服务器地址：" + ip.uppercaseString
                vpnmodel.port = "端口：" + port
                vpnmodel.pwd = "密码：" + pwd
                vpnmodel.style = "加密方式：" + style
                vpns.append(vpnmodel)
                
                
                lblIP.text = vpnmodel.ip
                lblPort.text = vpnmodel.port
                lplPwd.text = vpnmodel.pwd
                lblSytle.text = vpnmodel.style
                UIPasteboard.generalPasteboard().string = pwd
            }
        }
        catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

