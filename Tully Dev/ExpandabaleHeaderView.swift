 //
//  ExpandabaleHeaderView.swift
//  Tully Dev
//
//  Created by macbook on 1/7/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import UIKit
protocol ExpandabaleHeaderViewDelegate {
    func toogleSection(header: ExpandabaleHeaderView, section : Int)
}

class ExpandabaleHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var cate_name_lbl: UILabel?
    @IBOutlet var btn_checkbox_ref: UIButton!
    @IBOutlet var section_checkbox_view_ref: UIView!
    @IBOutlet var section_checkbox_img_ref: UIImageView!
    var tapSectionCheckboxClick : ((UITableViewHeaderFooterView) -> Void)?
    var delegate: ExpandabaleHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
    }
    
    @IBAction func section_checkbox_btn_click(_ sender: UIButton) {
        tapSectionCheckboxClick?(self)
    }
    
    func selectHeaderView(gesture : UITapGestureRecognizer){
        let cell = gesture.view as! ExpandabaleHeaderView
        delegate?.toogleSection(header: self, section : cell.section)
    }
    
    func display_select_view(){
        btn_checkbox_ref.isEnabled = false
        self.section_checkbox_view_ref?.alpha = 0.0
        self.section_checkbox_img_ref?.image = nil
    }
    
    func display_checkbox_view(){
        btn_checkbox_ref.isEnabled = true
        self.section_checkbox_view_ref?.alpha = 1.0
    }
    
    func checkbox_checked(){
        section_checkbox_img_ref.layer.borderWidth = 0.0
        section_checkbox_img_ref.image = UIImage(named: "gray_checkbox")!
        section_checkbox_img_ref.layer.cornerRadius = 5.0
        section_checkbox_img_ref.clipsToBounds = true
    }
    
    func checkbox_unchecked(){
        section_checkbox_img_ref.image = nil
        section_checkbox_img_ref.layer.borderColor = UIColor.gray.cgColor
        section_checkbox_img_ref.layer.borderWidth = 1.0
        section_checkbox_img_ref.layer.cornerRadius = 5.0
        section_checkbox_img_ref.layer.masksToBounds = true
    }
    
    func customInit(cate_name: String, section: Int, delegate: ExpandabaleHeaderViewDelegate){
        self.cate_name_lbl?.text = cate_name
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cate_name_lbl?.textColor = UIColor.darkGray
    }
}
