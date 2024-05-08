//
//  ViewController.swift
//  Task2
//
//  Created by skia mac mini on 5/7/24.
//

import UIKit

final class MainViewController: UIViewController {

    private let viewModel: MainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                let studies = try await self.viewModel.requestStudyList()
                async let series = self.viewModel.requestDicomSeriesOfStudyList(studies)
                
                /// `Study list` 와 각  `Study`에 속한 `Series` 정보 출력
                print(studies)
                print("================================")
                print(try await series)
            }
            catch {
                print("Error -- \(error)")
            }
        }
    }


}

