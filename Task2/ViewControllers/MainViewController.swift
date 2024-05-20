//
//  ViewController.swift
//  Task2
//
//  Created by skia mac mini on 5/7/24.
//

import UIKit
import OSLog

final class MainViewController: UIViewController {

    private let viewModel: MainViewModel = MainViewModel()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    
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
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    private func registerTableViewCell() {
        self.resultTableView.register(
            UINib(nibName: DicomTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: DicomTableViewCell.identifier
        )
      
        self.resultTableView.register(
            UINib(nibName: SeriesTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: SeriesTableViewCell.identifier
        )
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections()
    }
    
    // - MARK: UITableViewDelegate, UITableViewDataSource methods.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRows(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studySection = self.viewModel.cellItem(at: indexPath.section)
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DicomTableViewCell.identifier, for: indexPath
            ) as? DicomTableViewCell else { fatalError() }
            
            cell.configure(with: studySection)
            
            return cell
            
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SeriesTableViewCell.identifier, for: indexPath
        ) as? SeriesTableViewCell else { fatalError() }
        
        cell.configure(with: studySection.seriesList[indexPath.row-1])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowItem = self.viewModel.cellItem(at: indexPath.section)
        rowItem.isExpanded.toggle()
        
        guard rowItem.isExpanded,
              rowItem.seriesList.isEmpty else {
            self.resultTableView.reloadSections(
                [indexPath.section],
                with: .automatic
            )
            return
        }
      
        Task {
            do {
                let seriesList = try await self.viewModel.requestSeries(of:"\(rowItem.study.id)")
                
                rowItem.seriesList = seriesList.map{
                    SeriesInfo(series: $0)
                }
                
                self.resultTableView.reloadSections(
                    [indexPath.section],
                    with: .automatic
                )
            }
            catch {
                Logger.network.error("\(error)")
            }
        }
        
    }
}
