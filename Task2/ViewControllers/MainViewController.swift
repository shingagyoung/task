//
//  ViewController.swift
//  Task2
//
//  Created by skia mac mini on 5/7/24.
//

import UIKit

final class MainViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    
    private let viewModel: MainViewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegate()
        self.registerTableViewCell()
        
        Task {
            await self.viewModel.fetchStudySectionData()
            self.resultTableView.reloadData()
        }
        
    }

    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let text = self.searchTextField.text else { return }
        Task {
            await self.viewModel.fetchStudySectionData(with: text)
            self.resultTableView.reloadData()
        }
        
    }
    
    private func setDelegate() {
        self.resultTableView.delegate = self
        self.resultTableView.dataSource = self
    }
    
    private func registerTableViewCell() {
        self.resultTableView.register(UINib(nibName: "DicomTableViewCell", bundle: nil), forCellReuseIdentifier: "DicomTableViewCell")
      
        self.resultTableView.register(UINib(nibName: "SeriesTableViewCell", bundle: nil), forCellReuseIdentifier: "SeriesTableViewCell")
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studySection = self.viewModel.cellItem(at: indexPath.section)
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DicomTableViewCell", for: indexPath) as? DicomTableViewCell else { fatalError() }
            
            cell.configure(with: studySection)
            
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeriesTableViewCell", for: indexPath) as? SeriesTableViewCell else { fatalError() }
            
            cell.configure(with: studySection.seriesList[indexPath.row-1])
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowItem = self.viewModel.cellItem(at: indexPath.section)
        rowItem.isExpanded.toggle()
        
        if rowItem.isExpanded {
            Task {
                do {
                    let seriesList = try await self.viewModel.requestSeries(of:"\(rowItem.study.id)")
                    rowItem.seriesList = seriesList
                    
                    self.resultTableView.reloadSections(
                        [indexPath.section],
                        with: .automatic
                    )
                }
                catch {
                    print("Error -- \(error.localizedDescription)")
                }
            }
        } else {
            self.resultTableView.reloadSections(
                [indexPath.section],
                with: .automatic
            )
        }
    }
}
