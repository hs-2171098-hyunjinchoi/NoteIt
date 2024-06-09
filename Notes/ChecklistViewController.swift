//
//  ChecklistViewController.swift
//  Notes
//
//  Created by chj on 6/9/24.
//

import UIKit
import CoreData

class ChecklistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var items: [ChecklistItem] = []
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var label: UILabel!
    
    // MARK: - IBActions
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        // 새로운 체크리스트 항목 추가 알림창
        let alertController = UIAlertController(title: "New Checklist Item", message: "Add a new item", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Item title"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self] action in
            guard let title = alertController.textFields?.first?.text, !title.isEmpty else { return }
            
            let newItem = ChecklistItem(context: self.context)
            newItem.title = title
            newItem.isChecked = false
            newItem.createdAt = Date()
            
            self.items.append(newItem)
            self.saveItems()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        loadItems()
    }
    
    // MARK: - Data Handling Methods
    func loadItems() {
        let request: NSFetchRequest<ChecklistItem> = ChecklistItem.fetchRequest()
        do {
            items = try context.fetch(request)
            DispatchQueue.main.async { // UI 업데이트를 메인 스레드에서 처리
                self.tableView.isHidden = self.items.isEmpty
                self.label.isHidden = !self.items.isEmpty
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching checklist items: \(error)")
        }
    }

    
    func saveItems() {
        do {
            try context.save()
            DispatchQueue.main.async { // 메인 스레드에서 UI 업데이트
                self.tableView.reloadData()
                self.tableView.isHidden = self.items.isEmpty
                self.label.isHidden = !self.items.isEmpty
            }
        } catch {
            print("Error saving checklist items: \(error)")
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isChecked ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].isChecked.toggle()
        saveItems()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 항목 삭제 전 사용자 확인
            let alert = UIAlertController(title: "항목 삭제", message: "이 항목을 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.context.delete(self.items[indexPath.row])
            self.items.remove(at: indexPath.row)
            self.saveItems()
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadItems() // 체크 리스트 데이터 새로고침
    }
}
