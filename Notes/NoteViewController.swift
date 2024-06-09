//
//  NoteViewController.swift
//  Notes
//
//  Created by chj on 6/5/24.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet var titleLabel: UITextView!
    @IBOutlet var noteLabel: UITextView!
    
    public var noteTitle: String = ""
    public var note: String = ""
    var noteObject: Note?

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = noteTitle  // 네비게이션 바의 타이틀 설정
        titleLabel.text = noteTitle
        titleLabel.isEditable = true // 편집 가능하도록 설정
        
        noteLabel.text = note
        noteLabel.isEditable = true // 편집 가능하도록 설정
    }
    
    @IBAction func saveNote() {
        if let noteObject = self.noteObject, let newTitle = titleLabel.text, let newText = noteLabel.text {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                // 메모 제목 업데이트
                noteObject.title = newTitle

                // 메모 내용 업데이트
                noteObject.note = newText

                // 날짜를 현재 시간으로 업데이트
                noteObject.date = Date()

                do {
                    try context.save()
                    navigationController?.popViewController(animated: true)
                } catch {
                    print("Error saving the updated note: \(error)")
                }
            }
    }
}
