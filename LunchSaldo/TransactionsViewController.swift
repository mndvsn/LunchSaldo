//
//  TransactionsViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-02-03.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit
import Alamofire

enum TransactionState: Int {
  case Successful, Failed
}

enum TransactionType: Int {
  case Purchase, Reload
}

struct Transaction: Printable {
  let amount: Double
  let date: String
  let state: TransactionState
  let type: TransactionType
  
  var description: String {
    return "[\(date)] \(amount)"
  }
}

class TransactionCell: UITableViewCell {
  
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}

class TransactionsViewController: UITableViewController {

  @IBOutlet weak var loadMoreButton: UIBarButtonItem!
  
  let cardId = NSUserDefaults.standardUserDefaults().integerForKey(AppSettings.Key.RikslunchenCardID.rawValue)
  
  var transactions = [Transaction]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadMoreButton.tintColor = UIColor.whiteColor()
    

    loadTransactions(20, withOffset: transactions.count) {
      self.tableView.reloadData()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  func loadTransactions(number: Int, withOffset offset: Int, onComplete: () -> ()) {
    loadMoreButton.enabled = false
    Alamofire.request(RikslunchenRouter.GetTransactions(cardId: cardId, from: NSDate(timeIntervalSinceReferenceDate: 0), to: NSDate(), records: number, offset: offset))
      .response { (_, _, data, _) in
        if let records = RikslunchenParser.parseTransactions(data as NSData) {
          self.transactions.extend(records)
          self.loadMoreButton.enabled = true
          onComplete()
        }
    }
  }
  
  @IBAction func loadMoreTransactions(sender: UIBarButtonItem) {
    loadTransactions(50, withOffset: transactions.count) {
      let oldLastRow = self.tableView.numberOfRowsInSection(0)
      self.tableView.reloadData()
      
      let newLastRow = self.tableView.numberOfRowsInSection(0)
      if newLastRow == oldLastRow {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: newLastRow - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
      } else {
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: oldLastRow, inSection: 0), atScrollPosition: .Top, animated: true)
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return transactions.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("transaction", forIndexPath: indexPath) as TransactionCell
    
    let transaction = transactions[indexPath.row]
    
    cell.dateLabel.text = transaction.date
    cell.amountLabel.text = "\(transaction.amount)0"
    
    switch transaction.type {
    case .Purchase:
      cell.amountLabel.textColor = AppSettings.Color.red!
    case .Reload:
      cell.amountLabel.textColor = AppSettings.Color.blue!
      cell.amountLabel.text = "+" + cell.amountLabel.text!
    }
    
    if transaction.state == .Successful {
      cell.contentView.backgroundColor = nil
    } else {
      let red = AppSettings.Color.red!
      cell.contentView.backgroundColor = red.colorWithAlphaComponent(0.1)
    }
    
    return cell
  }
  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
}
