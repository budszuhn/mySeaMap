//
//  MSMSearchController.swift
//  myseamap
//
//  Created by Frank Budszuhn on 12.07.20.
//  Copyright © 2020 Frank Budszuhn. See LICENSE.
//

import UIKit

class MSMSearchController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var placemarks: [CLPlacemark]?
    @objc var delegate: MSMSearchViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        // setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = true

        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
        delegate?.searchDone()
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
            cell.detailTextLabel?.text = placemark.formattedPlacemark()
        }

        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let placemark = placemarks?[indexPath.row] {
            
            delegate?.setPlacemark(placemark)
        }
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
