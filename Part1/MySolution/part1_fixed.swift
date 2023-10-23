import UIKit

class BetterNameVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet private var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var detailViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var detailView: DetailView!
    
    private var dataArray: [Details]? { didSet { collectionView.reloadData() } }
    
    private enum Constants {
        static var detailViewWidth: CGFloat = 100
        static var detailAnimationTime: Double = 0.5
        static var defaultWidthMultiplier = 0.2929
        static var frameWidthMultiplier: Double = 3
        static var frameWidthOffset: Double = 84
        static var phoneMinSpacing: CGFloat = 24
        static var widthMultiplier = UIDevice.isPhone ? 0.9 : defaultWidthMultiplier
        static var cellHeight: Double = 150.0
    }
    
    override func viewDidLoad() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SomeCell.self, forCellWithReuseIdentifier: "SomeCell") // FIXME: use nib's id
        // FIXME: Use localizable string
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(dismissController))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // FIXME: inject this service and use its fetch
        try? DataService().fetch() { [weak self] newData in
            guard let self else { return }
            self.dataArray = newData
        }
    }
    
    @objc func dismissController () {}
    
    @IBAction func showDetail() {
        UIView.animate(
            withDuration: Constants.detailAnimationTime,
            animations: {
                self.detailViewWidthConstraint.constant = Constants.detailViewWidth
                self.view.layoutIfNeeded()
            }
        )
    }
    
    @IBAction func closeDetails() {
        UIView.animate(
            withDuration: Constants.detailAnimationTime,
            animations: {
                self.detailViewWidthConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension BetterNameVC: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width * Constants.widthMultiplier, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let frameWidth = (view.frame.width * Constants.defaultWidthMultiplier * Constants.frameWidthMultiplier) + Constants.frameWidthOffset
        return UIDevice.isPhone ? Constants.phoneMinSpacing : (view.frame.width - frameWidth) / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetail()
    }
}
