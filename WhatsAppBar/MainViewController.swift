//
//  MainViewController.swift
//  WhatsAppBar
//
//  Created by Aldy on 20/05/2018.
//  Copyright © 2018 Aldy. All rights reserved.
//

import Cocoa
import WebKit

class MainViewController: NSViewController, NSComboBoxDelegate, NSTextFieldDelegate {

    @IBOutlet var lblPhoneNumb: NSTextField!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var cmbDataSource: ComboBoxDataSource!
    @IBOutlet var cmbBox: NSComboBox!
    @IBOutlet var lblCountryCode: NSTextField!
    @IBOutlet var imgFlag: NSImageView!
    @IBOutlet var menus: NSMenu!
    
    let clickToChatUrl = "https://api.whatsapp.com/send?phone="
    var url = URL(string:"")
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        cmbBox.numberOfVisibleItems = 10
        cmbBox.dataSource = cmbDataSource
        cmbBox.delegate = self
        lblPhoneNumb.delegate = self
        
        let savedIndex = UserDefaults.userCountryIndex
        if savedIndex != -1 {
            cmbBox.selectItem(at: savedIndex)
        }
    }
    
    public func comboBoxSelectionDidChange(_ notification: Notification){
        setSelectedCountry(country: cmbDataSource.comboBox(cmbBox, objectForItemAt: cmbBox.indexOfSelectedItem)! as! Countries)
    }

    override func controlTextDidChange(_ obj: Notification) {
        let  characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789-").inverted as  NSCharacterSet
        self.lblPhoneNumb.stringValue =  (self.lblPhoneNumb.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
    }
    
    @IBAction func onEnter(_ sender: NSComboBox) {
        setSelectedCountry(country: cmbDataSource.comboBox(cmbBox, objectForItemAt: cmbBox.indexOfSelectedItem)! as! Countries)
    }
    
    private func setSelectedCountry(country: Countries) {
        print(country)
        
        lblCountryCode.stringValue = country.dialCode
        imgFlag.image = NSImage.init(imageLiteralResourceName: country.iso2)
        
        lblPhoneNumb.isEditable = true
    }
    
    @IBAction func messageThisNumber(_ sender: AnyObject) {
        let phoneNumberSuffix = phoneNumberChecker(numberToCheck: lblCountryCode.stringValue)
        var phoneNumber = lblPhoneNumb.stringValue
        
        if(phoneNumber.isEmpty) {
            showPhoneNumberEmptyInfo()
            return
        }
        
        if phoneNumber.prefix(1) == "0" {
            phoneNumber.removeFirst()
        }
      
        phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        phoneNumber = phoneNumberSuffix + phoneNumber
        
        url = URL(string: clickToChatUrl+phoneNumber)!
        
        let cfs = "desktop.WhatsApp" as CFString
        let result = LSCopyApplicationURLsForBundleIdentifier (cfs, nil)
        
        if result?.takeRetainedValue().hashValue != 1 {
            showAlertAppNotFound()
        } else {
            webView.load(URLRequest(url:url!))
            lblPhoneNumb.stringValue = ""
            
            (NSApplication.shared.delegate as! AppDelegate).closePopover(sender: self)
        }
    }
    
    private func showAlertAppNotFound() {
        let myAlert = NSAlert()
        myAlert.messageText = "Info"
        myAlert.informativeText = "You don't have WhatsApp Desktop Apps\nDo you want to install now ?"
        myAlert.alertStyle = NSAlert.Style.informational
        myAlert.icon = NSImage(named:NSImage.Name("AppIcon"))
        myAlert.addButton(withTitle: "Yes")
        myAlert.addButton(withTitle: "No")
        
        switch myAlert.runModal() {
        case NSApplication.ModalResponse.alertFirstButtonReturn:
            let urlStr = "macappstore://itunes.apple.com/us/app/whatsapp-desktop/id1147396723?mt=12"
            NSWorkspace.shared.open(URL(string: urlStr)!)
            break
        case NSApplication.ModalResponse.alertSecondButtonReturn:
            break
        default: break
        }
    }
    
    private func showPhoneNumberEmptyInfo() {
        let myAlert = NSAlert()
        myAlert.messageText = "Warning!"
        myAlert.informativeText = "Please input phone number you want to contact"
        myAlert.alertStyle = NSAlert.Style.informational
        myAlert.icon = NSImage(named:NSImage.Name("AppIcon"))
        myAlert.showsSuppressionButton = false
        myAlert.suppressionButton?.title = "Ok"
        myAlert.runModal()
    }
    
    func phoneNumberChecker(numberToCheck: String) -> String {
        if numberToCheck == "54" {
            return "54"+"9"
        } else if numberToCheck == "52" {
            return "52"+"1"
        }
        return numberToCheck
    }
    
    @IBAction func buyMeCoffee(_ sender: Any) {
        let url = URL(string:"https://ko-fi.com/aldychris")!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func settingMenu(_ sender: NSButton) {
        menus.popUp(positioning: menus.item(at: 0), at: NSEvent.mouseLocation, in: nil)
    }
    
    @IBAction func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}



extension MainViewController {
    static func freshController() -> MainViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "MainViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? MainViewController else {
            fatalError("Why cant i find MainViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

