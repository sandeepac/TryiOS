import UIKit
import Firebase

class ForgotPwdVC: UIViewController , UITextFieldDelegate
{
    @IBOutlet var txt_ref_email: UITextField!
    @IBOutlet var btn_ref_send: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        MyConstants.setWhiteActivityIndicator(myView: self.view)
        create_design()
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    @IBAction func btn_click_send(_ sender: Any){
        MyConstants.startWhiteActivityIndicator()
        var email_flag = false
        if(txt_ref_email.text == ""){
            MyConstants.display_alert(msg_title: "Error", msg_desc: "Enter Email ID", action_title: "Try again", navpop: true, myVC: self)
        }else{
            if(txt_ref_email.text == ""){
                MyConstants.display_alert(msg_title: "Error", msg_desc: "Enter Email ID", action_title: "Try again", navpop: true, myVC: self)
            }else{
                if(validations.isValidEmail(testStr: txt_ref_email.text!)){
                    email_flag = true
                }else{
                    MyConstants.display_alert(msg_title: "Error", msg_desc: "Invalid Email ID", action_title: "Try again", navpop: true, myVC: self)
                }
            }
        }
        if(email_flag == true){
            let email = txt_ref_email.text!
            self.view.endEditing(true)
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error{
                    MyConstants.stopWhiteActivityIndicator()
                    MyConstants.display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "Try again", navpop: true, myVC: self)
                }else{
                    MyConstants.stopWhiteActivityIndicator()
                    let ac = UIAlertController(title: "Email Sent", message: "Email sent with instruction to restore your password.", preferredStyle: .alert)
                    let attributes = [NSForegroundColorAttributeName: UIColor.red, NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 16.0)!]
                    let titleAttrString = NSMutableAttributedString(string: "Email Sent", attributes: attributes)
                    ac.setValue(titleAttrString, forKey: "attributedTitle")
                    ac.view.tintColor = UIColor(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
                    ac.addAction(UIAlertAction(title: "OK", style: .default){
                        (result : UIAlertAction) -> Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                    self.present(ac, animated: true)
                }
            }
        }else{
            MyConstants.stopWhiteActivityIndicator()
        }
    }
    
    //MARK: - Close textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        MyConstants.closeTextView(myView: self.view)
        return false
    }
    
    //MARK: - Custom design
    func create_design(){
        txt_ref_email.layer.cornerRadius = 7.0
        btn_ref_send.layer.cornerRadius = 4.0
        let indentView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        txt_ref_email.leftView = indentView
        txt_ref_email.leftViewMode = .always
    }
    
    @IBAction func go_back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
