//
//  DisciplesViewController.swift
//  DeepLife
//
//

import UIKit

import Alamofire

import SwiftyJSON

protocol DisciplesProfileDelegate: class {
    
    func discipleDidTap(id: Int)
    
    func refreshTableViews()
    
}

class DisciplesViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        
        didSet {
            
            scrollView.delegate = self
            
        }
        
    }
    
    var currentIndex: Int = 0
    
    @IBOutlet weak var segmentedControl: CustomSegmentedControl! {
        
        didSet {
            
            segmentedControl.delegate = self
            
        }
        
    }
    
    var primaryListData: [User] = [User]()
    
    var generationalListData: [User] = [User]()
    
    lazy var primarySlide: DisciplesTableView = {
        
        let primaryView = Bundle.main.loadNibNamed("DisciplesTableView", owner: self, options: nil)?.first as! DisciplesTableView
        
        primaryView.discipleData = primaryListData
        
        primaryView.delegate = self
        
        return primaryView
        
    }()
    
    lazy var secondarySlide: DisciplesTableView = {
        
        let secondaryView = Bundle.main.loadNibNamed("DisciplesTableView", owner: self, options: nil)?.first as! DisciplesTableView
        
        secondaryView.discipleData = generationalListData
        
        secondaryView.delegate = self
        
        return secondaryView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSlideScrollView(slides: [primarySlide, secondarySlide])
        
        self.navigationItem.backBarButtonItem?.title = ""
        
        self.navigationController?.navigationBar.tintColor = .black
        
        getDisciplesList(withSpinner: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    func setupSlideScrollView(slides : [DisciplesTableView]) {
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            
            scrollView.addSubview(slides[i])
            
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        
        segmentedControl.updateSegmentedControlSegs(index: Int(pageIndex))
        
        currentIndex = Int(pageIndex)
        
    }
    
    func getDisciplesList(withSpinner: Bool) {
        
        guard let currentUserId = Auth.auth.currentUserId else {
            
            return
            
        }
        
        let userDataParameters: Parameters = [
            
            "user_id" : currentUserId
            
        ]
        
        let headers: HTTPHeaders = [
            
            "Accept": "application/json; charset=utf-8"
            
        ]
        
        var sv: UIView?
        
        if withSpinner {
        
            sv = UIViewController.displaySpinner(onView: self.view)
            
        }
        
        Alamofire.request(APIRoute.shared.getDiscipleListURL(), method: .post, parameters: userDataParameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (data) in
            
            guard let strongSelf = self else { return }
            
            if let _sv = sv {
                
                UIViewController.removeSpinner(spinner: _sv)
                
            }

            if let error = data.error {
                
                print("an error occured")
                
                print(error.localizedDescription)
                
                return
                
            }
            
            if let _data = data.result.value {
                
                let jsonData = JSON(_data)
                
                strongSelf.primaryListData.removeAll()
                
                strongSelf.generationalListData.removeAll()
                
                if let primaryList = jsonData["primary_disciples_list"].arrayObject {
                    
                    for primaryItem in primaryList {
                        
                        guard let primary = primaryItem as? [String: Any] else {
                            
                            continue
                            
                        }
                        
                        guard let deepStageEntry = primary["deep_stage"] as? String else {
                            
                            continue
                            
                        }
                        
                        var deepStage: DeepStageType = DeepStageType.Win
                        
                        if deepStageEntry == DeepStageType.Win.getDescription() {
                            
                            deepStage = DeepStageType.Win
                            
                        }
                        else if deepStageEntry == DeepStageType.Build.getDescription() {
                            
                            deepStage = DeepStageType.Build
                            
                        }
                        else if deepStageEntry == DeepStageType.Send.getDescription() {
                            
                            deepStage = DeepStageType.Send
                            
                        }
                        
                        guard let _followerId = primary["follower_id"] as? String,
                              let followerId = Int(_followerId) else {
                            
                            continue
                            
                        }
                        
                        var firstName: String = ""
                        
                        var lastName: String = ""
                        
                        var avatar: String? = nil
                        
                        if let _firstName = primary["first_name"] as? String {
                            
                            firstName = "\(_firstName) "
                            
                        }
                        
                        if let _lastName = primary["last_name"] as? String {
                            
                            lastName = _lastName
                            
                        }
                        
                        if let _avatar = primary["avatar"] as? String {
                            
                            avatar = _avatar
                            
                        }
                        
                        let fullName: String = "\(firstName)\(lastName)"
                        
                        let newDisciple = User(id: followerId, name: fullName, profileImage: avatar, stage: deepStage)
                        
                        strongSelf.primaryListData.append(newDisciple)
                        
                    }
                    
                }
                
                if let generationalList = jsonData["generational_disciples_list"].arrayObject {
                    
                    for generationalItem in generationalList {
                        
                        guard let generational = generationalItem as? [String: Any] else {
                            
                            continue
                            
                        }
                        
                        guard let _followerId = generational["follower_id"] as? String,
                            let followerId = Int(_followerId) else {
                                
                                continue
                                
                        }
                        
                        guard let deepStageEntry = generational["deep_stage"] as? String else {
                            
                            return
                            
                        }
                        
                        var deepStage: DeepStageType = DeepStageType.Win
                        
                        if deepStageEntry == DeepStageType.Win.getDescription() {
                            
                            deepStage = DeepStageType.Win
                            
                        }
                        else if deepStageEntry == DeepStageType.Build.getDescription() {
                            
                            deepStage = DeepStageType.Build
                            
                        }
                        else if deepStageEntry == DeepStageType.Send.getDescription() {
                            
                            deepStage = DeepStageType.Send
                            
                        }
                        
                        var firstName: String = ""
                        
                        var lastName: String = ""
                        
                        var avatar: String? = nil
                        
                        if let _firstName = generational["first_name"] as? String {
                            
                            firstName = "\(_firstName) "
                            
                        }
                        
                        if let _lastName = generational["last_name"] as? String {
                            
                            lastName = _lastName
                            
                        }
                        
                        if let _avatar = generational["avatar"] as? String {
                            
                            avatar = _avatar
                            
                        }
                        
                        let fullName: String = "\(firstName)\(lastName)"
                        
                        let newDisciple = User(id: followerId, name: fullName, profileImage: avatar, stage: deepStage)
                        
                        strongSelf.generationalListData.append(newDisciple)
                        
                    }
                    
                }
                
                DispatchQueue.main.async {
                    
                    strongSelf.primarySlide.discipleData = strongSelf.primaryListData
                    
                    strongSelf.secondarySlide.discipleData = strongSelf.generationalListData
                    
                }
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "disciplesProfileSegue" {
            
            guard let destinationVC = segue.destination as? DiscipleProfileViewController else { return }
            
            guard let followerId = sender as? Int else { return }
            
            destinationVC.followerdId = followerId
            
            destinationVC.delegate = self
            
        }
        
    }
    
    @IBAction func cancelButtonDidTouch(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }

}

extension DisciplesViewController: DisciplesControlDelegate {
    
    func scrollTo(index: Int) {
        
        if currentIndex == index {
            
            return
            
        }
        
        let pageWidth:CGFloat = self.scrollView.frame.width
        
        let slideToX = pageWidth * CGFloat(index)
        
        self.scrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.scrollView.frame.height), animated: true)
        
    }
    
}

extension DisciplesViewController: DisciplesProfileDelegate {
    
    func discipleDidTap(id: Int) {
        
        performSegue(withIdentifier: "disciplesProfileSegue", sender: id)
        
    }
    
    func refreshTableViews() {
        
        getDisciplesList(withSpinner: false)
        
    }
    
}
