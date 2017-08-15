//
//  SocialTableTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Niral Shah on 4/1/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class SocialTableTableViewController: UITableViewController {
    
    @IBOutlet weak var imageCell1: UIImageView!
    @IBOutlet weak var statusLabel1: UILabel!
    @IBOutlet weak var motvLabel1: UILabel!
    
    @IBOutlet weak var imageCell2: UIImageView!
    @IBOutlet weak var statusLabel2: UILabel!
    @IBOutlet weak var motvLabel2: UILabel!
    
    @IBOutlet weak var imageCell3: UIImageView!
    @IBOutlet weak var statusLabel3: UILabel!
    @IBOutlet weak var motvLabel3: UILabel!
    
    @IBOutlet weak var imageCell4: UIImageView!
    @IBOutlet weak var statusLabel4: UILabel!
    @IBOutlet weak var motvLabel4: UILabel!
    
    @IBOutlet weak var imageCell5: UIImageView!
    @IBOutlet weak var statusLabel5: UILabel!
    @IBOutlet weak var motvLabel5: UILabel!
    
    @IBOutlet weak var imageCell6: UIImageView!
    @IBOutlet weak var statusLabel6: UILabel!
    @IBOutlet weak var motvLabel6: UILabel!
    
    @IBOutlet weak var imageCell7: UIImageView!
   @IBOutlet weak var statusLabel7: UILabel! 
    @IBOutlet weak var motvLabel7: UILabel!

    @IBOutlet weak var imageCell8: UIImageView!
    @IBOutlet weak var statusLabel8: UILabel!
    @IBOutlet weak var motvLabel8: UILabel!
    
    @IBOutlet weak var imageCell9: UIImageView!
    @IBOutlet weak var statusLabel9: UILabel!
    @IBOutlet weak var motvLabel9: UILabel!
    
    @IBOutlet weak var imageCell10: UIImageView!
    
    @IBOutlet weak var statusLabel10: UILabel!
    @IBOutlet weak var motvLabel10: UILabel!
    
    @IBOutlet weak var statusLabel11: UILabel!
    @IBOutlet weak var motvLabel11: UILabel!
    @IBOutlet weak var imageCell11: UIImageView!
    
    @IBOutlet weak var imageCell12: UIImageView!

    @IBOutlet weak var statusLabel12: UILabel!
    @IBOutlet weak var motvLabel12: UILabel!
    
    let images = ["Sriram.png","Niral.png","Spencer.png","priyesh.png","milap.png","ravi.png"];
    let names = ["Sriram","Niral","Spencer","Priyesh","Milap","Ravi"];
    let labels = [" ran 5 miles today!", " burned 450 calories today!", " made 2 new friends!", " made 1 new friend!", " won their arena match!", " was first place on the leaderboard yesterday!", " earned a fitness achievement!", " completed a personal coaching session!", " wants to GET STRONGER!", " wants to GET FASTER!", " wants to GET LEAN", " wants to GET FLEXIBLE!", " wants to do it ALL!", " redeemed Beats Headphones!", " redeemed Nike Shoes!", " earned a protein bar!", " has a calorie goal of 3000!", " has a calorie goal of 1500!"]
    let motivationalQuote = ["#runFit", "#getFit", "#FitWithFriends", "#Fitspiration", "#ProFit", "#stayFit", " #playFit"," #beFit","#strengthFit", "#fastFit", "#leanFit", "#flexFit", "#allFit", "#prizeFit", "#motivationFit", "#workFit", "#goalFit", "#limitless"]
    
    var prevCell1 = 0;
    var prevCell2 = 1;
    var prevCell3 = 2;
    var prevCell4 = 3;
    var prevCell5 = 4;
    var prevCell6 = 5;
    
    var prevQCell1 = 0;
    var prevQCell2 = 1;
    var prevQCell3 = 2;
    var prevQCell4 = 3;
    var prevQCell5 = 4;
    var prevQCell6 = 5;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged);
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var randomNum1 = (Int(arc4random_uniform(5)))
            var randomNum2 = (Int(arc4random_uniform(5)))
            var randomNum3 = (Int(arc4random_uniform(5)))
            var randomNum4 = (Int(arc4random_uniform(5)))
            var randomNum5 = (Int(arc4random_uniform(5)))
            var randomNum6 = (Int(arc4random_uniform(5)))
            let size = self.motivationalQuote.count;
           
            var randomLabel1 = (Int(arc4random_uniform(17)))
            var randomLabel2 = (Int(arc4random_uniform(17)))
            var randomLabel3 = (Int(arc4random_uniform(17)))
            var randomLabel4 = (Int(arc4random_uniform(17)))
            var randomLabel5 = (Int(arc4random_uniform(17)))
            var randomLabel6 = (Int(arc4random_uniform(17)))
            
            
            
            self.imageCell12.image = UIImage(named:self.images[self.prevCell6]);
            self.statusLabel12.text = self.names[self.prevCell6]+self.labels[self.prevQCell6];
            self.motvLabel12.text = self.motivationalQuote[self.prevQCell6];
            
            self.imageCell11.image = UIImage(named:self.images[self.prevCell5]);
            self.statusLabel11.text = self.names[self.prevCell5]+self.labels[self.prevQCell5];
            self.motvLabel11.text = self.motivationalQuote[self.prevQCell5];
            
            self.imageCell10.image = UIImage(named:self.images[self.prevCell4]);
            self.statusLabel10.text = self.names[self.prevCell4]+self.labels[self.prevQCell4];
            self.motvLabel10.text = self.motivationalQuote[self.prevQCell4];
            
            self.imageCell9.image = UIImage(named:self.images[self.prevCell3]);
            self.statusLabel9.text = self.names[self.prevCell3]+self.labels[self.prevQCell3];
            self.motvLabel9.text = self.motivationalQuote[self.prevQCell3];
            
            self.imageCell8.image = UIImage(named:self.images[self.prevCell2]);
            self.statusLabel8.text = self.names[self.prevCell2]+self.labels[self.prevQCell2];
            self.motvLabel8.text = self.motivationalQuote[self.prevQCell1];
            
            self.imageCell7.image = UIImage(named:self.images[self.prevCell1]);
            self.statusLabel7.text = self.names[self.prevCell1]+self.labels[self.prevQCell1];
            self.motvLabel7.text = self.motivationalQuote[self.prevQCell1];
            
            
            self.imageCell6.image = UIImage(named:self.images[randomNum6]);
            self.statusLabel6.text = self.names[randomNum6]+self.labels[randomLabel6];
            self.motvLabel6.text = self.motivationalQuote[randomLabel6];
            
            self.imageCell5.image = UIImage(named:self.images[randomNum5]);
            self.statusLabel5.text = self.names[randomNum5]+self.labels[randomLabel5];
            self.motvLabel5.text = self.motivationalQuote[randomLabel5];
            
            self.imageCell4.image = UIImage(named:self.images[randomNum4]);
            self.statusLabel4.text = self.names[randomNum4]+self.labels[randomLabel4];
            self.motvLabel4.text = self.motivationalQuote[randomLabel4];
            
            self.imageCell3.image = UIImage(named:self.images[randomNum3]);
            self.statusLabel3.text = self.names[randomNum3]+self.labels[randomLabel3];
            self.motvLabel3.text = self.motivationalQuote[randomLabel3];
            
            self.imageCell2.image = UIImage(named:self.images[randomNum2]);
            self.statusLabel2.text = self.names[randomNum2]+self.labels[randomLabel2];
            self.motvLabel2.text = self.motivationalQuote[randomLabel2];
            
            self.imageCell1.image = UIImage(named:self.images[randomNum1]);
            self.statusLabel1.text = self.names[randomNum1]+self.labels[randomLabel1];
            self.motvLabel1.text = self.motivationalQuote[randomLabel1];
            
            self.prevCell6 = randomNum6;
            self.prevCell5 = randomNum5;
            self.prevCell4 = randomNum4;
            self.prevCell3 = randomNum3;
            self.prevCell2 = randomNum2;
            self.prevCell1 = randomNum1;
            
            
            self.prevQCell1 = randomLabel1;
            self.prevQCell2 = randomLabel2;
            self.prevQCell3 = randomLabel3;
            self.prevQCell4 = randomLabel4;
            self.prevQCell5 = randomLabel5;
            self.prevQCell6 = randomLabel6;
            
         });
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
       // let newMovie =
        //movies.append(newMovie)
        
    
        
       // movies.sort() { $0.title < $1.title }
        
        
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
        self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140.0
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, 120))
        
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    
}
