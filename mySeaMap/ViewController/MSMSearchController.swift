//
//  MSMSearchController.swift
//  myseamap
//
//  Created by Frank Budszuhn on 12.07.20.
//  Copyright © 2020 Frank Budszuhn. See LICENSE.
//

import UIKit

class MSMSearchController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var placemarks: [CLPlacemark]?


    override func viewDidLoad() {
        super.viewDidLoad()

        // setup search controller
        searchController.searchResultsUpdater = self
        //searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false

        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchString = searchController.searchBar.text {
            
            performSearch(searchString: searchString)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return placemarks?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "search-cell", for: indexPath)

        if let placemark = placemarks?[indexPath.row] {
            
            cell.textLabel?.text = placemark.locality
        }

        return cell
    }

  
 
    fileprivate func performSearch(searchString: String) {
        
        guard searchString.count > 2 else {
            self.placemarks = nil
            self.tableView.reloadData()
            return
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchString) { [unowned self] (placeMarkArray, error) in
            if error != nil {
                print("Error in search : \(String(describing: error))")
            }
            
            if let placeMarks = placeMarkArray {
                
                DispatchQueue.main.async { [unowned self] in
                    self.placemarks = placeMarks
                    self.tableView.reloadData()
                }
            }
        }
    }


}
