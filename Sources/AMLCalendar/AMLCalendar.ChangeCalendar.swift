import UIKit

extension AMLCalendar {
    
    private func refreshSymbolDays() {
        for stackItem in daySymbolsStackView.arrangedSubviews {
            stackItem.removeFromSuperview()
        }
        setupSymbolsOfDays()
    }
    
    public func changeCalendar(calendar: Calendar, animated: Bool = false) {
        
        func refreshCollectionView() {
            
            self.calendar = calendar
            
            monthHeaderDateFormatter.calendar = calendar
            monthHeaderDateFormatter.timeZone = calendar.timeZone
            monthHeaderDateFormatter.locale = calendar.locale
            
            dayDateFormatter.calendar = calendar
            dayDateFormatter.timeZone = calendar.timeZone
            dayDateFormatter.locale = calendar.locale
            
            dateManager = DateManager(calendar: self.calendar, dayDateFormatter: self.dayDateFormatter)
            lodaData()
            
            refreshSymbolDays()
            collectionView.setCollectionViewLayout(CustomCollectionFlowLayout(calendar: calendar), animated: false)
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
        
        guard animated else {
            refreshCollectionView()
            return
        }
        
        let showAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
            self?.subviews.forEach{ $0.alpha = 1 }
        }
        
        let hideAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak self] in
            self?.subviews.forEach{ $0.alpha = 0 }
        }
        
        hideAnimator.addCompletion { position in
            guard case .end = position else { return }
            refreshCollectionView()
            showAnimator.startAnimation()
        }
        
        hideAnimator.startAnimation()
    }
}
