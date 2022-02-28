import Foundation
import UIKit

extension AMLCalendar {
    
    func setupCollectionView() {
        
        collectionView.register(
            CalendarCell.self,
            forCellWithReuseIdentifier: CalendarCell.identifier
        )
        
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.identifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = style.backgroundColor
    }
}

extension AMLCalendar: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return months.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let section = months[section]
        return section.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellFor(collectionView: collectionView, indexPath: indexPath)
    }

    // TODO: - check performance with will display
    private func cellFor(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as! CalendarCell
        
        cell.update(style: style)
        
        let month = months[indexPath.section]
        let day = month[indexPath.row]
        cell.model = (day, calendar)
        
        /// read extra info text from delegate if exist
        if let info = delegate?.infoText(date: day.date) {
            cell.infoText = info
        }
        
        // TODO: - move appearance functions to another delegated method
        /// handle selection
        guard day.isWithinMonth else { return cell }
        guard
            let lowerBoundDate = lowerBoundSelectedDate,
            let upperBoundDate = upperBoundSelectedDate else {
                  if day.isSelected {
                      cell.select()
                  }
                  return cell
              }
        
        guard configuration.rangeSelectionEnabled else { return cell }
        let range = (lowerBoundDate...upperBoundDate)
        if day.date == range.lowerBound {
            cell.select(.start)
        } else if day.date == range.upperBound {
            cell.select(.end)
        } else if range.contains(day.date) {
            cell.select(.mid)
        } else {
            
        }
        return cell
    }
}

extension AMLCalendar {
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return headerView(collectionView: collectionView, indexPath: indexPath)
        default :
            assertionFailure("undefined view")
            return UICollectionReusableView()
        }
    }
    
    private func headerView(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.identifier,
            for: indexPath
        ) as! HeaderView
        
        header.updateStyle(style: style)
        
        // TODO: - change datasource to an other struct/class ...
        let month = months[indexPath.section]
        let someRandomDay = month[15]
        header.text = monthHeaderDateFormatter.string(from: someRandomDay.date)
        return header
    }
}


extension AMLCalendar: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfDaysInWeek = calendar.weekdaySymbols.count
        let insets = collectionView.contentInset.left + collectionView.contentInset.right
        let collectionRealWidth = collectionView.bounds.size.width - insets
        let width = (collectionRealWidth / CGFloat(numberOfDaysInWeek))
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // TODO: - get size from styled text
        return CGSize(
            width: collectionView.bounds.size.width,
            height: 60.0
        )
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCell
        months[indexPath.section][indexPath.row].isSelected = false
        cell.deselect()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarCell
        handleCellSelection(cell: cell, indexPath: indexPath)
    }
    
    private func handleCellSelection(cell: CalendarCell, indexPath: IndexPath) {
  
        
        let row = indexPath.row
        let day = months[indexPath.section][row]
        
        /// start / end of range should be in a month
        guard day.isWithinMonth else { return }
        
        /// date must be toady or later
        guard day.date >= calendar.today else { return }

        // TODO: - check with refresh section
        cell.select()
        months[indexPath.section][row].isSelected = true
        
        guard configuration.rangeSelectionEnabled  else {
            lowerBoundSelectedDate = day.date
            delegate?.didSelect(date: day.date)
            /// clear other selected days, because collection 'didDeselectItemAt' wont be called if the items where not showing in current page
            for month in months.enumerated() {
                for item in month.element.enumerated() {
                    if item.element.date != day.date {
                        months[month.offset][item.offset].isSelected = false
                    }
                }
            }
            collectionView.reloadData()
            return
        }
        
        /// range selection enabled flow
        if lowerBoundSelectedDate == nil {
            lowerBoundSelectedDate = day.date
            delegate?.didSelectDateRange(lowerBound: day.date, upperBound: nil)
        } else if upperBoundSelectedDate == nil {

            /// check that new selected day not be before previous start selected date
            guard let lowerBoundDate = lowerBoundSelectedDate,
                  day.date > lowerBoundDate else {
                      selectDateRangeLowerBound(day: day)
                      return
                  }
            
            let range = calendar.dateComponents([.day], from: lowerBoundDate, to: day.date)
            guard let rangeDaysCount = range.day,
                  rangeDaysCount <= configuration.rangeSelectionLimit else {
                      selectDateRangeLowerBound(day: day)
                      delegate?.failedToSelectDate(error: CalendarError.selectedIndexIsOutOfRangeLimitation)
                return
            }
            
            upperBoundSelectedDate = day.date
            delegate?.didSelectDateRange(lowerBound: lowerBoundDate, upperBound: day.date)
            /// set days between lower - upper bound to selected
            guard let upperBoundDate = upperBoundSelectedDate else { return }
            for month in months.enumerated() {
                for item in month.element.enumerated() {
                    
                    let date = item.element.date
                    if date > lowerBoundDate && date < upperBoundDate {
                        months[month.offset][item.offset].isSelected = true
                        collectionView.reloadData()
                    } else if date != lowerBoundDate && date != upperBoundDate {
                        months[month.offset][item.offset].isSelected = false
                        collectionView.reloadData()
                    }
                }
            }
        } else {
            selectDateRangeLowerBound(day: day)
        }
    }
    
    private func selectDateRangeLowerBound(day: Day) {
        
        lowerBoundSelectedDate = day.date
        upperBoundSelectedDate = nil
        delegate?.didSelectDateRange(lowerBound: day.date, upperBound: nil)
        /// reset range selection
        for month in months.enumerated() {
            for item in month.element.enumerated() {
                if item.element.date != day.date {
                    months[month.offset][item.offset].isSelected = false
                    collectionView.reloadData()
                }
            }
        }
    }
}
