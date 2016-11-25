//
//  ViewController.swift
//  ASVPN
//
//  Created by ashen on 16/4/20.
//  Copyright © 2016年 Ashen. All rights reserved.
//

import UIKit

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
    
    @IBAction func btnActionCopt(_ sender: AnyObject) {
        
        if vpns.count == 0 {
            return
        }
        let model = vpns[refreshCount];
        lblIP.text = model.ip
        lblPort.text = model.port
        lplPwd.text = model.pwd
        lblSytle.text = model.style
        UIPasteboard.general.string = model.pwd.replacingOccurrences(of: "密码：", with: "")
        refreshCount = refreshCount + 1
        if refreshCount > 2 {
            refreshCount = 0
        }
        
    }
    
    
    func getVPN() {
        
     
        let url = URL(string: "http://www.ishadowsocks.net")
        let request = URLRequest(url: url!)
     
        let congiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: congiguration)
       
        let task = session.dataTask(with: request, completionHandler: { (data, response, error)->Void in
            if error == nil{
                self.check(String(data: data!, encoding: String.Encoding.utf8)!)
            }
        })
       
        task.resume()
    }
    
    func check(_ str: String) {
        
        do {
            var pattern = "<h4>([\\w\\W])服务器地址:(.*?)</h4>"
            pattern = pattern.appending("[\\w\\W]+?端口:(.*?)</h4>")
            pattern = pattern.appending("[\\w\\W]+?密码:(.*?)</h4>")
            pattern = pattern.appending("[\\w\\W]+?加密方式:(.*?)</h4>")
            let regex = try NSRegularExpression(pattern: pattern, options:
                NSRegularExpression.Options.caseInsensitive)
            
            let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            for checkingRes in res {
                let name = (str as NSString).substring(with: checkingRes.rangeAt(1))
                let ip = (str as NSString).substring(with: checkingRes.rangeAt(2))
                let port = (str as NSString).substring(with: checkingRes.rangeAt(3))
                let pwd = (str as NSString).substring(with: checkingRes.rangeAt(4))
                let style = (str as NSString).substring(with: checkingRes.rangeAt(5))
                
                let vpnmodel = VPNModel()
                vpnmodel.ip = name + "服务器地址：" + ip.uppercased()
                vpnmodel.port = "端口：" + port
                vpnmodel.pwd = "密码：" + pwd
                vpnmodel.style = "加密方式：" + style
                vpns.append(vpnmodel)
                
                
                lblIP.text = vpnmodel.ip
                lblPort.text = vpnmodel.port
                lplPwd.text = vpnmodel.pwd
                lblSytle.text = vpnmodel.style
                UIPasteboard.general.string = pwd
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

