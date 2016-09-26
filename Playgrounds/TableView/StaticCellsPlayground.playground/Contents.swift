//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import DataSource


class StaticCellsDataSource: NSObject, TableViewDataSourceType {

    var sections: [[UITableViewCell]]
    
    required init(sections: [[UITableViewCell]]) {
        self.sections = sections
    }
    
    convenience init(rows: [UITableViewCell]) {
        self.init(sections: [rows])
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return object(at: indexPath) as! UITableViewCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    // MARK: - TableViewDataSourceType

    var numberOfSections: Int {
        return sections.count
    }

    // MARK: - DataSourceType

    func object(at indexPath: IndexPath) -> Any? {
        guard indexPath.section < sections.count else { return nil }
        let rows = sections[indexPath.section]
        
        return indexPath.row < rows.count ? rows[indexPath.row] : nil
    }
    
    func indexPaths(for object: Any) -> [IndexPath] {
        guard let cell = object as? UITableViewCell else { return [] }
        
        var indexPaths: [IndexPath] = []
        
        for section in 0..<sections.count {
            let rows = sections[section]
            
            for row in 0..<rows.count {
                guard rows[row] === cell else { continue }
                indexPaths.append(IndexPath(row: row, section: section))
            }
        }
        
        return indexPaths
    }
}


class TableViewController: UIViewController {
    
    var tableView: UITableView {
        return view as! UITableView
    }
    
    var switchCell: UITableViewCell!
    
    var dataSource: StaticCellsDataSource!
    
    override func loadView() {
        view = UITableView(frame: .zero, style: .grouped)
        
        switchCell = {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            
            let stackView = UIStackView(arrangedSubviews: [
                {
                    let label = UILabel(frame: .zero)
                    label.text = "Enable:"
                    
                    return label
                }(),
                {
                    let switchControl = UISwitch(frame: .zero)
                    switchControl.addTarget(self, action: #selector(switchHandler(sender:for:)), for: .valueChanged)
                    
                    return switchControl
                }()
            ])
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(stackView)
            
            let constraints = [
                NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal,
                    toItem: cell.contentView, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal,
                    toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal,
                    toItem: cell.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ]
        
            NSLayoutConstraint.activate(constraints)
            
            return cell
        }()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = StaticCellsDataSource(sections: [ [switchCell] ])
        tableView.dataSource = dataSource
    }
    
    // MARK: - Actions
    
    func switchHandler(sender: UISwitch, for event: UIEvent) {
        if sender.isOn {
            var rows = dataSource.sections[0]
            rows.append({
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Bring it on"
                
                return cell
            }())
            
            dataSource.sections = [rows]
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
        else {
            var rows = dataSource.sections[0]
            rows.removeLast()
            dataSource.sections = [rows]
            
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = TableViewController()

