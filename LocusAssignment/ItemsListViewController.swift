//
//  ItemsListViewController.swift
//  LocusAssignment
//
//  Created by Sumit Gupta on 08/10/22.
//

import Foundation


class ItemsListViewController: UIViewController, UITableViewDataSource {
    private var tableView = UITableView()
    private var itemsModel: Items? = nil
    private var formModel: NSMutableDictionary = [:] // The model which stores the user input
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchItemsList()
    }
    
    //MARK: - Private functions
    
    private func setupUI() {
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.title = "Locus Assignment"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submitPressed))
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    private func fetchItemsList() {
        guard let path = Bundle.main.path(forResource: "json_input", ofType: "json") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            let jsonData = try Data(contentsOf: url)
            let items = try JSONDecoder().decode(Items.self, from: jsonData)
            self.itemsModel = items
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    //MARK: - Actions
    
    @objc private func submitPressed() {
        print(self.formModel)
    }
    
    //MARK: - UITableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = itemsModel {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let itemsModel = itemsModel, indexPath.row < itemsModel.count else {
            return UITableViewCell()
        }
        let item = itemsModel[indexPath.row]
        switch item.type {
        case .photo:
            let cell = ImageCell(withItem: item, withFormModel: formModel, withParentVC: self)
            cell.applyState(fromModel: formModel)
            return cell
        case .singleChoice:
            let cell = SingleChoiceButtonsCell(withItem: item, withFormModel: formModel)
            cell.applyState(fromModel: formModel)
            return cell
        case .comment:
            let cell = CommentsCell(withItem: item, withFormModel: formModel, withParentTable: tableView)
            cell.applyState(fromModel: formModel)
            return cell
        }
    }
}
