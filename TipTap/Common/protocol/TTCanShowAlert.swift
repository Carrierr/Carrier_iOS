//
//  TTCanShowAlert.swift
//  TipTap
//
//  Created by Haehyeon Jeong on 2018. 9. 22..
//  Copyright © 2018년 Tiptap. All rights reserved.
//

import Foundation
import UIKit

protocol TTCanShowAlert {
    func showAlert(title : String?, message:String?, confirmButtonTitle:String?, completion:(()->())?)
}

extension TTCanShowAlert{
    func showAlert(title : String?,
                   message:String?,
                   confirmButtonTitle:String? = nil,
                   completion:(()->())? = nil){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAlert = UIAlertAction(title: confirmButtonTitle ?? "확인", style: .default, handler: { (result) in
            if (completion != nil) {
                completion!()
            }
        })
        
        alertController.addAction(confirmAlert)
        
        appDelegate?.searchFrontViewController().present(alertController, animated: true, completion: nil)
    }
    
    
    func showAlert(title : String?,
                   message : String?,
                   completion:@escaping (()->()),
                   cancelAction: @escaping (()->())) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAlert = UIAlertAction(title: "확인", style: .default, handler: { (result) in
                completion()
        })
        
        let cancelAlert = UIAlertAction(title: "취소", style: .cancel, handler: { (result) in
            cancelAction()
        })

        
        
        
        alertController.addAction(confirmAlert)
        alertController.addAction(cancelAlert)
        
        appDelegate?.searchFrontViewController().present(alertController, animated: true, completion: nil)
    }
    
    func showActionSheet(sheetActions:UIAlertAction...){
        

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        for sheetAction in sheetActions{
            alertController.addAction(sheetAction)
        }
        
        
        alertController.addAction(cancelButton)
        
        appDelegate?.searchFrontViewController().present(alertController, animated: true, completion: nil)
    }
}
