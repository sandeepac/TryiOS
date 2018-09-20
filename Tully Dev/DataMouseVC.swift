//
//  DataMouseVC.swift
//  Tully Dev
//
//  Created by macbook on 6/3/17.
//  Copyright © 2017 Tully. All rights reserved.
//

import UIKit
import SQLite
import Mixpanel

protocol selectedDataProtocol {
    func getSelectedString(selectedWord : String)
}

class DataMouseVC: UIViewController , UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate
{
    //MARK: - Variables & Outlets
    @IBOutlet var tbl_outer_view: UIView!
    @IBOutlet var DataMouseTblRef: UITableView!
    @IBOutlet var btn_purchase_ref: UIButton!
    
    var DataMouseDataArray:[DataOfdataMouse] = [DataOfdataMouse]()
    var mySelectedWord = ""
    var myProtocol : selectedDataProtocol?
    var myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad(){
        super.viewDidLoad()
        btn_purchase_ref.layer.cornerRadius = 10.0
        MyConstants.showAnimate(myView: self.view)
        myActivityIndicator.center = view.center
        view.addSubview(myActivityIndicator)
        custom_design()
        
        DataMouseTblRef.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        if(mySelectedWord != ""){
            if(Reachability.isConnectedToNetwork()){
                getDataMouseData()
            }else{
                getOfflineDataMouseData()
            }
        }
        Mixpanel.mainInstance().track(event: "Rhyme initiated")
    }
    
    func custom_design(){
        tbl_outer_view.layer.borderWidth = 1.0
        tbl_outer_view.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1).cgColor
        tbl_outer_view.layer.cornerRadius = 5.0
        tbl_outer_view.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return DataMouseDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myData=DataMouseDataArray[indexPath.row]
        let myCell : DataMouseTblCell = tableView.dequeueReusableCell(withIdentifier: "DataMouseTblCellIdentifier", for: indexPath) as! DataMouseTblCell
        myCell.data_option_lbl.text = myData.data
        myCell.data_detail_btn_Ref.tag = indexPath.row
    
        myCell.tapOpenDetail = { (cell) in
            let myData = self.DataMouseDataArray[myCell.data_detail_btn_Ref.tag]
            let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WordMeaningSid") as! WordMeaningVC
            popvc.myword = myData.data!
            popvc.mydesc = myData.desc_word!
            self.addChildViewController(popvc)
            popvc.view.frame = self.view.frame
            self.view.addSubview(popvc.view)
            popvc.didMove(toParentViewController: self)
        }
        
        if(indexPath.row == DataMouseDataArray.count - 1){
            myCell.isHidden = true
        }
        if(indexPath.row == 0){
            myCell.data_option_lbl.text = "Select a Word"
        }else{
            myCell.isHidden = false
        }
        return myCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0 || indexPath.row == DataMouseDataArray.count - 1){
            self.myProtocol?.getSelectedString(selectedWord: self.mySelectedWord)
            MyConstants.removeAnimate(myView: self.view, myVC: self)
        }else{
            let myData = DataMouseDataArray[indexPath.row]
            Mixpanel.mainInstance().track(event: "Rhyme Selected")
            myProtocol?.getSelectedString(selectedWord: myData.data!)
            MyConstants.removeAnimate(myView: self.view, myVC: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(DataMouseDataArray.count > 0){
            var last_row = 0
            var myindex = 0
            var last_flag = false
            let visible = DataMouseTblRef.indexPathsForVisibleRows

            for vs in visible!{
                if(vs.row >= 0){
                    myindex = myindex + 1
                    if(myindex == (visible?.count)!){
                        last_row = vs.row
                    }else{
                        if(myindex == 2){
                            let gen_index = NSIndexPath(row: vs.row, section: 0)
                            let cell1 = DataMouseTblRef.cellForRow(at: gen_index as IndexPath) as? DataMouseTblCell
                            cell1?.data_option_lbl.textColor = UIColor.gray
                            cell1?.data_detail_btn_Ref.isEnabled = true
                            cell1?.data_img_ref.image = UIImage(named: "info-icon.png")
                            cell1?.right_arrow_img_ref.image = UIImage(named: "right-arrow.png")
                        }else{
                            let gen_index = NSIndexPath(row: vs.row, section: 0)
                            let cell1 = DataMouseTblRef.cellForRow(at: gen_index as IndexPath) as? DataMouseTblCell
                            cell1?.data_option_lbl.textColor = UIColor.gray
                            cell1?.data_detail_btn_Ref.isEnabled = false
                            cell1?.data_img_ref.image = nil
                            cell1?.right_arrow_img_ref.image = nil
                        }
                    }
                }else{
                    last_flag = true
                }
            }
            
            if(!last_flag){
                let gen_index = NSIndexPath(row: last_row, section: 0)
                let cell1 = DataMouseTblRef.cellForRow(at: gen_index as IndexPath) as? DataMouseTblCell
                cell1?.data_option_lbl.textColor = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 0.4)
            }
        }
    }
    
    func getDataMouseData()
    {
        myActivityIndicator.startAnimating()
        DataMouseDataArray.removeAll()
        mySelectedWord = mySelectedWord.trimmingCharacters(in: .whitespaces)
        mySelectedWord = mySelectedWord.replacingOccurrences(of: "\n", with: "")
        let mySelectedWord1 = mySelectedWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let get_mouse_data=DataOfdataMouse(data: "", desc_word: "")
        self.DataMouseDataArray.append(get_mouse_data)
        let myurl = MyConstants.dataMouseApi + mySelectedWord1 + "&md=d"
        
        //myurl = myurl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: myurl)!
        //let url = URL(fileURLWithPath: myurl)
        //DispatchQueue.main.async(execute: {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if data != nil {
                
            if( error != nil ){
                MyConstants.display_alert(msg_title: "Error", msg_desc: (error?.localizedDescription)!, action_title: "OK", navpop: false, myVC: self)
            }else{
                if let urlContent = data{
                    do{
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                            DispatchQueue.main.sync (execute: {
                                var data1: String
                                var desc_word1 : String
                                for json in jsonResult{
                                    if((json as AnyObject).value(forKey: "word") as? String != nil){
                                        data1 = (json as AnyObject).value(forKey: "word") as! String
                                    }else{
                                        data1 = ""
                                    }
                                    
                                    if((json as AnyObject).value(forKey: "defs") as? NSArray != nil){
                                        let myarr = (json as AnyObject).value(forKey: "defs") as? NSArray
                                        desc_word1 = (myarr?[0] as? String)!
                                    }else{
                                        desc_word1 = ""
                                    }
                                    
                                    let get_mouse_data=DataOfdataMouse(data: data1, desc_word: desc_word1)
                                    self.DataMouseDataArray.append(get_mouse_data)
                                }
                                let get_mouse_data=DataOfdataMouse(data: "", desc_word: "")
                                self.DataMouseDataArray.append(get_mouse_data)
                                self.DataMouseTblRef.reloadData()
                                if(self.DataMouseDataArray.count > 1){
                                    let gen_index = NSIndexPath(row: 1, section: 0) as IndexPath
                                    self.DataMouseTblRef.scrollToRow(at: gen_index, at: UITableViewScrollPosition.top, animated: false)
                                    let gen_index1 = NSIndexPath(row: 0, section: 0) as IndexPath
                                    self.DataMouseTblRef.scrollToRow(at: gen_index1, at: UITableViewScrollPosition.top, animated: false)
                                }else{
                                    self.myProtocol?.getSelectedString(selectedWord: self.mySelectedWord)
                                    MyConstants.removeAnimate(myView: self.view, myVC: self)
                                }
                                self.myActivityIndicator.stopAnimating()
                            })
                    }catch{
                        MyConstants.display_alert(msg_title: "Error", msg_desc: (error.localizedDescription), action_title: "OK", navpop: false, myVC: self)
                       self.myActivityIndicator.stopAnimating()
                    }
                }
                
            }
                
            }else{
                self.myProtocol?.getSelectedString(selectedWord: self.mySelectedWord)
                MyConstants.removeAnimate(myView: self.view, myVC: self)
            
            }
        }
        task.resume()
           // } as! @convention(block) () -> Void)
    }
    
    
    func getOfflineDataMouseData()
    {
        myActivityIndicator.startAnimating()
        DataMouseDataArray.removeAll()
        mySelectedWord = mySelectedWord.trimmingCharacters(in: .whitespaces)
        mySelectedWord = mySelectedWord.replacingOccurrences(of: "\n", with: "")
        let get_mouse_data=DataOfdataMouse(data: "", desc_word: "")
        self.DataMouseDataArray.append(get_mouse_data)
        
        do{
            let path = Bundle.main.path(forResource: "dictionarydb", ofType: "sqlite3")!
            let db = try Connection(path, readonly: true)
            let stmt = try db.prepare("SELECT rm.rhym FROM rhym_master rm JOIN word_rhym wr ON wr.rhym_id = rm.id JOIN words_master wm ON wm.id = wr.word_id WHERE wm.word like '"+mySelectedWord+"'")
            for row in stmt {
                for (index, _) in stmt.columnNames.enumerated() {
                    let rhy_word = row[index]! as! String
                    let get_mouse_data=DataOfdataMouse(data: rhy_word, desc_word: "")
                    self.DataMouseDataArray.append(get_mouse_data)
                }
            }
            let get_mouse_data=DataOfdataMouse(data: "", desc_word: "")
            self.DataMouseDataArray.append(get_mouse_data)
            self.DataMouseTblRef.reloadData()
            if(self.DataMouseDataArray.count > 1){
                let gen_index = NSIndexPath(row: 1, section: 0) as IndexPath
                self.DataMouseTblRef.scrollToRow(at: gen_index, at: UITableViewScrollPosition.top, animated: false)
                let gen_index1 = NSIndexPath(row: 0, section: 0) as IndexPath
                self.DataMouseTblRef.scrollToRow(at: gen_index1, at: UITableViewScrollPosition.top, animated: false)
            }else{
                self.myProtocol?.getSelectedString(selectedWord: self.mySelectedWord)
                MyConstants.removeAnimate(myView: self.view, myVC: self)
            }
            self.myActivityIndicator.stopAnimating()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    @IBAction func btn_purchase_click(_ sender: UIButton) {
        
    }
    
    @IBAction func close_view(_ sender: Any) {
    self.myProtocol?.getSelectedString(selectedWord: self.mySelectedWord)
        MyConstants.removeAnimate(myView: self.view, myVC: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
