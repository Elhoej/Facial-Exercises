//
//  ChartsCollectionView.swift
//  Facial Exercises
//
//  Created by De MicheliStefano on 04.01.19.
//  Copyright © 2019 Vuk Radosavljevic. All rights reserved.
//

import UIKit

class ChartCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    static private var cellId = "ChartCell"
    
    var exercises: [(String, [Exercise])]? {
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
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        register(ChartCell.self, forCellWithReuseIdentifier: ChartCollectionView.cellId)
        self.allowsSelection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: ChartCollectionView.cellId, for: indexPath) as! ChartCell
        guard let pastExercises = exercises else { return cell }
        let exerciseType = pastExercises[indexPath.item]
        cell.title = exerciseType.0
        cell.exercises = exerciseType.1
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

private class ChartCell: UICollectionViewCell {
    
    var title: String? {
        didSet {
            updateViews()
        }
    }
    
    var exercises: [Exercise]? {
        didSet {
            setupChart()
        }
    }
    
    private lazy var chartTitle: UILabel = {
        let label = UILabel()
        label.font = Appearance.appFont(style: .body, size: 17.0)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let userStatsView: UserStatHistoryView = {
        let graph = UserStatHistoryView()
        return graph
    }()
    
    private let padding: CGFloat = 12.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(chartTitle)
        chartTitle.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        
        addSubview(userStatsView)
        userStatsView.anchor(top: chartTitle.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        
        userStatsView.backgroundColor = .clear
    }
    
    private func updateViews() {
        guard let title = title else { return }
        chartTitle.text = title
    }
    
    private func setupChart() {
        guard let exercises = exercises else { return }
        userStatsView.userRecords = exercises.compactMap { UserRecord(date: $0.timestamp!, highScore: $0.score) }
    }
    
}
