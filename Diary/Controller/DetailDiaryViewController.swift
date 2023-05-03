//
//  Diary - DetailDiaryViewController.swift
//  Created by Rhode, 무리.
//  Copyright © yagom. All rights reserved.
//

import UIKit
import CoreData

final class DetailDiaryViewController: UIViewController {
    private var diaryDate: String?
    private var bottomConstraint: NSLayoutConstraint?
    private var coreDataManager = CoreDataManager.shared
    private var isCreateDiary: Bool = false
    private var isSaveRequired: Bool = true
    private var diary: Diary?
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = NameSpace.diaryPlaceholder
        textView.keyboardDismissMode = .interactive
        
        return textView
    }()
    
    private let detailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        
        return button
    }()
    
    init(isCreateDiary: Bool, isSaveRequired: Bool) {
        self.isCreateDiary = isCreateDiary
        self.isSaveRequired = isSaveRequired
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSubview()
        configureConstraint()
        configureKeyboard()
        addKeyboardNotification()
        enterBackgroundNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveDiary()
    }
    
    func configureContent(diary: Diary) {
        self.diary = diary
        diaryTextView.text = diary.title + NameSpace.newline + diary.body
        diaryTextView.contentOffset = CGPoint.zero
        diaryDate = Date(timeIntervalSince1970: diary.date).convertDate()
        self.title = diaryDate
    }
    
    // MARK: - configure method
    private func configureSubview() {
        view.addSubview(diaryTextView)
    }
    
    private func configureConstraint() {
        bottomConstraint = diaryTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            diaryTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            diaryTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            diaryTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        diaryTextView.delegate = self
        diaryTextView.setContentOffset(.zero, animated: true)
        
        detailButton.addTarget(self, action: #selector(showDetailAction), for: .touchUpInside)
        let detailDiaryButon = UIBarButtonItem(customView: detailButton)
        navigationItem.rightBarButtonItem = detailDiaryButon
        
        if diaryDate == nil {
            title = Date().convertDate()
        }
    }
    
    private func configureKeyboard() {
        if isCreateDiary {
            diaryTextView.becomeFirstResponder()
        }
    }
    
    private func configureDiary() -> Diary? {
        let id = UUID()
        let diaryContents = diaryTextView.text.split(separator: "\n", maxSplits: 1)
        let title = String(diaryContents[0])
        var body: String
        
        if diaryContents.count == 2 {
            body = String(diaryContents[1])
        } else {
            body = NameSpace.empty
        }
        
        guard let date = Date().timeIntervalSince1970.roundDownNumber() else { return nil }
        
        return Diary(title: title, body: body, date: date, id: id)
    }
    
    // MARK: - Notification method
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
    
    private func enterBackgroundNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue =
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           let firstWindow = UIApplication.shared.windows.first {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let changedHeight = -(keyboardHeight - firstWindow.safeAreaInsets.bottom)
            bottomConstraint?.constant = changedHeight
        }
    }
    
    @objc
    private func keyboardWillHide() {
        bottomConstraint?.constant = 0
    }
    
    @objc
    private func didEnterBackground() {
        saveDiary()
    }
    
    // MARK: - Action Sheet method
    @objc
    private func showDetailAction() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let share = UIAlertAction(title: "공유", style: .default) { _ in
            self.showActivityViewController()
        }
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.deleteDiary()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        actionSheet.addAction(share)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true)
    }
    
    private func showActivityViewController() {
        let activityItems = [UIActivity.ActivityType.airDrop, .message, .mail]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - CoreData method
    private func saveDiary() {
        if isSaveRequired {
            if isCreateDiary {
                createDiary()
            } else {
                updateDiary()
            }
            
            isSaveRequired = false
        }
    }
    
    private func createDiary() {
        guard let diary = configureDiary() else { return }
        
        coreDataManager.createDiary(diary)
    }
    
    private func updateDiary() {
        let diaryContents = diaryTextView.text.split(separator: "\n", maxSplits: 1)
        let title = String(diaryContents[0])
        let body = String(diaryContents[1])
        
        guard let id = diary?.id,
              let date = Date().timeIntervalSince1970.roundDownNumber() else { return }
        
        let updatedDiary = Diary(title: title, body: body, date: date, id: id)
        
        coreDataManager.updateDiary(diary: updatedDiary)
    }

    private func deleteDiary() {
        guard let diary else { return }
        
        coreDataManager.deleteDiary(diary: diary)
        isSaveRequired = false
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension DetailDiaryViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        saveDiary()
    }
}

private enum NameSpace {
    static let diaryPlaceholder = "내용을 입력하세요"
    static let newline = "\n"
    static let empty = ""
}
