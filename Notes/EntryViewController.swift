//
//  EntryViewController.swift
//  Notes
//
//  Created by chj on 6/5/24.
//
import UIKit
import CoreData

class EntryViewController: UIViewController {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var noteField: UITextView!
    
    public var completion: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    @objc func didTapSave() {
        if let titleText = titleField.text, !titleText.isEmpty, let noteText = noteField.text, !noteText.isEmpty {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
            newNote.title = titleText
            newNote.note = noteText
            newNote.date = Date() // 현재 날짜를 저장

            do {
                try context.save()
                completion?(titleText, noteText)
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("Failed to save note: \(error)")
            }
        }
    }
}
