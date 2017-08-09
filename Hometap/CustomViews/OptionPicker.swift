//
//  OptionPicker.swift
//  Hometap
//
//  Created by Daniel Soto on 8/2/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import JModalController

class OptionPicker: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static public func pickerWith(title: String, options: [String], delegate: OptionPickerDelegate, onViewController: UIViewController, allowMultiple: Bool = false, tag: Int = 0, selected: [Int] = []) -> Void {
        let storyboard = UIStoryboard(name: "OptionPicker", bundle: nil)
        let option_picker = storyboard.instantiateViewController(withIdentifier: "OptionPicker") as? OptionPicker
        // Acá me pasa TODOS los posibles
        option_picker?.label = title
        option_picker?.delegate = delegate
        option_picker?.jm_delegate = delegate as! JModalDelegate
        option_picker?.options = options
        option_picker?.allowMultiple = allowMultiple
        option_picker?.tag = tag
        option_picker?.indexes = selected
        
        let config = JModalConfig(transitionDirection: .bottom, animationDuration: 0.2, backgroundTransform: false, tapOverlayDismiss: true)
        
        onViewController.presentModal(onViewController, modalViewController: option_picker!, config: config, completion: nil)
    }
    
    private var options: [String] = []
    private var allowMultiple = false
    private var label: String = "Options"
    private var tag:Int = 0
    private var indexes: [Int] = []
    
    private var layouted:Bool = false
    
    @IBOutlet weak var optionTable: UITableView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var doneB: UIButton!
    
    private var delegate: OptionPickerDelegate!
    
    private var jm_delegate : JModalDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.text.text = label
        self.text.textColor = K.UI.form_color
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.layouted = true
        self.doneB.roundCorners(radius: K.UI.light_round_px)
        self.doneB.addLightShadow()
        self.optionTable.reloadData()
    }
    
    
    @IBAction func closePicker(_ sender: Any) {
        guard !indexes.isEmpty else{
            showAlert(title: "Lo sentimos", message: "Debes seleccionar una opción", closeButtonTitle: "Listo")
            return
        }
        if allowMultiple {
            delegate.optionPickerDidPickMultipleSubjects!(indexes: indexes, selected: options[indexes], tag:tag)
            jm_delegate.dismissModal(self, data: nil)
        } else {
            delegate.optionPickerDidPickSubject(index: indexes[0], selected: options[indexes[0]], tag:tag)
            jm_delegate.dismissModal(self, data: nil)
        }
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return layouted ? options.count : 0
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        if self.layouted {
            (cell.viewWithTag(1)?.clearShadows())
            (cell.viewWithTag(1)?.addNormalShadow())
            if indexes.contains(indexPath.row) {
                cell.viewWithTag(1)?.backgroundColor = K.UI.main_color
                (cell.viewWithTag(1)?.viewWithTag(2) as? UILabel)?.textColor = .white
            } else {
                cell.viewWithTag(1)?.backgroundColor = UIColor.white
                (cell.viewWithTag(1)?.viewWithTag(2) as? UILabel)?.textColor = .black
            }
        }
        (cell.viewWithTag(1)?.viewWithTag(2) as? UILabel)?.text = options[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if allowMultiple {
            if indexes.contains(indexPath.row) {
                indexes.remove(object: indexPath.row)
            } else {
                indexes.append(indexPath.row)
            }
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else {
            indexes.insert(indexPath.row, at: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
            self.closePicker(self)
        }
    }
    
    
}

@objc public protocol OptionPickerDelegate : NSObjectProtocol {
    
    @available(iOS 7.0, *)
    func optionPickerDidPickSubject(index:Int, selected:String, tag:Int)
    
    @objc @available(iOS 7.0, *)
    optional func optionPickerDidPickMultipleSubjects(indexes:[Int], selected:[String], tag:Int)
    
}
