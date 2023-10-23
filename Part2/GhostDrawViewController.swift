import RxCocoa
import RxSwift

import UIKit

class GhostDrawViewController: UIViewController {
    @IBOutlet private var drawingView: UIView!
    @IBOutlet private var redButton: UIButton!
    @IBOutlet private var greenButton: UIButton!
    @IBOutlet private var blueButton: UIButton!
    @IBOutlet private var eraserButton: UIButton!
    
    private let selectedColorOptionRelay = BehaviorRelay<ColorOption>(value: .eraser)
    private let disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        // FIXME: borderWidth and borderColor does not work in the xib
        redButton.layer.borderWidth = 5
        redButton.layer.borderColor = UIColor.black.cgColor
        greenButton.layer.borderWidth = 5
        greenButton.layer.borderColor = UIColor.black.cgColor
        blueButton.layer.borderWidth = 5
        blueButton.layer.borderColor = UIColor.black.cgColor
        eraserButton.layer.borderWidth = 5
        eraserButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func setupBindings() {
        redButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedColorOptionRelay.accept(.red)
            })
            .disposed(by: disposeBag)
        
        greenButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedColorOptionRelay.accept(.green)
            })
            .disposed(by: disposeBag)

        blueButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedColorOptionRelay.accept(.blue)
            })
            .disposed(by: disposeBag)

        eraserButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectedColorOptionRelay.accept(.eraser)
            })
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        drawGhost(at: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        drawGhost(at: touch)
    }
    
    private func drawGhost(at touch: UITouch) {
        let location = touch.location(in: self.view)
        if drawingView.frame.contains(location) {
            selectedColorOptionRelay
                .take(1)
                .flatMap { option in
                    Observable.just(option).delay(option.delay, scheduler: MainScheduler.instance)
                }
                .subscribe(onNext: { [weak self] option in
                    self?.draw(with: option.color, at: location)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func draw(with color: UIColor, at location: CGPoint) {
        let dot = UIView(frame: CGRect(x: location.x, y: location.y, width: 10, height: 10))
        dot.layer.cornerRadius = 5
        dot.backgroundColor = color
        drawingView.addSubview(dot)
    }
}

enum ColorOption {
    case red
    case green
    case blue
    case eraser
    
    var color: UIColor {
        switch self {
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .eraser: return .white
        }
    }
    
    var isEraser: Bool { self == .eraser }
    
    var delay: RxTimeInterval {
        switch self {
        case .red: return .seconds(1)
        case .green: return .seconds(3)
        case .blue: return .seconds(5)
        case .eraser: return .seconds(2)
        }
    }
}
