//
//  ViewController.swift
//  Task2
//
//  Created by skia mac mini on 5/7/24.
//

import UIKit

final class ViewController: UIViewController {

    private let viewModel: MainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            do {
                async let studies = self.viewModel.requestStudyList()
                async let series = self.viewModel.requestSeries(of: "1")
                
                print(try await studies)
                print("================")
                print(try await series)
            }
            catch {
                print("Error -- \(error)")
            }
        }
    }


}

