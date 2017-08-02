//
//  DatePickerViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/1/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import JModalController
import MBProgressHUD

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var acceptB: UIButton!
    
    var delegate: DatePickerDelegate!
    var jm_delegate : JModalDelegate!
    var label : String!
    var date: String?
    var format: String?
    var type: UIDatePickerMode?
    var tag: Int?
    
    var minDate:MinDate?
    var maxDate:MaxDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.text.text = label
        self.picker.datePickerMode = type!
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = self.format
        
        if (date != nil) {
            if let dateDate = dayTimePeriodFormatter.date(from: date!) {
                self.picker.date = dateDate
            }
        }
        
        switch self.minDate! {
        case .none:
            break
        case .now:
            self.picker.minimumDate = Date()
        case .date(let dateStr):
            if let dateDate = dayTimePeriodFormatter.date(from: dateStr) {
                self.picker.date = dateDate
                self.picker.minimumDate = dateDate
            }
        case .timeOnDate(let dateStr, let frmt):
            print("\(dateStr) | \(frmt)")
            let formatter = DateFormatter()
            formatter.dateFormat = frmt
            let dateDate = formatter.string(from: Date())
            if dateDate == dateStr {
                self.picker.date = Date()
                self.picker.minimumDate = Date()
            }
            
        }
        
        switch self.maxDate! {
        case .none:
            break
        case .now:
            self.picker.maximumDate = Date()
        case .date(let dateStr):
            if let dateDate = dayTimePeriodFormatter.date(from: dateStr) {
                self.picker.maximumDate = dateDate
            }
        case .timeOnDate(let dateStr, let frmt):
            print("\(dateStr) | \(frmt)")
            let formatter = DateFormatter()
            formatter.dateFormat = frmt
            let dateDate = formatter.string(from: Date())
            if dateDate == dateStr {
                self.picker.date = Date()
                self.picker.maximumDate = Date()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    func loadWith(label: String, date: String?, format:String?, type: UIDatePickerMode, minDate:MinDate, maxDate:MaxDate, delegate: DatePickerDelegate, jm_delegate: JModalDelegate, tag: Int) {
        self.label = label
        self.date = date
        self.format = format
        self.type = type
        self.delegate = delegate
        self.jm_delegate = jm_delegate
        self.tag = tag
        
        self.minDate = minDate
        self.maxDate = maxDate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeDatePicker(_ sender: Any) {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = format
        
        let dateString = dayTimePeriodFormatter.string(from: picker.date)
        
        delegate.datePickerDidSelectDate(date: picker.date, string:dateString, tag: tag!)
        jm_delegate.dismissModal(self, data: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    public enum MinDate {
        case none
        case now
        case timeOnDate(String, String)
        case date(String)
    }
    
    public enum MaxDate {
        case none
        case now
        case timeOnDate(String, String)
        case date(String)
    }
    
}


public protocol DatePickerDelegate : NSObjectProtocol {
    
    @available(iOS 7.0, *)
    func datePickerDidSelectDate(date: Date, string: String, tag: Int)
    
}
