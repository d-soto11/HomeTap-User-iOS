//
//  PaymentsListViewController.swift
//  Hometap
//
//  Created by Daniel Soto on 8/27/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class PaymentsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var paymentsTable: UITableView!
    
    public var payments: [PaymentCard] = []
    
    public class func showList(parent: UIViewController) {
        let st = UIStoryboard.init(name: "Payments", bundle: nil)
        let list = st.instantiateViewController(withIdentifier: "List") as! PaymentsListViewController
        parent.show(list, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MBProgressHUD.showAdded(to: self.paymentsTable, animated: true)
        self.payments = []
        Client.withID(id: K.User.client?.uid ?? "") { (client) in
            K.User.client = client
            K.User.client?.payments(callback: { (payment, total) in
                if payment != nil {
                    self.payments.append(payment!)
                    if (self.payments.count == total) {
                        self.paymentsTable.reloadData()
                        MBProgressHUD.hide(for: self.paymentsTable, animated: true)
                    }
                } else {
                    MBProgressHUD.hide(for: self.paymentsTable, animated: true)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.payments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // isLastCell
        if (indexPath.row == self.payments.count) {
            let cell_m = tableView.dequeueReusableCell(withIdentifier: "addPaymentCell", for: indexPath) as! HTTableViewCell
            
            cell_m.uiUpdates = {(cell) in
                (cell.viewWithTag(1) as? UIButton)?.clearShadows()
                (cell.viewWithTag(1) as? UIButton)?.roundCorners(radius: K.UI.light_round_px)
                (cell.viewWithTag(1) as? UIButton)?.addLightShadow()
                (cell.viewWithTag(1) as? UIButton)?.addTarget(self, action: #selector(self.newPayment), for: .touchUpInside)
            }
            
            return cell_m
        } else {
            let cell_m = tableView.dequeueReusableCell(withIdentifier: "paymentCell", for: indexPath) as! HTTableViewCell
            let payment = payments[indexPath.row]
            
            cell_m.uiUpdates = {(cell) in
                cell.viewWithTag(2)?.roundCorners(radius: K.UI.light_round_px)
                cell.viewWithTag(2)?.addNormalShadow()
                (cell.viewWithTag(2)?.viewWithTag(11) as? UILabel)?.text = String(format: "%@ ***%@", payment.brand!, payment.number!)
            }
            return cell_m
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // isLastCell
        return indexPath.row == self.payments.count ? 80 : 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == payments.count {
            newPayment()
        } else {
            let payment = payments[indexPath.row]
            print(payment.uid!)
            print(payment.brand!)
            EditPaymentViewController.edit(parent: self, card: payment)
        }
    }
    
    func newPayment() {
        AddPaymentViewController.add(parent: self)
    }


}
