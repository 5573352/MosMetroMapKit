//
//  MCDScheduleViewController.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 15.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDScheduleViewController: BaseController {

    @IBOutlet weak var tableView     : UITableView!
    
    @objc private func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var scrollButton: UIButton!
    
    @IBAction func scrollToDevider(_ sender: Any) {
        forcedScroll(animated: true)
    }
    
    var scrollableItemStart = 0
    var scrollableItemEnd   = 0
    var firstLaunchStart = true
    var firstLaunchEnd = true
    var towardsStartName = ""
    var towardsEndName = ""
    var lastContentOffset: CGFloat = 0
    var transformButton = true

    lazy var titleStackView: UIStackView = {
        // title label
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = "Title"
        titleLabel.font = UIFont(name: "MoscowSans-Bold", size: 17)
        titleLabel.textColor = .textPrimary
        // subtitleLabel
        let subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = NSLocalizedString("MCD schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        subtitleLabel.font = UIFont(name: "MoscowSans-Bold", size: 11)
        subtitleLabel.textColor = .grey
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        return stackView
    }()
    
    var towardsStart: [MCDThread]? {
        didSet {
            makeState()
        }
    }
    var towardsEnd: [MCDThread]? {
        didSet {
            makeState()
        }
    }
    
    public func setTitle(_ text: String) {
        if let title = titleStackView.arrangedSubviews.first as? UILabel {
            title.text = text
        }
    }

    private func openRouteScreen(thread: MCDThread) {
        let routeVC = MCDRouteScreen(nibName: "MCDRouteScreen", bundle: nil)
        routeVC.onClose = { [weak self] in
            guard let self = self else { return }
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close_pan"), style: .plain, target: self, action: #selector(self.handleClose))
        }
        self.navigationController?.pushViewController(routeVC, animated: true)
        self.navigationItem.rightBarButtonItem = nil
        routeVC.title = NSLocalizedString("Route", tableName: nil, bundle: .mm_Map, value: "", comment: "") + " \("№\(thread.trainNum)")"
        routeVC.idtr = thread.idtr
    }
    
    
    private func makeState() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            if let start = self.towardsStart, let end = self.towardsEnd {
                
                // К началу линию
                let startPassed = start.filter { self.isPassed(thread: $0)}
                let startUpcoming = start.filter { !self.isPassed(thread: $0)}
                var rowsStart = [Any]()
                
                
                
                let startPassedRows: [ViewState.Train] = startPassed.map { [weak self] thread in
                    let onSelect: () -> () = { [weak self] in
                        self?.openRouteScreen(thread: thread)
                        
                    }
                    return ViewState.Train(isLeft: true,
                                           status: self?.statusHelper(for: thread) ?? "",
                                           statusColor: thread.status.color(),
                                           time: thread.arrival.toFormat("HH:mm"),
                                           details: self?.detailsHelper(thread: thread) ?? "",
                                           onSelect: onSelect)
                    
                }
                rowsStart.append(contentsOf: startPassedRows)
                rowsStart.append(ViewState.ExpandRow())
                if self.firstLaunchStart {
                    self.scrollableItemStart = rowsStart.count - 2
                }
                let startUpcomingRows: [ViewState.Train] = startUpcoming.map { [weak self] thread in
                    let onSelect: () -> () = { [weak self] in
                        self?.openRouteScreen(thread: thread)
                        
                    }
                    return ViewState.Train(isLeft: false,
                                           status: self?.statusHelper(for: thread) ?? "",
                                           statusColor: thread.status.color(),
                                           time: thread.arrival.toFormat("HH:mm"),
                                           details: self?.detailsHelper(thread: thread) ?? "",
                                           onSelect: onSelect)
                    
                }
                rowsStart.append(contentsOf: startUpcomingRows)
                
                
                // К концу лини
                let endPassed = end.filter { self.isPassed(thread: $0)}
                let endUpcoming = end.filter { !self.isPassed(thread: $0)}
                var rowsEnd = [Any]()
                let endPassedRows: [ViewState.Train] = endPassed.map { [weak self] thread in
                    let onSelect: () -> () = { [weak self] in
                        guard let self = self else {  return }
                        self.openRouteScreen(thread: thread)
                    }
                    return ViewState.Train(isLeft: true,
                                           status: self?.statusHelper(for: thread) ?? "",
                                           statusColor: thread.status.color(),
                                           time: thread.arrival.toFormat("HH:mm"),
                                           details: self?.detailsHelper(thread: thread) ?? "",
                                           onSelect: onSelect)
                    
                }
                rowsEnd.append(contentsOf: endPassedRows)
                rowsEnd.append(ViewState.ExpandRow())
                if self.firstLaunchEnd {
                    self.scrollableItemEnd = rowsEnd.count - 2
                }
                let endUpcomingRows: [ViewState.Train] = endUpcoming.map { [weak self] thread in
                    let onSelect: () -> () = { [weak self] in
                        guard let self = self else {  return }
                        self.openRouteScreen(thread: thread)
                    }
                    return ViewState.Train(isLeft: false,
                                           status: self?.statusHelper(for: thread) ?? "",
                                           statusColor: thread.status.color(),
                                           time: thread.arrival.toFormat("HH:mm"),
                                           details: self?.detailsHelper(thread: thread) ?? "",
                                           onSelect: onSelect)
                    
                }
                rowsEnd.append(contentsOf: endUpcomingRows)
                DispatchQueue.main.async { [self] in
                    self.viewState = ViewState(start: rowsStart, end: rowsEnd, startName: self.towardsStartName, endName: self.towardsEndName, state: .towardsStart)
                }
            } else {
                DispatchQueue.main.async {
                    self.viewState = ViewState(start: [], end: [], startName: self.towardsStartName, endName: self.towardsEndName, state: .loading)
                }
               
            }
        }
    }
    
    private func detailsHelper(thread: MCDThread) -> String {
        var detailsText = "№\(thread.trainNum)"
        return detailsText
    }
    
    private func isPassed(thread: MCDThread) -> Bool {
        return thread.arrival < Date().addingTimeInterval(3600*3)
    }
    
    private func statusHelper(for thread: MCDThread) -> String {
        if thread.arrival < Date().addingTimeInterval(3600*3) {
            switch thread.status {
            case .late(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Arrived %d min late", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .early(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Arrived %d min earlier", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .standart:
                return NSLocalizedString("Arrived on schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            }
        } else {
            switch thread.status {
            case .late(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Possible delay %d min", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .early(let mins):
                return String.localizedStringWithFormat(NSLocalizedString("Arriving %d min earlier", tableName: nil, bundle: .mm_Map, value: "", comment: ""), mins)
            case .standart:
                return NSLocalizedString("On schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
            }
        }
    }
    

    struct ViewState {
        var start: [Any]
        var end: [Any]
        let startName: String
        let endName: String
        let state: State
        
        enum State {
            case loading
            case towardsStart
            case towardsEnd
        }
        
        struct Train  {
            let isLeft   : Bool
            let status   : String
            let statusColor: UIColor
            let time     : String
            let details  : String
            var onSelect : (()->())
        }
        
        struct ExpandRow {}
        
        static let initial = ViewState(start: [], end: [], startName: "", endName: "", state: .loading)
        
    }
    
    public var viewState : ViewState = .initial {
        didSet {
            scrollButton.alpha = 0
            var animated = false
            switch viewState.state {
            case .loading : break
            case .towardsStart:
                if firstLaunchStart {
                    animated = true
                    firstLaunchStart = false
                }
            case .towardsEnd:
                if firstLaunchEnd {
                    animated = true
                    firstLaunchEnd = false
                }
            }
            tableView.reloadData { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.forcedScroll(animated: animated)
                }
            }
        }
    }
    
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.tableView.reloadData() })
            { _ in completion() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollButton.layer.borderWidth             = 0.0
        scrollButton.layer.shadowColor             = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        scrollButton.layer.shadowOffset            = CGSize(width: 0, height: 0)
        scrollButton.layer.shadowRadius            = 8
        scrollButton.layer.shadowOpacity           = 1
        scrollButton.layer.masksToBounds           = false
//        scrollButton.imageView?.transform = CGAffineTransform(rotationAngle: 0)
        scrollButton.isHidden = true
        
        tableView.register(UINib(nibName: "MCDTrainScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: MCDTrainScheduleTableViewCell.reuseID)
        tableView.register(UINib(nibName: "MCDExpandTableViewCell", bundle: nil), forCellReuseIdentifier: MCDExpandTableViewCell.reuseID)
        tableView.register(LoadingTableViewCell.nib,
            forCellReuseIdentifier: LoadingTableViewCell.identifire)
        tableView.register(UINib(nibName: ErrorTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: ErrorTableViewCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = self
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.tableView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.tableView.addGestureRecognizer(swipeRight)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "close_pan"), style: .plain, target: self, action: #selector(self.handleClose))
        navigationItem.titleView = titleStackView


    }
    
    private func makeTransition(with type: CATransitionSubtype) {
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.fillMode = CAMediaTimingFillMode.forwards
        transition.duration = 0.25
        transition.subtype = type
        self.tableView.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
    }
    
    @objc
    private func handleGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
        }
        else if gesture.direction == .left {
        }
    }
    
    private func setupSegmentControl() {
//        let d = firstDir?.first as! ViewState.Train
//        let t = secondDir?.first as! ViewState.Train
//        segmentControl.segmentEdgeInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width/3, bottom: UIScreen.main.bounds.width/3, right: 0);
    }
    
    private func forcedScroll(animated: Bool) {
        scrollButton.alpha = 0
        switch viewState.state {
        case .loading : break
        case .towardsStart :
            if scrollableItemStart > 0 {
                tableView.scrollToRow(at: IndexPath(row: scrollableItemStart, section: 0), at: .top, animated: animated)
            }
        case .towardsEnd   :
            if scrollableItemEnd   > 0  {
                tableView.scrollToRow(at: IndexPath(row: scrollableItemEnd, section: 0), at: .top, animated: animated)
            }
        }
        scrollButton.alpha = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setupSegmentControl()
    }
    
    @objc
    func segmentedControlChangedValue(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            makeTransition(with: .fromLeft)
            viewState = ViewState(start: viewState.start, end: viewState.end,
                                  startName: viewState.startName, endName: viewState.endName, state: .towardsStart)
        case 1:
            makeTransition(with: .fromRight)
            viewState = ViewState(start: viewState.start, end: viewState.end,
                                  startName: viewState.startName, endName: viewState.endName, state: .towardsEnd)
        default:
            break
        }
    }
}

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
            { _ in completion() }
    }
}

extension MCDScheduleViewController : UITableViewDelegate {
    
    private func changeScrollButtonAlpa(with value: CGFloat) {
        UIView.animate(withDuration: animationDuration) {
            self.scrollButton.alpha = value
            if value == 0 {
                self.scrollButton.isHidden = true
            } else {
                self.scrollButton.isHidden = false
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if transformButton {
            if self.lastContentOffset < scrollView.contentOffset.y {
                scrollButton.imageView?.transform = CGAffineTransform(rotationAngle: 0)
            } else if self.lastContentOffset > scrollView.contentOffset.y {
                scrollButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                // didn't move
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case is MCDExpandTableViewCell:
            changeScrollButtonAlpa(with: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() +  animationDuration, execute: {
                self.transformButton = false
            })
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch cell {
        case is MCDExpandTableViewCell:
            changeScrollButtonAlpa(with: 0)
            transformButton = true
        default: break
        }
    }
}

extension MCDScheduleViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewState.state {
        case .loading:
            return 1
        case .towardsStart:
            return viewState.start.count
        case .towardsEnd:
            return viewState.end.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewState.state {
        case .loading           :
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifire, for: indexPath) as! LoadingTableViewCell
            cell.separatorInset         = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
            tableView.separatorStyle    = .none
            return cell
        case .towardsStart:
            switch viewState.start[indexPath.row] {
            case is ViewState.Train :
                let d = viewState.start[indexPath.row] as! ViewState.Train
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDTrainScheduleTableViewCell.reuseID, for: indexPath) as! MCDTrainScheduleTableViewCell
    
                cell.statusLabel.text  = d.status
                cell.statusLabel.textColor = d.statusColor
                cell.timeLabel.text    = d.time
                cell.deatilsLabel.text = d.details
                cell.contentView.alpha = d.isLeft ? 0.55 : 1
                return cell
            case is ViewState.ExpandRow     :
                scrollableItemStart = indexPath.row - 1
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDExpandTableViewCell.reuseID, for: indexPath) as! MCDExpandTableViewCell
                return cell
            default:
                return UITableViewCell()
            }
        case .towardsEnd :
            switch viewState.end[indexPath.row] {
            case is ViewState.Train :
                let d = viewState.end[indexPath.row] as! ViewState.Train
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDTrainScheduleTableViewCell.reuseID, for: indexPath) as! MCDTrainScheduleTableViewCell
                cell.statusLabel.text  = d.status
                cell.statusLabel.textColor = d.statusColor
                cell.timeLabel.text    = d.time
                cell.deatilsLabel.text = d.details
                cell.contentView.alpha = d.isLeft ? 0.55 : 1
                return cell
            case is ViewState.ExpandRow     :
                scrollableItemEnd = indexPath.row - 1
                let cell = tableView.dequeueReusableCell(withIdentifier: MCDExpandTableViewCell.reuseID, for: indexPath) as! MCDExpandTableViewCell
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewState.state {
        case .loading :
            tableView.deselectRow(at: indexPath, animated: false)
        case  .towardsStart:
            switch viewState.start[indexPath.row] {
            case is ViewState.Train :
                let d = viewState.start[indexPath.row] as! ViewState.Train
                d.onSelect()
                tableView.deselectRow(at: indexPath, animated: false)
            case is ViewState.ExpandRow     :
                tableView.deselectRow(at: indexPath, animated: false)
                self.forcedScroll(animated: true)
            default:
                break
            }
        case .towardsEnd:
            switch viewState.end[indexPath.row] {
            case is ViewState.Train :
                let d = viewState.end[indexPath.row] as! ViewState.Train
                d.onSelect()
                tableView.deselectRow(at: indexPath, animated: false)
            case is ViewState.ExpandRow     :
                self.forcedScroll(animated: true)
                tableView.deselectRow(at: indexPath, animated: false)
            default:
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}
