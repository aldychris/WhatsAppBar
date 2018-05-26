//
//  SettingViewController.swift
//  WhatsAppBar
//
//  Created by Aldy on 20/05/2018.
//  Copyright © 2018 Aldy. All rights reserved.
//

import Cocoa
import ServiceManagement

class SettingViewController: NSViewController, NSComboBoxDelegate {
    
    @IBOutlet var cmbBox: NSComboBox!
    @IBOutlet var cmbDataSource: ComboBoxDataSource!
    @IBOutlet var chkStartup: NSButton!
    
    var selectedObject = Countries(name:"", iso2:"", dialCode:"")
    
    override func viewDidLoad() {
        let appdel : AppDelegate = NSApplication.shared.delegate as! AppDelegate
        appdel.closePopover(sender: self)
        
        cmbBox.numberOfVisibleItems = 10
        cmbBox.dataSource = cmbDataSource
        cmbBox.delegate = self

        let savedIndex = UserDefaults.userCountryIndex
        if savedIndex != -1 {
            cmbBox.selectItem(at: savedIndex)
        }
        
        if UserDefaults.didEnableStartOnLogin == 1 {
            chkStartup.state = NSControl.StateValue.on
        } else {
            chkStartup.state = NSControl.StateValue.off
        }
    }
    
    public func comboBoxSelectionDidChange(_ notification: Notification){
        selectedObject = cmbDataSource.comboBox(cmbBox, objectForItemAt: cmbBox.indexOfSelectedItem)! as! Countries
        print(selectedObject)
    }
    
    @IBAction func onFinishEditing(_ sender: NSComboBox){
        selectedObject = cmbDataSource.comboBox(cmbBox, objectForItemAt: cmbBox.indexOfSelectedItem)! as! Countries
        print(selectedObject)
    }
    
    @IBAction func saveSetting(_ sender:NSButton) {
        if selectedObject.name != "" {
            UserDefaults.set(userCountryIndex: cmbBox.indexOfSelectedItem)
        }
        
        UserDefaults.set(didEnableStartOnLogin: chkStartup.state.rawValue)
        
        let launcherAppId = "com.aldychris.whatsappbar.Launcher"
        if chkStartup.state.rawValue == 1 {
            SMLoginItemSetEnabled(launcherAppId as CFString, true)
        }
        else {
            SMLoginItemSetEnabled(launcherAppId as CFString, false)
        }
        
        dismissViewController(self)
    }
    
    
}
