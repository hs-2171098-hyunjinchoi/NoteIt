//
//  ViewController.swift
//  Notes
//
//  Created by chj on 6/5/24.
//

import UIKit
import CoreData

// 앱의 메인 뷰 컨트롤러로, 메모 리스트를 보여주고 관리
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var label: UILabel!
    
    // CoreData에서 가져온 메모 데이터를 저장할 배열
    var models: [Note] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self // 테이블 뷰의 delegate 설정
        table.dataSource = self // 테이블 뷰의 dataSource 설정
        title = "Notes" // 네비게이션 바의 타이틀 설정
        loadNotes() // CoreData에서 메모 데이터 로드
    }
    
    // 날짜 포맷팅하는 함수
    // nil이면 nil을 반환
    func formatDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // CoreData에서 모든 메모 데이터를 가져와서 테이블 뷰를 업데이트하는 함수
    func loadNotes() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()

        // 날짜에 따라 노트를 정렬
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            models = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.isHidden = self.models.isEmpty
                self.label.isHidden = !self.models.isEmpty
            }
        } catch {
            print("Failed to fetch notes: \(error)")
        }
    }


    // 'New Note' 버튼을 탭했을 때 호출되는 액션
    @IBAction func didTapNewNote() {
        guard let vc = storyboard?.instantiateViewController(identifier: "new") as? EntryViewController else {
            return
        }
        vc.title = "New Note"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { noteTitle, note in
            self.navigationController?.popToRootViewController(animated: true)
            self.loadNotes() // 새 메모를 추가한 후 데이터를 다시 로드
        }
        navigationController?.pushViewController(vc, animated: true)
    }
   
    // 스와이프 액션을 위한 메소드
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 공유 액션 생성
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, view, completionHandler) in
            self.shareNote(at: indexPath)
            completionHandler(true)
        }
        shareAction.backgroundColor = UIColor.systemYellow
        
        // 삭제 액션 생성
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.presentDeleteAlert(at: indexPath)
            completionHandler(true)
        }

        // 액션 배열을 설정과 함께 반환
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return configuration
    }
    
    // 공유 기능을 위한 메소드
    private func shareNote(at indexPath: IndexPath) {
        let note = models[indexPath.row]
        let noteText = note.note ?? "No content to share"
        let activityViewController = UIActivityViewController(activityItems: [noteText], applicationActivities: nil)
        
        // iPad에서의 공유 문제를 방지
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        // ActivityViewController를 표시
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // 삭제 확인 알림 표시
    func presentDeleteAlert(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "메모 삭제", message: "이 메모를 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            self.deleteNote(at: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    // 메모 삭제 로직
    func deleteNote(at indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let noteToDelete = models[indexPath.row]
        
        // Core Data에서 메모 삭제
        context.delete(noteToDelete)
        models.remove(at: indexPath.row)

        // tableView 참조하여 행 삭제
        self.table.deleteRows(at: [indexPath], with: .fade)

        do {
            try context.save()
        } catch {
            print("Error saving context after deleting note: \(error)")
        }
    }



    // 테이블 뷰의 행 수를 반환하는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    // 각 행의 셀을 구성하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let note = models[indexPath.row]
        cell.textLabel?.text = note.title
        
        let dateString = formatDate(note.date) ?? "No Date"
        cell.detailTextLabel?.text = "\(dateString)"
        
        return cell
    }

    // 테이브 뷰의 행이 선택되었을 때 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let note = models[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "note") as? NoteViewController else {
            print("Failed to instantiate NoteViewController")
            return
        }
        vc.noteTitle = note.title ?? ""
        vc.note = note.note ?? ""
        vc.noteObject = note // 선택된 메모 객체 전달
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes() // 메모 데이터 새로고침
    }

}
