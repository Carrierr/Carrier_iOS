//
//  TTLoginViewController.swift
//  TipTap
//
//  Created by Haehyeon Jeong on 2018. 8. 15..
//  Copyright © 2018년 Tiptap. All rights reserved.
//

import UIKit
import KakaoOpenSDK

class TTFirstViewController: TTBaseViewController {

    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavi()
    }
    
    
    override func setupUI() {
        self.titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        self.loginButton.layer.borderColor = UIColor.gray.cgColor
        self.loginButton.layer.borderWidth = 1
        
        self.registerButton.layer.borderColor = UIColor.gray.cgColor
        self.registerButton.layer.borderWidth = 1
    }
    
    
    private func initNavi(){
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    
    @IBAction func pressedLoginButton(_ sender: Any) {
        let session: KOSession = KOSession.shared();
        
        if session.isOpen() {
            session.close()
        }
        
        session.open(completionHandler: { (error) -> Void in
            
            if !session.isOpen() {
                if let error = error as NSError? {
                    switch error.code {
                    case Int(KOErrorCancelled.rawValue):
                        break
                    default:
                        UIAlertController.showMessage(error.description)
                    }
                    return
                }

            }
            KOSessionTask.userMeTask(completion: { (error, me) in
                print("id : \(me?.id ?? "")")
                print("id : \(me?.nickname ?? "")")
                print("id : \(me?.account?.email ?? "")")
                
                TTAuthAPIManager.sharedManager.login(loginFlatform: .kakao, account: me?.id ?? "", name: me?.nickname ?? "", completion: { (result) in
                    switch result {
                    case .success( _):
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sessionDidChange"), object: nil)
                        break
                    case .error( _):
                        break
                    case .errorMessage(_):
                        break
                    }
                })
            })
        })
    }
}