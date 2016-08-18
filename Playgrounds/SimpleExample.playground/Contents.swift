//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import DataSource


class AnimalsDataSource : TableViewDataSource {

    private var animals = [ "Cheetah", "Puma", "Jaguar" ]

    func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnimalCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)
        cell.textLabel?.text = animals[indexPath.row]
        return cell
    }
}


class TableViewController: UIViewController {
    
    var tableView: UITableView {
        return view as! UITableView
    }
    
    let dataSource = AnimalsDataSource()
    
    override func loadView() {
        view = UITableView(frame: .zero, style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.registerReusableViews(with: tableView)
        tableView.dataSource = dataSource
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = TableViewController()

