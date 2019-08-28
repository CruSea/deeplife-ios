//
//  ActivityView.swift
//  DeepLife
//
//

import UIKit

import AlamofireImage

class DisciplesTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: DisciplesProfileDelegate?
    
    var discipleData: [User] = [User]() {
        
        didSet {
            
            tableView.reloadData()
            
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "DisciplesTableViewCell", bundle: nil), forCellReuseIdentifier: "DisciplesTableViewCell")
        
        tableView.dataSource = self
        
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(85.0)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = discipleData[indexPath.row]
        
        delegate?.discipleDidTap(id: user.id)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return discipleData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DisciplesTableViewCell") as! DisciplesTableViewCell
        
        if let profileImage = discipleData[indexPath.row].profileImage {
            
            let url = URL(string: "https://deeplife.africa/\(profileImage)")!
            
            cell.profileImageView.af_setImage(withURL: url)
            
        }
        
        cell.usernameLabel.text = discipleData[indexPath.row].name
        
        cell.stageLabel.text = "\(discipleData[indexPath.row].stage) Stage"
        
        return cell
        
    }
    
}
