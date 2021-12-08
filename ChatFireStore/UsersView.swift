//
//  FirestChat.swift
//  ChatFireStore
//
//  Created by Abdullah Alnutayfi on 07/12/2021.
//

import UIKit
import Firebase
import FirebaseFirestore
class UsersView: UIViewController {
    var users : [User] = []

    let firestore = Firestore.firestore()
    lazy var signOutLable : UIButton = {
        $0.titleLabel?.font =  UIFont.systemFont(ofSize: 28, weight: .bold)
        $0.setTitle("SignOut", for: .normal)
        $0.tintColor = .black
        $0.addTarget(self, action: #selector(signOutBtnClick),for: .touchDown)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .system))
    
    lazy var usersTableView : UITableView = {
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 200
        $0.register(MyUsersCell.self, forCellReuseIdentifier: "userCell")
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsers()
        [signOutLable,usersTableView].forEach{view.addSubview($0)}
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            signOutLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            signOutLable.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -50),
            
            usersTableView.topAnchor.constraint(equalTo: signOutLable.bottomAnchor),
            usersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            usersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            usersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        ])

    }
    
    @objc func signOutBtnClick(){
        do{
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        }catch{}
    }
    func getUsers(){
        firestore.collection("Users").getDocuments { snapShot, error in
            for user in snapShot!.documents{
                print(user.documentID)
                print(user.data())
                self.users.append(User(name: user.get("Name") as! String, id: user.get("ID") as! String))
            }
            self.usersTableView.reloadData()
        }
    }
}

extension UsersView : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! MyUsersCell
        cell.uaername.text = users[indexPath.row].name
        cell.imgView.image = UIImage(systemName: "person.circle.fill")

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatView = Chat()
       // chatView.modalPresentationStyle = .fullScreen
        chatView.id = users[indexPath.row].id
        chatView.name = users[indexPath.row].name
        self.present(chatView, animated: true, completion: nil)
    }
}

struct User{
    let name : String
    let id : String
}
