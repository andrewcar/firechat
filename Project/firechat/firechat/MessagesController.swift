//
//  MessagesController.swift
//  firechat
//
//  Created by Andrew Carvajal on 9/9/17.
//  Copyright © 2017 Andrew Carvajal. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
    }
    
    @objc fileprivate func handleNewMessage() {
        let newMessageController = NewMessageController()
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    fileprivate func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
        if let dictionary = snapshot.value as? [String: Any] {
//            self.navigationItem.title = dictionary["name"] as? String
            
            let user = FirechatUser()
            user.setValuesForKeys(dictionary)
            self.setupNavBar(with: user)
        }
            
        }, withCancel: nil)
    }
    
    func setupNavBar(with user: FirechatUser) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageURL = user.profileImageURL {
            profileImageView.loadImageUsingCache(with: profileImageURL)
        }
        
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)

        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
        
        titleView.addSubview(button)
        
        button.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: titleView.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: titleView.heightAnchor).isActive = true
    }
    
    @objc fileprivate func showChatController() {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc fileprivate func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
}

