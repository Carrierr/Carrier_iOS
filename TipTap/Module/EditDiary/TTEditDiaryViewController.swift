//
//  TTEditDiaryViewController.swift
//  TipTap
//
//  Created by Haehyeon Jeong on 2018. 8. 18..
//  Copyright © 2018년 Tiptap. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import MapKit


class AdressData{
    var city : String = ""
    var detailAddress : String = ""
    
    init(city : String, detailAddress : String) {
        self.city         = city
        self.detailAddress = detailAddress
    }
}


class TTEditDiaryViewController: TTBaseViewController, TTTimeGettable, TTLocationGettable, TTCanShowAlert, UIGestureRecognizerDelegate {
    var todayDiaryCount = 1
    var locationManager : CLLocationManager?
    var location        : CLLocation?
    
    private var address : AdressData?
    private lazy var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var imageViewTopConst: NSLayoutConstraint!
    @IBOutlet private weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var textCountLabel: UILabel!
    @IBOutlet private weak var placeHolderLabel: UILabel!
    @IBOutlet private weak var boardTextView: UITextView!
    @IBOutlet private weak var accessoryBottomConst: NSLayoutConstraint!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var travelPicture: UIImageView!
    @IBOutlet private weak var locationStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImagePicker()
        setUpLocationManager()
        registerNotification()
        setImageView(isHidden: true)
        dateLabel.text = currentTime()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if boardTextView.text?.count == 0 {
            placeHolderLabel.isHidden = false
        }else{
            placeHolderLabel.isHidden = true
        }
        
    }
    
    
    override func setupUI() {
        navigationController?.navigationBar.tintColor = UIColor.gray;
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        boardTextView.layoutManager.delegate = self
        boardTextView.becomeFirstResponder()
        boardTextView.delegate = self
        
        numberLabel.text = "#\(todayDiaryCount)"
    }
    

    
    private func setupImagePicker(){
        imagePicker.delegate   = self
        imagePicker.sourceType = .savedPhotosAlbum
    }
    
    
    
    func setUpLocationManager(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self;
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    
    
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector:  #selector(onUIKeyboardWillShowNotification(noti:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUIKeyboardWillHideNotification(noti:)), name: .UIKeyboardWillHide, object: nil)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(pressedLocation(_:)))
        gesture.numberOfTapsRequired = 1;
        gesture.delegate = self;
        
        self.locationStackView.addGestureRecognizer(gesture)
    }
    
    
    
    
    @objc func onUIKeyboardWillShowNotification(noti : Notification){
        if let keyboardFrame: NSValue = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.accessoryBottomConst.constant = -keyboardHeight
        }
    }
    
    
    @objc func onUIKeyboardWillHideNotification(noti : Notification){
        self.accessoryBottomConst.constant = 0
    }
    

    
    @IBAction func submitDiary(_ sender: Any) {
        guard boardTextView.text.count > 0 else {
            showAlert(title: "", message: "일기 내용을 입력해주세요.")
            return
        }
        
        var latitude  = 0.0
        var longitude = 0.0
        
        if let location = self.location{
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
        
        let param = ["content":boardTextView.text!,
                     "city" : self.address?.city ?? "",
                     "location":self.address?.detailAddress ?? "",
                     "latitude":"\(latitude)",
                     "longitude":"\(longitude)"
                     ] as [String : Any]
        
        TTAPIManager.sharedManager
            .requestAPIWithImage("\(TTAPIManager.API_URL)/diary/write",
                method: .post,
                parameters: param,
                uploadImage : travelPicture.image)
        { (result) in
            print(result)
            self.showAlert(title: "", message: "일기가 등록 되었습니다.") {
                appDelegate?.registerLocalNoti()
                self.dismiss(animated: true, completion: nil)
            }

        }
    }
    
    
    
    @IBAction func pressedPickPhoto(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func pressedLocation(_ gestureRecognizer: UIPanGestureRecognizer){
        let searchVC = TTSearchViewController(nibName: "TTSearchViewController", bundle: nil)
        searchVC.modalPresentationStyle = UIModalPresentationStyle.custom
        searchVC.delegate = self
        self.present(searchVC, animated: false, completion: nil)
    }
    
    
    func setImageView(isHidden : Bool){
        if isHidden {
            imageViewHeight.constant = 0
            imageViewTopConst.constant = 0
            travelPicture.isHidden = isHidden
        }else{
            imageViewHeight.constant = 67
            imageViewTopConst.constant = 27
            travelPicture.isHidden = isHidden
        }
    }

}



extension TTEditDiaryViewController : TTSearchViewControllerDelegate {
    func selectPlace(_: TTSearchViewController, placeString: String) {
        locationLabel.text = placeString
        self.address = AdressData(city: placeString, detailAddress: "")
    }
    
    func searchPlace(_: TTSearchViewController, keyword: String, completion: @escaping (([MKMapItem]) -> ())) {
        getLocations(withKeyword: keyword, completion: { items in
            completion(items)
        })
    }
}


extension TTEditDiaryViewController : UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text?.count == 0 {
            placeHolderLabel.isHidden = false
        }else{
            placeHolderLabel.isHidden = true
        }
        if textView.text.count > 0 {
            submitButton.alpha = 1
        }else{
            submitButton.alpha = 0.3
        }
        
        textCountLabel.text = "\(textView.text.count)/500"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count >= 500{
            return false
        }
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if(textView.text.count == 0){
            placeHolderLabel.isHidden = true
        }
        return true;
    }
}


extension TTEditDiaryViewController : NSLayoutManagerDelegate{
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 6
    }
}



extension TTEditDiaryViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations.last
        currentLocation { (address) in
            if let address = address {
                self.locationLabel.text = "\(address.city) \(address.detailAddress)"
                self.address = address
            }else{
                self.locationManager?.stopUpdatingLocation()
            }
            
            
        }
        
    }
}





extension TTEditDiaryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            travelPicture.image = image.crop(to:CGSize(width: 89.3, height: 67))
            setImageView(isHidden: false)
        }
        
        dismiss(animated: true, completion: nil)
    }
}




