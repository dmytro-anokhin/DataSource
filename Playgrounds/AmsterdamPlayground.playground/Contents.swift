//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
import DataSource


let endpointURL = URL(string: "http://www.amsterdamopendata.nl/files/Festivals.json")!


struct Festival {

    let title: String
}

extension Festival: Equatable {
}

func ==(lhs: Festival, rhs: Festival) -> Bool {
    return lhs.title == rhs.title
}


class HeaderDataSource: TableViewDataSource {

    static let cellReuseIdentifier = "HeaderDataSourceCell"

    class ImageCell: UITableViewCell {
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(_imageView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private var _imageView: UIImageView
        
        override var imageView: UIImageView? {
            get {
                return _imageView
            }
            
            set {
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _imageView.frame = contentView.bounds
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            return CGSize(width: size.width, height: 120.0)
        }
    }
    
    let imageCell: UITableViewCell = {
        let cell = ImageCell(style: .default, reuseIdentifier: nil)
        cell.imageView?.image = #imageLiteral(resourceName: "amsterdam.jpg")
        
        return cell
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return imageCell
    }
}


class FestivalsDataSource: TableViewDataSource, TableViewReusableViewsRegistering, IndexPathIndexable {

    static let cellReuseIdentifier = "FestivalsDataSourceCell"

    private(set) var festivals: [Festival] = []

    func object(at indexPath: IndexPath) -> Any? {
        return indexPath.row < festivals.count ? festivals[indexPath.row] : nil
    }
    
    func indexPaths(for object: Any) -> [IndexPath] {
        guard let festival = object as? Festival, let index = festivals.index(where: { element in
            return element == festival
        })
        else {
            return []
        }
        
        return [ IndexPath(row: index, section: 0) ]
    }

    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    override func loadContent() {

        festivals = []
        notify(update: TableViewUpdate.reloadData())

        contentLoadingController.loadContent { coordinator in
        
            let task = self.session.dataTask(with: endpointURL) { [weak self] (data, response, error) in
                guard coordinator.current else {
                    coordinator.ignore()
                    return
                }
                
                guard let data = data else {
                    if let error = error {
                        coordinator.doneWithError(error)
                    }
                    else {
                        coordinator.updateWithNoContent()
                    }
                    
                    return
                }
                
                do {
                    guard let array = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray else {
                        coordinator.updateWithNoContent()
                        return
                    }
                    
                    let festivals: [Festival] = array.flatMap { element in
                        guard let dictionary = element as? NSDictionary, let title = dictionary["title"] as? String else {
                            return nil
                        }
                        
                        return Festival(title: title)
                    }
                    
                    coordinator.updateWithContent {
                        self?.festivals = festivals
                        self?.notify(update: TableViewUpdate.reloadData())
                    }
                }
                catch {
                    coordinator.updateWithNoContent()
                }
            }
            
            task.resume()
        }
    }
    
    func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FestivalsDataSource.cellReuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return festivals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FestivalsDataSource.cellReuseIdentifier, for: indexPath)
        let festival = object(at: indexPath) as! Festival
        
        cell.textLabel?.text = festival.title
        
        return cell
    }
}


class TableViewController: UIViewController, UpdateObserver {

    var tableView: UITableView {
        return view as! UITableView
    }
    
    let dataSource: TableViewComposedDataSource = {
        let rootDataSource = TableViewComposedDataSource()
        rootDataSource.add(HeaderDataSource())
        rootDataSource.add(FestivalsDataSource())
    
        return rootDataSource
    }()
    
    override func loadView() {
        view = UITableView(frame: .zero, style: .plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        dataSource.updateObserver = self
        
        dataSource.registerReusableViews(with: tableView)
        tableView.dataSource = dataSource
        
        dataSource.loadContent()
    }
    
    func perform(update: DataSource.Update, from sender: UpdateObservable) {
        update.perform(tableView)
    }
    
    func refresh() {
        dataSource.loadContent()
    }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = UINavigationController(rootViewController: TableViewController())
