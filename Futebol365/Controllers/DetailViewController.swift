//
//  DetailViewController.swift
//  Futebol365
//
//  Created by Adriano Goncalves on 23/08/2015.
//  Copyright (c) 2015 Adriano Goncalves. All rights reserved.
//

import UIKit
import Parse

class DetailViewController: UIViewController {
   
   @IBOutlet weak var homeTeam: UILabel!
   @IBOutlet weak var awayTeam: UILabel!
   @IBOutlet weak var homeTeamFavourite: UISwitch!
   @IBOutlet weak var awayTeamFavourite: UISwitch!
   
   private var favourites: [FPTFavouriteTeam] = []
   
   var item: FPTGame!
   
   // MARK: UIViewController
   
   override func viewDidLoad() {
      super.viewDidLoad()
      homeTeam.text = item.homeTeamName
      awayTeam.text = item.awayTeamName
      
      if let user = PFUser.currentUser() {
         let query = PFQuery(className: FPTFavouriteTeam.parseClassName())
         query.whereKey("user", equalTo: user)
         query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if error == nil {
               if let allFavourites = results as? [FPTFavouriteTeam] {
                  if allFavourites.count > 0 {
                     self.favourites = results as! [FPTFavouriteTeam]
                     for favourite in allFavourites {
                        if favourite.team == self.item.homeTeam {
                           self.homeTeamFavourite.setOn(true, animated: true)
                        }
                        if favourite.team == self.item.awayTeam {
                           self.awayTeamFavourite.setOn(true, animated: true)
                        }
                     }
                  }
               }
            } else {
               
            }
         })
      } else {
         showError("No user logged in")
      }
      
   }
   
   // MARK: Actions
   
   @IBAction func homeTeamFavouriteChanged(sender: UISwitch) {
      if sender.on {
         addFavourite(item.homeTeam)
      } else {
         removeFavourite(item.homeTeam)
      }
   }
   
   @IBAction func awayTeamFavouriteChanged(sender: UISwitch) {
      if sender.on {
         addFavourite(item.awayTeam)
      } else {
         removeFavourite(item.awayTeam)
      }
   }
   
   // MARK: Private
   
   private func showError(message: String) {
      homeTeamFavourite.enabled = false
      awayTeamFavourite.enabled = false
      let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in }))
      self.presentViewController(alert, animated: true, completion: nil)
   }
   
   private func addFavourite(team: FPTTeam) {
      if let user = PFUser.currentUser() {
         let newFavourite = FPTFavouriteTeam(className: FPTFavouriteTeam.parseClassName())
         newFavourite.team = team
         newFavourite.user = user
         newFavourite.saveInBackgroundWithBlock({ (result, error) -> Void in
            print(error)
         })
         favourites.append(newFavourite)
      }
   }
   
   private func removeFavourite(team: FPTTeam) {
      for (index,favourite) in favourites.enumerate() {
         if favourite.team == team {
            favourite.deleteInBackgroundWithBlock({ (result, error) -> Void in
               print(error)
            })
            favourites.removeAtIndex(index)
            break
         }
      }
   }
   
}
