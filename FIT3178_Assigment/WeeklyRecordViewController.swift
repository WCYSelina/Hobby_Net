//
//  WeeklyRecordViewController.swift
//  FIT3178_Assignment
//
//  Created by Ching Yee Selina Wong on 7/5/2023.
//

import UIKit

class WeeklyRecordViewController: UIViewController,DatabaseListener,UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VerticalTableViewCell.reuseIdentifier, for: indexPath) as! VerticalTableViewCell
        var notesText: [String] = []
        records![indexPath.row].notes.forEach{ note in
            if let noteDetail = note.noteDetails{
                notesText.append(noteDetail)
            }
            
        }
//        let notesText = records![indexPath.row].notes.map {
//            if let noteDetail = $0.noteDetails{
//                $0.noteDetails
//            }
//        }
//        if let notesText = notesText{ [String]? -> [String]  [String?] -x [String]
        cell.configure(data: notesText)
//        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height * 0.5
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let weekPickerHeight: CGFloat = 50
        weekPickerstackView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.bounds.width, height: weekPickerHeight)

        // Set the frame for the tableView
        tableView.frame = CGRect(x: 0, y: weekPickerstackView.frame.maxY, width: view.bounds.width, height: view.bounds.height - weekPickerHeight - view.safeAreaInsets.top)
        tableView.frame = view.bounds
    }
    
    func onWeeklyRecordChange(change: DatabaseChange, records: [Records]) {
        self.records = records
    }
    
    func onHobbyChange(change: DatabaseChange, hobbies: [Hobby]) {
    }
    
    func onRecordChange(change: DatabaseChange, record: [Notes]) {
    }
    
    func onNoteChange(change: DatabaseChange, notes: [Notes]) {
    }
    
    func onHobbyRecordFirstChange(change: DatabaseChange, hobby: Hobby) {
    }
    

    @IBOutlet weak var weekPickerstackView: UIStackView!
    weak var databaseController:DatabaseProtocol?
    var listenerType = ListenerType.record
    var records:[Records]?
    var startWeek:Date?
    var endWeek:Date?
    let weekRange = UILabel()
    var hobby:Hobby?
    var currentDate: Date = Date() {
        didSet {
            updateWeekLabel()
        }
    }
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0) // so that the table view is below the week picker and does not overlay
        tableView.register(VerticalTableViewCell.self, forCellReuseIdentifier: VerticalTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
 
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Create the left arrow button
        let leftArrowButton = UIButton(type: .system)
        leftArrowButton.setTitle("<", for: .normal)
        leftArrowButton.translatesAutoresizingMaskIntoConstraints = false
        leftArrowButton.addTarget(self, action: #selector(moveBackward), for: .touchUpInside)
        
        weekRange.numberOfLines = 0
        updateWeekLabel()
        
        // Create the right arrow button
        let rightArrowButton = UIButton(type: .system)
        rightArrowButton.setTitle(">", for: .normal)
        rightArrowButton.addTarget(self, action: #selector(moveForward), for: .touchUpInside)
        
        weekPickerstackView.addArrangedSubview(leftArrowButton)
        weekPickerstackView.addArrangedSubview(weekRange)
        weekPickerstackView.addArrangedSubview(rightArrowButton)
        
        view.addSubview(weekPickerstackView)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @objc func moveForward() {
        currentDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        
    }
    
    @objc func moveBackward() {
        currentDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
    }
    
    func updateWeekLabel() {
        let week = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let start = formatter.string(from: week.start)
        self.startWeek = week.start
        let end = formatter.string(from: week.end)
        self.endWeek = week.end
        self.weekRange.text = "\(start) - \(end)"
        databaseController?.showRecordWeekly(hobby: hobby!, startWeek: startWeek!, endWeek: endWeek!){
            //
        }
    }

}

class HorizontalCollectionViewCell: UICollectionViewCell{
    static let reuseIdentifier = "HorizontalCollectionViewCell"
    
    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(card)
        card.addSubview(label)
    }
       
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   override func layoutSubviews() {
       super.layoutSubviews()
       let margin: CGFloat = 10
       card.frame = CGRect(x: margin, y: margin, width: contentView.bounds.width - 2 * margin, height: contentView.bounds.height - 2 * margin)
       label.frame = CGRect(x: 8, y: 8, width: card.bounds.width - 16, height: card.bounds.height - 16)
    }
   
   func configure(text: String) {
       label.text = text
   }
}

class VerticalTableViewCell:UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    static let reuseIdentifier = "VerticalTableViewCell"
    
    private let collectionView: UICollectionView = {
           let layout = UICollectionViewFlowLayout()
           layout.scrollDirection = .horizontal
           layout.minimumInteritemSpacing = 0
           layout.minimumLineSpacing = 0
           let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
           collectionView.showsHorizontalScrollIndicator = false
           collectionView.backgroundColor = .white
           return collectionView
       }()
    private var data: [String] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HorizontalCollectionViewCell.self, forCellWithReuseIdentifier: HorizontalCollectionViewCell.reuseIdentifier)
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.5), // Set the height to half of the screen height
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    func configure(data: [String]) {
        self.data = data
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalCollectionViewCell.reuseIdentifier, for: indexPath) as! HorizontalCollectionViewCell
        cell.configure(text: data[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let cardWidth: CGFloat = screenWidth // Set the card width to the screen width
        let cardHeight: CGFloat = screenHeight * 0.5 // Set the card height to half of the screen height
        return CGSize(width: cardWidth, height: cardHeight)
        }
}
