import UIKit

class MainView: UIView {
    var pickVideoTapped: (() -> Void)?
    var demoVideoPicked: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let pickVideoButton = Button(title: Copy.Buttons.pickVideo, type: .primary, icon: IconNames.video)
        pickVideoButton.addTarget(self, action: #selector(pickVideoTappedAction), for: .touchUpInside)
        addSubview(pickVideoButton)
        pickVideoButton.placeAtTheBottom(of: self)
        
        let mainContentContainer = MainContentContainer()
        addSubview(mainContentContainer)
        mainContentContainer.placeAbove(button: pickVideoButton, inside: self)
        
        let heroTitle = HeroTitle()
        mainContentContainer.addSubview(heroTitle)
        heroTitle.placeAtTheBottom(of: mainContentContainer)
        
        let pillButton = PillButton(title: Copy.Buttons.tryDemoVideo)
        pillButton.addTarget(self, action: #selector(tryDemoVideoTappedAction), for: .touchUpInside)
        mainContentContainer.addSubview(pillButton)
        pillButton.placeAtTheTop(of: mainContentContainer)
    }
    
    @objc private func pickVideoTappedAction() {
        pickVideoTapped?()
    }
    
    @objc private func tryDemoVideoTappedAction() {
        demoVideoPicked?()
    }
}

class MainViewController: UIViewController {
    private var mainView: MainView!
    private var videoPicker: MediaPickerController!
    
    override func loadView() {
        mainView = MainView()
        mainView.pickVideoTapped = { [weak self] in
            self?.videoPicker.presentMediaPicker(forType: .video)
        }
        view = mainView
    }
    
    override func viewDidLoad() {
        videoPicker = MediaPickerController(presenter: self)
        
        videoPicker.videoPicked = { [weak self] videoURL in
            let selectedVideoViewController = SelectedVideoViewController(videoURL: videoURL)
            self?.navigationController?.pushViewController(selectedVideoViewController, animated: true)
        }
        
        mainView.demoVideoPicked = { [weak self] in
            let videoURL = Bundle.main.url(
                forResource: DemoAssetsFiles.Video.name,
                withExtension: DemoAssetsFiles.Video.extension
            )
            guard let videoURL = videoURL else { return }
            let selectedVideoViewController = SelectedVideoViewController(videoURL: videoURL)
            self?.navigationController?.pushViewController(selectedVideoViewController, animated: true)
        }
    }
}
