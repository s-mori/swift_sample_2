//
//  WebViewController.swift
//  sample2
//
//  Created by Satomi Mori on 2015/08/24.
//  Copyright (c) 2015年 Satomi Mori. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var entry = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var url = appDelegate.url
        println("URL: \(url)")
        
        let webView = UIWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
