//
//  ResultViewController.swift
//  Facial Exercises
//
//  Created by De MicheliStefano on 03.01.19.
//  Copyright © 2019 Vuk Radosavljevic. All rights reserved.
//

/**
 A view controller which shows the results summary of the user's exercise session.
 - Author: Stefano Demicheli
 */

import UIKit
import CoreData
import Lottie

class ResultViewController: UIViewController {
    
    // MARK: - Public properties
    
    var shouldCelebrate = false
    var exercisesWithResults = [String: Float]() {
        didSet {
            print(exercisesWithResults)
            updateViews()
        }
    }
    
    // MARK: - Private properties
    
    private let headerView: HeaderResultsView = {
        let view = HeaderResultsView(score: 50)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let exerciseResultsView: ExerciseResultsCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        let cv = ExerciseResultsCollectionView(collectionViewLayout: layout)
        return cv
    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Finish", for: .normal)
        button.backgroundColor = .selectedGreen
        button.titleLabel?.font = Appearance.appFont(style: .title2, size: 16)
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleFinish), for: .touchUpInside)
        
        return button
    }()
    
    private let blurEffect: UIVisualEffectView = {
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        frost.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return frost
    }()
    
    private let sidePadding: CGFloat = 20.0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setGradientBackground(colors: [UIColor.rgb(red: 67, green: 206, blue: 162).cgColor, UIColor.rgb(red: 24, green: 90, blue: 157).cgColor], locations: [0.0, 1.0], startPoint: CGPoint(x: 1, y: 0), endPoint: CGPoint(x: 0, y: 1))
        
        setupViews()
        
        if shouldCelebrate { setupEmitterView() }
    }
    
    // MARK: - User actions
    
    // When the user dismisses the results summary page we'll save the exercise results to local persistence
    @objc func handleFinish() {
        saveExercises()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func saveExercises(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        for exercise in exercisesWithResults {
            let _ = Exercise(type: exercise.key, score: exercise.value)
        }
        
        context.performAndWait {
            do {
                try CoreDataStack.shared.save(context: context)
                NSLog("Successfully saved exercises")
            } catch {
                NSLog("Error saving in context \(context): \(error)")
            }
        }
    }
    
    // MARK: - Configuration
    
    private func setupViews() {
        
        view.addSubview(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 50, left: sidePadding, bottom: 0, right: sidePadding), size: CGSize(width: 0, height: 150))
        
        view.addSubview(finishButton)
        finishButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 30, bottom: 24, right: 30), size: CGSize(width: 0, height: 50))
        
        view.addSubview(exerciseResultsView)
        exerciseResultsView.anchor(top: headerView.bottomAnchor, leading: view.leadingAnchor, bottom: finishButton.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: sidePadding, left: sidePadding, bottom: sidePadding, right: sidePadding))
    }
    
    private func updateViews() {
        exerciseResultsView.completedExercises = exercisesWithResults.map { ($0.key, $0.value) }
    }
    
    private func setupEmitterView() {
        let rect = CGRect(x: 0.0, y: -90.0, width: view.bounds.width, height: 50.0)
        let emitter = CAEmitterLayer()
        emitter.frame = rect
        emitter.emitterShape = CAEmitterLayerEmitterShape.point
        emitter.emitterPosition = CGPoint(x: rect.width/2, y: rect.height/2)
        emitter.emitterSize = rect.size
        view.layer.addSublayer(emitter)
        
        emitter.emitterCells = [CAEmitterCell]()
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "star")?.cgImage
        emitterCell.color = UIColor.cyan.cgColor
        emitterCell.birthRate = 100
        emitterCell.lifetime = 5
        emitterCell.yAcceleration = 100.0
        emitterCell.xAcceleration = 10.0
        emitterCell.zAcceleration = 10.0
        emitterCell.spin = 5.0
        emitterCell.velocity = 350.0
        emitterCell.velocityRange = 200.0
        emitterCell.emissionLongitude = .pi * 0.5
        emitterCell.emissionRange = .pi * 0.5
        emitterCell.scale = 1.0
        emitterCell.scaleRange = 0.5
        
        emitter.emitterCells?.append(emitterCell)
    }
    
}

private class HeaderResultsView: UIView {

    let animationView: LOTAnimationView = {
        let lav = LOTAnimationView()
        lav.setAnimation(named: "trophy")
        lav.animationSpeed = 0.8
        
        return lav
    }()
    
    private let padding: CGFloat = 12.0
    
    init(frame: CGRect = CGRect.zero, score: Int) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(animationView)
        animationView.centerInSuperview(size: CGSize(width: 180, height: 180))
        animationView.play()
    }
    
}

private class ExerciseResultsCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static private var cellId = "ExerciseResultCell"
    var completedExercises: [(String, Float)]? {
        didSet {
            reloadData()
        }
    }
    
    override init(frame: CGRect = CGRect.zero, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        delegate = self
        dataSource = self
        backgroundColor = .clear
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        register(ExerciseResultCell.self, forCellWithReuseIdentifier: ExerciseResultsCollectionView.cellId)
        self.allowsSelection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completedExercises?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: ExerciseResultsCollectionView.cellId, for: indexPath) as! ExerciseResultCell
        
        guard let exercises = completedExercises else { return cell }
        let exercise = exercises[indexPath.item]
        cell.exercise = exercise
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: 80)
    }
    
}

private class ExerciseResultCell: UICollectionViewCell {
    
    var exercise: (String, Float)? {
        didSet {
            updateViews()
        }
    }
    
    private let blurEffect: UIVisualEffectView = {
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        frost.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        frost.layer.cornerRadius = 8
        frost.layer.masksToBounds = true
        
        return frost
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        return stackView
    }()
    
    private let exerciseNameLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.appFont(style: .body, size: 17.0)
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = Appearance.appFont(style: .body, size: 14.0)
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    private let sidePadding: CGFloat = 12
    private let defaultBackgroundColor: UIColor = .clear
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = defaultBackgroundColor
        layer.cornerRadius = 8
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(blurEffect)
        blurEffect.fillSuperview()
        
        addSubview(mainStackView)
        mainStackView.addArrangedSubview(exerciseNameLabel)
        mainStackView.addArrangedSubview(scoreLabel)
        mainStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: sidePadding, bottom: 8, right: sidePadding))
    }
    
    private func updateViews() {
        guard let exercise = exercise else { return }
        exerciseNameLabel.text = exercise.0
        scoreLabel.text = "Your score was \(String(exercise.1))"
    }
    
}
