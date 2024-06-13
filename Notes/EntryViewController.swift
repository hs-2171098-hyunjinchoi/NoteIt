//
//  EntryViewController.swift
//  Notes
//
//  Created by chj on 6/5/24.
//
import UIKit
import CoreData
import Speech

// 사용자가 메모를 음성으로 입력할 수 있는 뷰 컨트롤러
class EntryViewController: UIViewController, SFSpeechRecognizerDelegate {

    // UI 컴포넌트 연결
    @IBOutlet var titleField: UITextField! // 제목을 입력받는 텍스트 필드
    @IBOutlet var noteField: UITextView! // 메모를 입력받는 텍스트 뷰
    @IBOutlet weak var recordButton: UIButton! // 녹음을 제어하는 버튼
    
    // 음성 인식을 위한 객체
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    public var completion: ((String, String) -> Void)?

        
    private var currentText = "" // 현재까지 인식된 전체 텍스트를 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.becomeFirstResponder()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        speechRecognizer.delegate = self
        requestSpeechAuthorization() // 음성 인식 권한 요청
    }

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: // 권한이 허용된 경우
                    self.recordButton.isEnabled = true
                default: // 권한이 거부된 경우
                    self.recordButton.isEnabled = false
                    self.noteField.text = "Speech recognition authorization denied."
                }
            }
        }
    }
        
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            sender.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            sender.setTitle("Stop Recording", for: .normal)
        }
    }
        
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        currentText = noteField.text // 현재 텍스트를 저장

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
        }

        try? audioEngine.start()

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            var isFinal = false

            if let result = result {
                self.noteField.text = currentText + " " + result.bestTranscription.formattedString
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                stopRecording()
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    @objc func didTapSave() {
        if let titleText = titleField.text, !titleText.isEmpty, let noteText = noteField.text, !noteText.isEmpty {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext

            let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
            newNote.title = titleText
            newNote.note = noteText
            newNote.date = Date()

            do {
                try context.save()
                navigationController?.popViewController(animated: true)
            } catch {
                print("Failed to save note: \(error)")
            }
        }
    }
}
