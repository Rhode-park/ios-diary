//
//  Diary - DetailDiaryViewController.swift
//  Created by Rhode, 무리.
//  Copyright © yagom. All rights reserved.
//

import UIKit

final class DetailDiaryViewController: UIViewController {
    private var diaryDate: String?
    
    private let bodyTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = NameSpace.diaryPlaceholder
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSubview()
        configureConstraint()
        addKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeKeyboardNotification()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        bodyTextView.setContentOffset(.zero, animated: true)
        
        if diaryDate == nil {
            title = Date().convertDate()
        }
    }
    
    private func configureSubview() {
        view.addSubview(bodyTextView)
    }
    
    private func configureConstraint() {
        guard let navigationController,
              let firstWindow = UIApplication.shared.windows.first else { return }
        
        let changedHeight = navigationController.navigationBar.frame.height - firstWindow.safeAreaInsets.top
        
        NSLayoutConstraint.activate([
            bodyTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                              constant: changedHeight),
            bodyTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bodyTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bodyTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func configureContent(diary: Diary) {
        bodyTextView.text = diary.title + NameSpace.doubleNewline + diary.body
        diaryDate = Date(timeIntervalSince1970: diary.date).convertDate()
        title = diaryDate
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           let firstWindow = UIApplication.shared.windows.first {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let changedHeight = keyboardHeight - firstWindow.safeAreaInsets.bottom
            UIView.animate(withDuration: 0.5) {
                NSLayoutConstraint.activate([
                    self.bodyTextView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                                                              constant: -changedHeight)
                ])
            }
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        if self.view.window?.frame.origin.y != 0 {
            if let keyboardFrame: NSValue =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
               let firstWindow = UIApplication.shared.windows.first {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let changedHeight = keyboardHeight - firstWindow.safeAreaInsets.bottom
                UIView.animate(withDuration: 0.5) {
                    self.view.window?.frame.origin.y += changedHeight
                }
            }
        }
    }
}
