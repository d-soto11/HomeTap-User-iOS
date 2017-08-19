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
    
    static func pickerWith(title: String, date: String? = nil, format:String = "dd-MM-yyyy", type: UIDatePickerMode = .date, minDate:MinDate = .none, maxDate:MaxDate = .none, delegate: DatePickerDelegate, jm_delegate: JModalDelegate, tag: Int = 0, onViewController: UIViewController) {
        
        let date_picker = DatePickerViewController.init(nibName: "DatePickerViewController", bundle: nil)
        
        date_picker.label = title
        date_picker.date = date
        date_picker.format = format
        date_picker.type = type
        date_picker.delegate = delegate
        date_picker.jm_delegate = jm_delegate
        date_picker.tag = tag
        
        date_picker.minDate = minDate
        date_picker.maxDate = maxDate
        
        let config = JModalConfig(transitionDirection: .bottom, animationDuration: 0.2, backgroundTransform: false, tapOverlayDismiss: true)
        onViewController.presentModal(onViewController, modalViewController: date_picker, config: config) {
        }
    }
    
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var acceptB: UIButton!
    
    private var delegate: DatePickerDelegate!
    private var jm_delegate : JModalDelegate!
    private var label : String!
    private var date: String?
    private var format: String?
    private var type: UIDatePickerMode?
    private var tag: Int?
    
    private var minDate:MinDate?
    private var maxDate:MaxDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.text.text = label
        self.picker.datePickerMode = type!
        self.text.textColor = K.UI.form_color
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
        case .tomorrow:
            self.picker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
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
        case .tomorrow:
            self.picker.maximumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
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
    
    override func viewDidLayoutSubviews() {
        self.acceptB.roundCorners(radius: K.UI.light_round_px)
        self.acceptB.addLightShadow()
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
        case tomorrow
        case timeOnDate(String, String)
        case date(String)
    }
    
    public enum MaxDate {
        case none
        case now
        case tomorrow
        case timeOnDate(String, String)
        case date(String)
    }
    
}


public protocol DatePickerDelegate : NSObjectProtocol {
    
    @available(iOS 7.0, *)
    func datePickerDidSelectDate(date: Date, string: String, tag: Int)
    
}
