//
//  SecondChat.swift
//  ChatFireStore
//
//  Created by Abdullah Alnutayfi on 07/12/2021.
//

import UIKit
import FirebaseFirestore
import Firebase
class Chat: UIViewController {
    var myName  = ""
    let firestore = Firestore.firestore()
    let myId = Auth.auth().currentUser?.uid
    var id : String?
    var name : String?
    var messages: [Message] = []
    lazy var chatTableView : UITableView = {
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 200
        $0.register(MyChatCell.self, forCellReuseIdentifier: "chatCell")
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())
    
    lazy var messageTextField : UITextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.borderStyle = .roundedRect
        return $0
    }(UITextField())
    
    lazy var sedBtn : UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Send", for: .normal)
        $0.addTarget(self, action: #selector(sendMSG), for: .touchDown)
        return $0
    }(UIButton(type: .system))
    override func viewDidLoad() {
        fetchMesssages()
        super.viewDidLoad()
        print(id!, name!)
        view.backgroundColor = .white
        view.addSubview(chatTableView)
        view.addSubview(messageTextField)
        view.addSubview(sedBtn)
        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant:20),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chatTableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor),
            
           // messageTextField.topAnchor.constraint(equalTo: chatTableView.bottomAnchor,constant: 20),
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            messageTextField.widthAnchor.constraint(equalToConstant: 300),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            sedBtn.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor,constant: 10),
            sedBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
          
        ])
        
        // Do any additional setup after loading the view.
    }
    
    @objc func sendMSG(){
        let msg = ["content": messageTextField.text!, "id": myId, "date" : dateFormatter.string(from: Date()), "Name" : myName]
        print("*******\(myName)")
        let myId = Auth.auth().currentUser?.uid
        firestore.collection("Users").document(myId!)
            .collection("Message").document(self.id!).collection("msg").document().setData(msg as [String : Any])
        
        
        firestore.collection("Users").document(self.id!)
            .collection("Message").document(myId!).collection("msg").document().setData(msg as [String : Any])
        fetchMesssages()
    }
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.timeZone = TimeZone(secondsFromGMT: 3)
        return formatter
    }()
}

extension Chat : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell",for: indexPath) as! MyChatCell
       
        cell.username.text = messages[indexPath.row].name
        cell.message.text = messages[indexPath.row].content
        return cell
    }
    
    func fetchMesssages(){
        let name = firestore.collection("Users").document(myId!)
        name.getDocument { user, error in
            if let error = error{
                print(error)
            }else{
                if Auth.auth().currentUser?.uid == user?.get("ID") as? String{
                self.myName = user?.get("Name") as! String
                }
                print("###########")
                print(self.myName)
            }
        }
        firestore.collection("Users").document(myId!)
            .collection("Message").document(self.id!).collection("msg")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in
                self.messages = []
                if let e = error {
                    print(e)
                }else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        for document in snapshotDocuments {
                            let data = document.data()
                            if  let msg = data["content"] as? String,
                            let id = data["id"] as? String,
                                let date = data["date"] as? String,
                                let name = data["Name"] as? String
                            {
                                let fetchedMessage = Message(content: msg, id: id, date: date, name: name)
                                self.messages.append(fetchedMessage)
                                DispatchQueue.main.async {
                                    self.chatTableView.reloadData()
                                    
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}


struct Message {
    let content: String
    let id : String
    let date : String
    let name : String
}

