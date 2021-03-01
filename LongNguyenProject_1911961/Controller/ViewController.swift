//
//  ViewController.swift
//  LongNguyenProject_1911961
//
//  Created by english on 2020-12-01.
//  Copyright © 2020 Piyush. All rights reserved.
//
import CoreData
import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
        // return the amount of row equals to the amount of value in the nameArray
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //create a variable in the type UITableViewCell
        cell.textLabel?.text = nameArray[indexPath.row]
        //indexPath is a type that signifies which row we are filling the data at. indexPath.row will return a number that represents the row. For example, at row 2 it will return 2
        return cell
    }
    
    //create an array of the struct MyReminder
    var nameArray = [String]()
    //create an array for all the name
    var idArray = [UUID]()
    //create an array for all the id
    @IBOutlet weak var table: UITableView!
    //create a function when the user press the add button when clicked on the top right of the screen
    

    //function when you press add button
    @IBAction func didTapAdd(){
        //perform segue to the add view
        performSegue(withIdentifier: "toAddView", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        //viewDidLoad will only work when you turn on the viewcontroller the first time. Therefore, if you want to run any code when the user come back to the viewcontroller you use viewWillAppear
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newNotification"), object: nil)
        //add an observer from the notificationcenter so that when there's a notification in the notificationcenter named "newNotification" run the function in the selector
    }
    @objc func getData(){
        idArray.removeAll(keepingCapacity: false)
        nameArray.removeAll(keepingCapacity: false)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        //call appdelegate from UIApplication again and force as AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
        do{
            let results = try context.fetch(fetchRequest)
            // try to fetch from the context with the fetchRequest created. you always need the context to add or fetch something from the database
            // context.fetch will return an array
            if results.count > 0{
                //check if the array is empty.
                for result in results as! [NSManagedObject]{
                    // force change each result into NSManagedObject, i assume a type that can be fetch into string,int ,etc .
                    if let title = result.value(forKey: "title") as? String{
                        nameArray.append(title)
                        //append the value name into the nameArray
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        print(id)
                        idArray.append(id)
                    }
                    //reload in order to refresh the tableview
                    table.reloadData()
                }
            }
        }catch{
            print("error")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the delegate as well as the dataSource to self
        table.delegate = self
        table.dataSource = self
        //getdata to fill the table
        getData()
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //function to delete the a cell
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let idString = idArray[indexPath.row].uuidString
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminders")
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            do{
                let results = try  context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            var deleteString : [String] = []
                            deleteString.append(id.uuidString)
                            //delete the notification created. won't notify user anymore
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: deleteString)
                            //reload the data
                            tableView.reloadData()
                            do{
                                try context.save()
                            }
                            catch{
                                print("Error")
                            }
                            break
                        }
                    }
                }
            }catch{
                print("Error")
            }
        }
    }


}


