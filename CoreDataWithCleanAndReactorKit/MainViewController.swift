//
//  ViewController.swift
//  CoreDataWithCleanAndReactorKit
//
//  Created by xlab on 2021/01/26.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Main"
        self.navigationController?.navigationBar.tintColor = .gray
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addName))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeFirst))
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
        
        tableView.dataSource = self
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        navigationController?.navigationBar.barTintColor = .gray
        //        navigationController?.navigationBar.backgroundColor = .gray\
        
        //1
        //          guard let appDelegate =
        //            UIApplication.shared.delegate as? AppDelegate else {
        //              return
        //          }
        //
        //          let managedContext =
        //            appDelegate.persistentContainer.viewContext
        
        let managedContext = PersistenceManager.shared.context
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //3
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Clean All
        //        let request: NSFetchRequest<Person> = Person.fetchRequest()
        //        PersistenceManager.shared.deleteAll(request: request)
        //        let arr = PersistenceManager.shared.fetch(request: request)
        //        if arr.isEmpty { print("clean")}
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc func addName() {
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text else {
                return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc func removeFirst() {
        guard let firstObject = people.first else { return }
        PersistenceManager.shared.delete(object: firstObject)
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        people = PersistenceManager.shared.fetch(request: fetchRequest)
        tableView.reloadData()
    }
    
    func save(name: String) {
        
        //      guard let appDelegate =
        //        UIApplication.shared.delegate as? AppDelegate else {
        //        return
        //      }
        //
        //      // 1
        //      let managedContext =
        //        appDelegate.persistentContainer.viewContext
        
        let sharedContext = PersistenceManager.shared.context
        // 2
        guard let entity =
                NSEntityDescription.entity(forEntityName: "Person",
                                           in: sharedContext) else { return }
        
        let person = NSManagedObject(entity: entity,
                                     insertInto: sharedContext)
        
        // 3
        person.setValue(name, forKeyPath: "name")
        // 4
        do {
            try sharedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell",
                                          for: indexPath)
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
}

