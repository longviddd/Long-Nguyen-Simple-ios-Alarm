//
//  addViewController.swift
//  LongNguyenProject_1911961
//
//  Created by english on 2020-12-02.
//  Copyright © 2020 Piyush. All rights reserved.
//
//import CoreData in order to use the database
import CoreData
import UIKit
import UserNotifications
class addViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var titleField: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    public var completion: ((String, String, Date) -> Void)?
    @objc func didTapSaveButton(){
        if let titleText = titleField.text, !titleText.isEmpty,
            let bodyText = bodyField.text, !bodyText.isEmpty{
            let targetDate = datePicker.date
            // fill out the variables if validation is right
            let alarmId = UUID()
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            //call the share delegate from swift appdelegate file
            let context = appdelegate.persistentContainer.viewContext
            //create a context that is from the class viewContext in the appdelegate
            let newAlarm = NSEntityDescription.insertNewObject(forEntityName: "Reminders", into: context)
            //create a new alarm into the context that will be saved into the "Reminders" database
            newAlarm.setValue(alarmId, forKey: "id")
            newAlarm.setValue(titleText, forKey: "title")
            newAlarm.setValue(bodyText, forKey: "body")
            newAlarm.setValue(targetDate, forKey: "date")

            print(alarmId)
            do{
                try context.save()
            }catch{
                print("Error occured")
            }
            // ask user to authorizes sound, alert and badges.
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
                if success {
                    //create a notfication content
                    let content = UNMutableNotificationContent()
                        content.title = titleText
                        content.sound = .default
                        content.body = bodyText
                        let notiDate = targetDate
                    //create a trigger at the exact time of targetDate
                        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],from: notiDate),repeats: false)
                    //create a request when that trigger happens
                    let request = UNNotificationRequest(identifier: alarmId.uuidString, content: content, trigger: trigger)
                    //add the request to the User Notification Center
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                          if error != nil {
                            print("something went wrong")
                          }
                       })
                }
                else if error != nil {
                    print("error occurred")
                }
            })
                                                                                                      
            NotificationCenter.default.post(name: NSNotification.Name("newNotification"), object: nil)
            // add a notification in the notificationcenter named "newPainting" everytime btnSave is clicked.
            navigationController?.popViewController(animated: true)
            //return to the top view controller. navigationController? because it is optional. navigationcontroller might or might not exist.
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save", style: .done, target: self, action: #selector(didTapSaveButton))
        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
