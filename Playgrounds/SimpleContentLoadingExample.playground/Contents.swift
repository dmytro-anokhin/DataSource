//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import DataSource


class AnimalsDataSource: TableViewDataSource {

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
    
    private var animals: [String] = []

    override func loadContent() {
        DispatchQueue.global().async {
            let animals = [ "Cheetah", "Puma", "Jaguar" ]
            
            DispatchQueue.main.async {
                self.animals = animals
                self.notifyUpdate(TableViewUpdate.reloadData())
            }
        }
    }
}


class TableViewController: UIViewController, UpdateObserver {
    
    var tableView: UITableView {
        return view as! UITableView
    }
    
    let dataSource = AnimalsDataSource()
    
    override func loadView() {
        view = UITableView(frame: .zero, style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.updateObserver = self
        dataSource.registerReusableViews(with: tableView)
        dataSource.loadContent()
        tableView.dataSource = dataSource
    }
    
    func perform(update: Update, from sender: UpdateObservable) {
        update.perform(tableView)
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = TableViewController()

