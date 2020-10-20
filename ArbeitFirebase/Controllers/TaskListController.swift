// Created for ArbeitFirebase on 10/19/20 
// Using Swift 5.0 
// Running on macOS 11.0
// Qapla'
//

import UIKit
import Firebase

class TaskListController: UITableViewController {
  
  // MARK: Properties
  var tasks: [Task] = []
  var user: User!
  let tasksReference = Database.database().reference(withPath: "tasks")
  let usersReference = Database.database().reference(withPath: "online")

  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    // Printing out to console
//     tasksReference.observe(.value, with: {
//       snapshot in
//         print(snapshot)
//     })
    
    // Populating the initial list by observing the reference
    tasksReference.queryOrdered(byChild: "name").observe(.value, with: { snapshot in
      var newTasks: [Task] = []
      for child in snapshot.children {
        if let snapshot = child as? DataSnapshot,
          let task = Task(snapshot: snapshot) {
          newTasks.append(task)
        }
      }
      
      self.tasks = newTasks
      self.tableView.reloadData()
    })
    
    
    // What am I doing here?
    Auth.auth().addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      
      let currentUserRef = self.usersReference.child(self.user.uid)
      currentUserRef.setValue(self.user.email)
      currentUserRef.onDisconnectRemoveValue()
    }

  }
    

  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let task = tasks[indexPath.row]
    
    cell.textLabel?.text = task.name
    cell.detailTextLabel?.text = task.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: task.completed)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let task = tasks[indexPath.row]
      task.ref?.removeValue()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let task = tasks[indexPath.row]
    let toggledCompletion = !task.completed
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    task.ref?.updateChildValues([
      "completed": toggledCompletion
      ])
  }
  
  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = .black
      cell.detailTextLabel?.textColor = .black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = .gray
      cell.detailTextLabel?.textColor = .gray
    }
  }
  
  
  // MARK: Add Item
  @IBAction func didTouchAddTask(_ sender: AnyObject) {
    let alert = UIAlertController(title: "New Task",
                                  message: "Add a Task",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      guard let textField = alert.textFields?.first,
        let text = textField.text
      else { return }
      
      
//      let task = Task(name: text,
//                        addedByUser: "profh@cmu.edu",
//                        completed: false)

      let task = Task(name: text,
                        addedByUser: self.user.email,
                        completed: false)
      

      let taskReference = self.tasksReference.child(text.lowercased())
      
      taskReference.setValue(task.toAnyObject())
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }

}
