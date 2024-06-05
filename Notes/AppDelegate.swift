//
//  AppDelegate.swift
//  Notes
//
//  Created by chj on 6/5/24.
//

import UIKit
import CoreData

// 앱의 생명주기 관리 및 중앙 설정을 담당하는 클래스
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // MARK: - Core Data stack
    // Core Data의 persistent container를 설정
    // 이 컨테이너는 앱의 데이터 모델을 관리하고, 데이터 저장소에 액세스를 제공
    lazy var persistentContainer: NSPersistentContainer = {
        // 'MemoDataVerModel'의 이름으로 Core Data stack 초기화
        let container = NSPersistentContainer(name: "MemoDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            // 데이터 저장소 로드 시 오류 발생하면 로그로 출력
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support
    // 변경사항이 있는 경우, Core Data context를 저장
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()  // 변경사항 저장
            } catch let error as NSError {
                // 오류 발생 시, 앱 중단하고 오류 정보 출력
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // 앱 시작 시 최초 실행되는 메서드
    // 앱 설정과 초기화 코드를 이곳에서 처리
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
    // 새로운 Scene 연결 설정 시 호출되는 메서드
    // 여기서 새 Scene의 설정을 선택
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // 새로운 scene 생성을 위한 설정을 반환
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // 사용자가 Scene을 폐기할 때 호출되는 메서드
    // 폐기된 Scene 관련 자원을 정리할 때 사용
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 폐기된 Scene의 리소스를 해제하거나 정리할 작업을 수행
    }


}

