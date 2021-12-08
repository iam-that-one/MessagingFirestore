//
//  ViewController.swift
//  ChatFireStore
//
//  Created by Abdullah Alnutayfi on 07/12/2021.
//

import UIKit
import Firebase
import FirebaseFirestore
class Login: UIViewController {
    let fireStore = Firestore.firestore()
    
    lazy var nameTf : UITextField = {
        $0.placeholder = "Enter your name"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.borderStyle = .roundedRect
        return $0
    }(UITextField())
    lazy var signIn : UIButton = {
        $0.titleLabel?.font =  UIFont.systemFont(ofSize: 28, weight: .bold)
        $0.setTitle("signIn", for: .normal)
        $0.setBackgroundImage(UIImage(named: "btn"), for: .normal)
        $0.tintColor = .black
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(signInBtnClick), for: .touchDown)

        return $0
    }(UIButton(type: .system))
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        view.addSubview(signIn)
        view.addSubview(nameTf)
        
      
        nameTf.bottomAnchor.constraint(equalTo: signIn.topAnchor,constant: -20).isActive = true
        nameTf.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nameTf.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signIn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signIn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        signIn.heightAnchor.constraint(equalToConstant: 80).isActive = true
        signIn.widthAnchor.constraint(equalToConstant: 300).isActive = true
        print("Login page has loaded")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser?.uid != nil{
        let usersView = UsersView()
        self.present(usersView, animated: true, completion: nil)
        }
    }

    @objc func signInBtnClick(){
        if Auth.auth().currentUser?.uid == nil{
            Auth.auth().signInAnonymously { AnnUser, error in
                if let error = error{
                    print(error)
                }else{
                    let data = ["Name":self.nameTf.text!, "ID" : AnnUser?.user.uid]
                    self.fireStore.collection("Users").document((AnnUser?.user.uid)!).setData(data as [String : Any])
                    let usersView = UsersView()
                    self.present(usersView, animated: true, completion: nil)
                }
            }
        }else{
            let usersView = UsersView()
            self.present(usersView, animated: true, completion: nil)
        }
    }
}
