 //
//  NewMessageController.swift
//  firechat
//
//  Created by Andrew Carvajal on 9/18/17.
//  Copyright © 2017 Andrew Carvajal. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellID = "cell"

    var users = [FirechatUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        fetchUser()
    }
    
    fileprivate func fetchUser() {
        print("fetchUser")
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = FirechatUser()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        cell.imageView?.image = UIImage(named: "oprah")
        cell.imageView?.contentMode = .scaleAspectFill
        
        if let profileImageURL = user.profileImageURL {
            let url = URL(string: profileImageURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error as Any)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data!)
                }
                
            }).resume()
        }
        
        return cell
    }
}
 
 class UserCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 }
