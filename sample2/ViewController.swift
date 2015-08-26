//
//  ViewController.swift
//  sample2
//
//  Created by Satomi Mori on 2015/08/20.
//  Copyright (c) 2015年 Satomi Mori. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Tableで使用する配列を設定する
    private var qiitaList: [[String:AnyObject]] = []
    private var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Status Barの高さを取得する.
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // TableViewの生成する(status barの高さ分ずらして表示).
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        
        // Cell名の登録をおこなう.
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "QiitaCell")
        
        // DataSourceの設定をする.
        tableView.dataSource = self
        
        // Delegateを設定する.
        tableView.delegate = self
        
        // Viewに追加する.
        self.view.addSubview(tableView)
        
        // 引っ張って更新かける部分
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // APIでQiitaのリストを取得
        getQiitaList()
    }
    
    /*
    * 【質問】
    * 以下の3つのtableViewメソッドはqiitaListに値が入っているときのみ呼ばれるものなのでしょうか。
    */
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Num: \(indexPath.row)")
        println("Value: \(qiitaList[indexPath.row])")
        
        /* 選択されたURLを変数に格納
         * 参考：「SwiftでAppDelegateを使った画面間のデータ受け渡し」
         * http://qiita.com/xa_un/items/814a5cd4472674640f58
         */
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.url = qiitaList[indexPath.row]["url"] as? String
        self.navigationController?.pushViewController(WebViewController(), animated: true)
    }
    
    /*
    Cellの総数を返すデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qiitaList.count
    }
    
    /*
    Cellに値を設定するデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("QiitaCell", forIndexPath: indexPath) as! UITableViewCell
        /*
        * 【質問】
        * 文字列でシングルクォーテーションが使えないのは何故でしょう。
        * println("title: \(qiitaList[indexPath.row]['title'])")で出力を見ようとして数時間はまったので…。
        */
        
        // Cellに値を設定する.
        var title: AnyObject = qiitaList[indexPath.row]["title"]!
        cell.textLabel!.text = "\(title)"
        
        return cell
    }
    
    // tableView更新
    func refresh(){
        println("refresh")
        /*
         * 【質問】
         * 更新でreloadDataを使っているところが多かったのですが、APIにリクエストを投げるメソッドを呼び出すのではなく
         * reloadDataで更新をかけているのは、リクエストの回数を減らすためでしょうか。
         * 都度APIにリクエストを投げないとデータが更新されないのではと思い、関数を呼び出しています。
         */
        getQiitaList()
        self.refreshControl?.endRefreshing()
    }
    
    // QiitaAPIを使ってQiita記事のリスト（タイトル、URL）を取得
    func getQiitaList(){
        println("call getQiitaList")
        
        var mRequestTask: NSURLSessionDataTask!
        var request = NSMutableURLRequest(URL: NSURL(string: "https://qiita.com/api/v2/items")!)
        request.HTTPMethod = "GET"
        mRequestTask = NSURLSession.sharedSession().dataTaskWithRequest(request,completionHandler: { data, response, error in
            var jsonObject:AnyObject?
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            if(statusCode == 200){
                if (error == nil) {
                    var error:NSError?
                    jsonObject = NSJSONSerialization.JSONObjectWithData(
                        data,
                        options: NSJSONReadingOptions.AllowFragments,
                        error: &error) as AnyObject?
                    
                    if let qiitaJsonObject: AnyObject = jsonObject{
                        for origin in qiitaJsonObject as! [[String:AnyObject]]{
                            var dic: [String:AnyObject] = [:]
                            dic["title"] = origin["title"]
                            dic["url"] = origin["url"]
                            self.qiitaList.append(dic)
                        }
                    }
                }
            }
        })
        mRequestTask.resume()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

