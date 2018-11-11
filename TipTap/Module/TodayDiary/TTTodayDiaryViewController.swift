//
//  TTTodayDiaryViewController.swift
//  TipTap
//
//  Created by Haehyeon Jeong on 2018. 8. 18..
//  Copyright © 2018년 Tiptap. All rights reserved.
//

import UIKit

class TTTodayDiaryViewController: TTBaseViewController,TTCanShowAlert {
    @IBOutlet weak var postView: UIView!
    private var mainView       : TTPostMainView?
    private lazy var service = TTTodayDiaryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestTodayDiaryData()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    //MARK: Draw UI
    override func setupUI() {
        mainView = TTPostMainView(frame: self.view.frame)
        mainView?.pressedPost = { (diaryDatas) in
            self.show(TTDetailDiaryWireFrame.createModule(diaryDatas: diaryDatas), sender: nil)
        }
        
        self.postView.addSubview(mainView!)
    }
    
    
    //MARK: Request today diary data
    func requestTodayDiaryData(){
        guard let _ = mainView else { return }
        service.fetchTodayDiary { (result) in
            switch result {
            case .success(let result):
                self.mainView?.dataSet = TTDiaryDataSet(diaryDataList: result.diaryDataList!, stampNameList: result.stampNameList!)
                break
            case .errorMessage(let errorMsg):
                self.showAlert(title: "", message: errorMsg)
                break
                
            default : break
            }
        }
    }
    
    @IBAction func pressedWriteButton(_ sender: Any) {
        guard  let count =  self.mainView?.dataSet?.diaryDataList?.count else { return }
        if count >= 10 {
            showAlert(title: "", message: "하루에 작성할 일기는 10개까지입니다.")
        }else{
            self.present(UIStoryboard(name: "EditDiary", bundle: nil) .instantiateViewController(withIdentifier:"TTEditDiaryViewController"), animated: true, completion: nil)
        }
    }
}
