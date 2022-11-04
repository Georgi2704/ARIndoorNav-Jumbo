//  ARIndoorNav
//
//  ManageMapsController.swift
//  Class - ManageMapsController
//  Extensions - UITableViewDelegate, UITableViewDataSource
//
//  Created by Bryan Ung on 7/1/20.
//  Copyright © 2021 Bryan Ung. All rights reserved.
//
//  This class is a separate ViewController which is navigated to by the Hamburger Menu button on the main View Controller. This handles all actions regarded to the mangagement of maps. Users can kick off uploading a map, starting navigation using a custom map, or downloading custom maps.

import UIKit
import Firebase

//Reuse Identifer Variable for the table cells.
private let reuseIdentifier = "MapOptionCell"

class ManageMapsController: UIViewController {
    
    // MARK: - Properties

    var tableView: UITableView!
    var dataModelSharedInstance: DataModel?
    var manageMapsControllerDelegate: ManageMapsControllerDelegate?
    var cancelButton = UIButton(type: .system) as UIButton
    
    // MARK: - Init
    
    /*/ viewDidLoad()
     Initialization of the datamodel instance, view, and table
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismiss(animated: true, completion: nil)

        self.dataModelSharedInstance = DataModel.dataModelSharedInstance
        resetState()
        hideKeyboardWhenTappedAround()
        configureUI()
        configureTableView()
        self.dataModelSharedInstance!.getLocationDetails().setIsCreatingCustomMap(isCreatingCustomMap: true)
        //Refers to delegate, ContainerController and calls the function createCustomMapProcess() which invokes the main VC (housing the ARSceneView) to begin creating a custom map.
        self.manageMapsControllerDelegate!.createCustomMapProcess()
    }
    
    @objc func buttonAction() {
        self.dataModelSharedInstance!.getLocationDetails().setIsCreatingCustomMap(isCreatingCustomMap: true)
        //Refers to delegate, ContainerController and calls the function createCustomMapProcess() which invokes the main VC (housing the ARSceneView) to begin creating a custom map.
        self.manageMapsControllerDelegate!.createCustomMapProcess()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Selectors
    
    /*/ handleDismiss()
     Dismisses the View Controller when the navigation Bar left button is clicked.
     */
    @objc func handleDismiss(){
        self.dismiss(animated: true, completion: nil)
        self.dataModelSharedInstance!.getLocationDetails().setIsUploadingMap(isSet: false)
    }
    /*/ handleAdd()
     Handles the Navigation Bar Right Button when clicked.
     */
    @objc func handleAdd(){
        generatePopUp()
    }
    /*/ handleAdd()
     Handles the cancel button when clicked.
     */
    @objc func handleCancel(){
        toggleCancelButton(shouldShow: false)
        self.dataModelSharedInstance!.getLocationDetails().setIsUploadingMap(isSet: false)
    }
    
    // MARK: - Helper Functions
    
    /*/ resetState()
     Resets the View Controller state to the normal state by resetting the DataModel.LocationDetails variables to false
     */
    private func uploadState(){
        self.dataModelSharedInstance!.getLocationDetails().setIsCreatingCustomMap(isCreatingCustomMap: true)
        //Refers to delegate, ContainerController and calls the function createCustomMapProcess() which invokes the main VC (housing the ARSceneView) to begin creating a custom map.
        self.manageMapsControllerDelegate!.createCustomMapProcess()
    }
    
    private func resetState(){
        self.dataModelSharedInstance!.getLocationDetails().setIsCreatingCustomMap(isCreatingCustomMap: false)
        self.dataModelSharedInstance!.getLocationDetails().setIsUploadingMap(isSet: false)
    }
    /*/ generatePopUp()
     
     This function is called when the button on the ManageMapsController (top right)
     is clicked. It presents an actionsheet with options to 'create' 'upload' 'download'
     a custom map.
    */
    private func generatePopUp(){
        //Gets the number of custom maps stored on the device.
        let listCount = dataModelSharedInstance!.getDataStoreManager().dataStore.getLocationInfoList().count
        let alertController = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Create Custom Map", style: .default, handler: { _ in
            self.dataModelSharedInstance!.getLocationDetails().setIsCreatingCustomMap(isCreatingCustomMap: true)
            //Refers to delegate, ContainerController and calls the function createCustomMapProcess() which invokes the main VC (housing the ARSceneView) to begin creating a custom map.
            self.manageMapsControllerDelegate!.createCustomMapProcess()
            self.dismiss(animated: true, completion: nil)
        }))
        //User will only allow uploading of maps if they are logged in.
        alertController.addAction(UIAlertAction(title: "Upload Custom Maps", style: .default, handler: { _ in
            if Auth.auth().currentUser == nil {
                self.alert(info: AlertConstants.notLoggedIn)
            } else if (listCount <= 0){
                //If there are no saved maps, you can't upload a map.
                self.alert(info: AlertConstants.createMapToUpload)
            } else {
                //Prepares user to click on a map to upload
                self.alert(info: AlertConstants.selectMapToUpload)
                self.dataModelSharedInstance!.getLocationDetails().setIsUploadingMap(isSet: true)
                self.dataModelSharedInstance!.getLocationDetails().setIsCreatingCustomMap(isCreatingCustomMap:false)
                self.toggleCancelButton(shouldShow: true)
            }
        }))
        //Users will only be allowed to download maps if they are logged in.
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
    /*/ generateDownloadableOptionsAlert(data: Data)
     Receives data from the node.js server and parses it into a list of selectable names for a user to select which map to download.
     
     @param: data - Data - data sent back as an object from the nodejs server
     */
    /*/ downloadCustomMap(title: String)
     Receives a title of the name of the map the user wants to download. It uses this name to make a request to the node.js server for navigation information which then saves the map to the user's device.
     
     @param: data - Data - data sent back as an object from the nodejs server
     */
    /*/ toggleCancelButton(shouldShow : Bool)
     Toggles the visibility of the cancel button.
     
     @param: Bool - boolean value determining if the cancel button should show.
     */
    func toggleCancelButton(shouldShow : Bool){
        if shouldShow{
            configureCancelButton()
        } else {
            cancelButton.removeFromSuperview()
        }
    }
    
    //MARK: -Configurations
    
    /*/ configureUI()
     Configures the UI of the VC.
     */
    private func configureUI(){
        view.backgroundColor = AppThemeColorConstants.white
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = AppThemeColorConstants.gold
            appearance.titleTextAttributes = [.foregroundColor: AppThemeColorConstants.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: AppThemeColorConstants.white]
            
            self.navigationController?.navigationBar.tintColor = AppThemeColorConstants.white
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            self.navigationController?.navigationBar.tintColor = AppThemeColorConstants.white
            self.navigationController?.navigationBar.barTintColor = AppThemeColorConstants.white
            self.navigationController?.navigationBar.isTranslucent = false
        }
        self.navigationController?.navigationBar.prefersLargeTitles = true //makes bigger
        self.navigationController?.navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Manage Maps"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleAdd))
    }
    /*/ configureTableView()
     Initializes the TableView and set its delegates, and adds it to the view.
     */
    private func configureTableView(){
        tableView = UITableView()
        
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.backgroundColor = AppThemeColorConstants.white
        tableView.rowHeight = 60
        
        tableView.register(MapOptionCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        tableView.tableFooterView = UIView()
    }
    /*/ configureBottomButton()
     Configures the CancelButton and adds it to the view.
     */
    func configureCancelButton(){
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.backgroundColor = AppThemeColorConstants.gold.withAlphaComponent(0.60)
        self.cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.setTitleColor(AppThemeColorConstants.red, for: .normal)
        
        view.addSubview(cancelButton)
        //constraints
        self.cancelButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.cancelButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: BottomLabelConstants.bottomPadding).isActive = true
        self.cancelButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 75).isActive = true
        self.cancelButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -75).isActive = true
        self.cancelButton.layer.cornerRadius = 5
        
        self.cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
    }
}
