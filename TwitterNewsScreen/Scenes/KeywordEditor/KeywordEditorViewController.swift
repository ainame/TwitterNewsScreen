//
//  KeywordEditorViewController.swift
//  TwitterNewsScreen
//
//  Created by Namai Satoshi on 2017/02/19.
//  Copyright © 2017年 ainame. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class KeywordEditorViewController: UIViewController {
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var keywordLaunchButton: UIButton!
    @IBOutlet weak var screenNameLaunchButton: UIButton!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        keywordLaunchButton.rx.tap
            .asObservable()
            .subscribe(onNext: launchWithKeyword)
            .disposed(by: disposeBag)

        screenNameLaunchButton.rx.tap
            .asObservable()
            .subscribe(onNext: launchWithScreenName)
            .disposed(by: disposeBag)
    }

    func launchWithKeyword() {
        guard let keyword = keywordTextField.text, !keyword.isEmpty else {
            showAlert(message: "空で入力しないで")
            return
        }

        let launchOption = ImageScreenViewController.LaunchOption.keyword(keyword)
        presentImageScreenViewController(launchOption)
    }

    func launchWithScreenName() {
        guard let screenName = keywordTextField.text, !screenName.isEmpty else {
            showAlert(message: "空で入力しないで")
            return
        }

        let launchOption = ImageScreenViewController.LaunchOption.screenName(screenName)
        presentImageScreenViewController(launchOption)
    }

    private func presentImageScreenViewController(_ launchOption: ImageScreenViewController.LaunchOption) {
        let vc = UIStoryboard(name: "ImageScreenViewController", bundle: nil).instantiateInitialViewController()! as! ImageScreenViewController
        vc.launchOption = launchOption

        present(vc, animated: true, completion: nil)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
