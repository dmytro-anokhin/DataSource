
> The **DataSource** framework is currently in development. At the moment only small subset of functionality is implemented, documentation is missing and tests does not provide full code coverage. API and current code structure will change.
> 
> Use at your own risk ;)

## Description

The **DataSource** framework defines architecture for decoupling data and view controller code. The API defines interface for data management tasks and abstracts representation from a concrete view. The framework intensively uses composition to split complex tasks into standalone components and combine them to create rich functionality. This allows you to write well structured and highly reusable code.

The **DataSource** framework is written is Swift and extensively uses protocols. This creates lightweight code and allows including only functionality that you actually use.

The API is based on existing Cocoa Touch interfaces. In this way, the **DataSource** framework does not require any specific knowledge to get started and makes refactoring of existing codebase straightforward. You can use any other library/framework alongside with the **DataSource** framework.

The framework provides a rich set of utility tools to deal with common tasks.

At the moment `UITableView` is supported. `MKMapView` is coming in future release and `UICollectionView` is still in plans.

The **DataSource** framework is inspired by the idea described in "Advanced User Interfaces with Collection Views" ([Session 232, WWDC 2014](https://developer.apple.com/videos/play/wwdc2014/232/)).

## Getting Started

The basic implementation is defined by `TableViewDataSource` abstract class. This class confirms to `UITableViewDataSource` protocol. This is abstract class and you can implement it the same way you would implement `UITableViewController`:

```swift
class AnimalsDataSource: TableViewDataSource {

    private var animals = [ "Cheetah", "Puma", "Jaguar" ]

    override func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnimalCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)
        cell.textLabel?.text = animals[indexPath.row]
        return cell
    }
}
```

View controller implementation may look like this:

```swift
class TableViewController: UIViewController {
    
    // ...
    
    let dataSource = AnimalsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.registerReusableViews(with: tableView)
        tableView.dataSource = dataSource
    }
}
```

This is a starting poing for decoupling data from `UIViewController`. In this example data and its representation is managed by a `TableViewDataSource` object.

Lets create another data source to make this example bit more interesting:

```swift
class InsectsDataSource: TableViewDataSource {
    
    private var insects = [ "Bee", "Spider", "Grasshopper" ]

    override func registerReusableViews(with tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "InsectCell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return insects.count
    }

    override func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsectCell", for: indexPath)
        cell.textLabel?.text = insects[indexPath.row]
        return cell
    }
}
```

The `TableViewComposedDataSource` class is used to compose multiple data sources:

```swift
class TableViewController: UIViewController {

    // ...

    // Composed data source manages composition of multiple data sources
    let dataSource = TableViewComposedDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.add(dataSource: AnimalsDataSource(), animated: false)
        dataSource.add(dataSource: InsectsDataSource(), animated: false)
        
        dataSource.registerReusableViews(with: tableView)
        tableView.dataSource = dataSource
    }
}
```

In this example `TableViewComposedDataSource` creates a composition of `AnimalsDataSource` and `InsectsDataSource`. Similar behavior can be replicated using single `UITableViewDataSource` with `switch` statement on `indexPath.section`.
Composition has multiple advantages over `switch` statement:
* no need to modify existing code when adding a new data source;
* no need to synchronize `switch` blocks over multiple methods;
* code is split in multiple components to simplify modifications and eliminate massive classes;
* data source can be reused in other places as is.

### Loading Content

Common task is loading content from network or persistent store. Lets see how we can implement content loading in `TableViewDataSource`. We start with extending data source functionality by overriding `loadContent` method:

```swift
class AnimalsDataSource: TableViewDataSource {
    
    // ...

    private var animals: [String] = []

    override func loadContent() {
        DispatchQueue.global().async { // Perform loading in background.
            let animals = [ "Cheetah", "Puma", "Jaguar" ]
            
            DispatchQueue.main.async { // Perform update on main queue.
                self.animals = animals
                self.notify(update: TableViewUpdate.reloadData()) // Ask table view to reload.
            }
        }
    }
}
```

View controller should trigger `loadContent` at appropriate moment and confirm to `UpdateObserver` protocol in order to handle view update requests.

```swift
class TableViewController: UIViewController, UpdateObserver {
    
    // ...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ...

        dataSource.updateObserver = self // Listen to update notifications.
        dataSource.loadContent() // Trigger content loading.

        // ...
    }
    
    func perform(update: Update, from sender: UpdateObservable) {
        // Update object incapsulates logic of performing changes.
        // All it needs is a view to update.
        update.perform(tableView)
    }
}
```

## License

**DataSource** framework is released under the MIT license. See LICENSE for details.

Some of **DataSource** framework code is base on "AdvancedCollectionView: Advanced User Interfaces Using Collection View" by Apple. See Apple-LICENSE for details.
