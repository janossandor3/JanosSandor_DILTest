import UIKit

// "isIPhone" name does not represent the exact content of this function
// A function with a simple computed property and without input parameters could be a static var instead.
// This function is in the internal scope, with no context. Should probably never do that. Add it as an extension to UIDevice
// You should use implicit returns
func isIPhone() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

// Wrong naming
// Use better spacing in a list of words
// Add one or maximum two protocols at the main declaration and put the others in extensions to separated the functionalities
class someVC:
UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    // Don't use weak for an IBOutlet unless it is specifically needed to avoid a retain cycle
    // Usually nothing wants to interact with these outlets outside of this viewController. Make them private
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var detailViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var detailView: UIView!
    
    // Should be private if it's initialized and used in this viewController.
    // IMHO if this detail viewController is a simple view of details, using a ViewController is overkill. This should be a simple widget, a simple UIView.
    // As I checked the other part of the code, this detailVC seems like a popup. If it is, implement an alert view controller and share it with all the view controllers to be easily reused. Make is customizable too.
    // By the way it's not initialized or showed anywhere.
    var detailVC : UIViewController?
    // It's are very rare to use "Any". This "data" must be something. At least an asociated type, a generic or some kind of a model that can be used easily by the collection view.
    var dataArray : [Any]?
    
    override func viewWillAppear(_ animated: Bool) {
        
        // If the project's specification says to update the collection view at every appear, it's OK, but should be used as a 'pull to refresh' too.
        // In viewWillAppear we should use only some triggers. fetchData() probably pulls some data from a server and waits for the response. This waiting could stop the main thread which is one of the most avoidable thing to do in a view controller.
        fetchData()
        
        // Setting dataSource and delegate, registering UINibs and initializing a bar button item should happen once in a view controller's lifecycle. Put these in init() or viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // Code intendation is not good from here
        // Create a separate nib file for these to be reusable
        self.collectionView.register(UINib(nibName: "someCell",
                                         bundle: nil), forCellWithReuseIdentifier: "someCell")
        // No need for ".init" and typo in "dissmissController"
        // Hardcoded string, put it in the Localizable file where all the strings should be stored.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title:NSLocalizedString("Done", comment:
""), style: .plain, target: self, action: #selector(dissmissController))
        
    }
    
    // This function should close the current view controller. It doesn't do anything, it's empty.
    // If this view controller pushed modally, use dismiss. Otherwise use popViewController. By the way it's not a good practice to have the view controller close itself. A delegate should do that instead.
    @objc func dissmissController () {}
    
    func fetchData() {
        
        // Not possible to build this file because of this typo: “
        //let url = URL(string: “testreq")!
        // This string should be a Constant somewhere else. This whole function should not be in a view controller, it doesn't have any business with "View" or "UI".
        // Create a service for this part of the code, fetchData() should only trigger it.
        let url = URL(string: "testreq")!
         let task = URLSession.shared.dataTask(with: url) { [self](data, response, error) in

             // The result of this function should update the dataArray (which also shouldn't be in a view controller, I prefer using a view model for this)
             // This task should know about the type of the data. This line of code is really bad practice. What if the cast is failed?
             self.dataArray = data as? [Any]
             // reloadData should be triggered by the change of dataArray. Shouldn't be here.
             self.collectionView.reloadData()
         }
        
        // I'm not very familiar with dataTask and task.resume, please wait for another review too.
         task.resume()
    }

    // This is not well intended, and use camel-case for a Swift function. "closeshowDetails()" not used in the code
    // Wrong naming. should be only "closeDetail"
@IBAction func closeshowDetails(){
    
        self.detailViewWidthConstraint.constant = 0
        
    // Not readable
        UIView.animate(withDuration: 0.5, animations:
                        {
            self.view.layoutIfNeeded()
        })
        { (completed) in
            self.detailVC?.removeFromParent()
        }
    }

    @IBAction func showDetail(){
                  
        self.detailViewWidthConstraint.constant = 100
        
        // Not readable
        UIView.animate(withDuration: 0.5, animations:
                        {
            // The contents of animations and completion should be swapped. We should put the detailView first and then animate it to be bigger.
            self.view.layoutIfNeeded()
        })
        { (completed) in
            // detailView is not even initialized, and I don't see how it knows about the details of the cell (selecting a cell should trigger detail view, but it is not updated)
            self.view.addSubview(self.detailView)
        }
    }
                  
    // These "collectionView" functions should be in an "extension someVC" part at the bottom of this file. These extensions should implement the secondary types which "someVC" implements, like "UICollectionViewDelegateFlowLayout".
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        // What is this magic number? If this is really needed, it should be a static var in "Constants" of this view controller, but it's very strange for me.
        var widthMultiplier: CGFloat = 0.2929
        if isIPhone() {
            // These could be joined like: var asd: CGFloat = isIPhone ? 0.9 : 0.2929
            widthMultiplier = 0.9
        }
        
        // Unnecessary space and bad code intendation
        // height: 150.0? Should be in the Constants with every other numbers.
        return CGSize(width: view.frame.width * widthMultiplier ,
                       height: 150.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        // Unnecessary new line
        // Magic numbers again, what does 84 stand for? And why the "* 3"?
        let frameWidth = (view.frame.width * 0.2929 * 3) + 84
        var minSpacing: CGFloat = (view.frame.width - frameWidth)/2
        if isIPhone() {
            minSpacing = 24
        }
        return minSpacing
    }
    // Create a totally new section for each of the items? Why?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray?.count ?? 0
    }
    // This should be declared in the "DataSourceType" which is passed to the viewController's dataSource in the viewWillAppear (which should be in viewDidLoad)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    // This call should be also done in the DataSourceType.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showDetail()
    }
}
