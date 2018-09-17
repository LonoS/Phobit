//
//  AuswertungSelectionHandler.swift
//  Phobit
//
//  Created by 73 on 17.02.18.
//  Copyright © 2018 73. All rights reserved.
//

import Foundation
import UIKit

// Handles the Selection...
extension AuswertungsTableViewController: EditingProtocol, SpaltenSelectionProtocol {
    
    func finishedEditing(forMatrix: (Int, Int), text: String) {
        if text == "" {
            return
        }
        
        updateNumbers(forMatrix: forMatrix, text: text)
        print(forMatrix)
        print(text)
    }
    
    func updateNumbers(forMatrix matrix : (Int, Int), text : String){
        let doubleString = CFormat.correctStringToDouble(zahl: text)
        
        let steuerzeile = tableDict![IndexPath.init(row: matrix.0 + 1, section: 2)] as! Steuerzeile
        switch matrix.1{
        case 0:
            steuerzeile.setProzent(prozent: Int(text)!)
            steuerzeile.setNetto(netto: Double(steuerzeile.getBrutto()/(100+Double(steuerzeile.getProzent()))*100))//Nettto
            steuerzeile.setProzentbetrag(prozentbetrag: steuerzeile.getBrutto()-steuerzeile.getNetto())//MwSt
            
            
        case 1:
            steuerzeile.setNetto(netto: doubleString)
            steuerzeile.setBrutto(brutto: steuerzeile.getNetto()*(1+(Double(steuerzeile.getProzent())/100)))//Brutto
            steuerzeile.setProzentbetrag(prozentbetrag: steuerzeile.getBrutto()-steuerzeile.getNetto())//MwSt
            
            reloadBruttoGesamt()
            
            
        case 2:
            steuerzeile.setProzentbetrag(prozentbetrag: doubleString)
            steuerzeile.setNetto(netto: steuerzeile.getProzentbetrag()/Double(steuerzeile.getProzent())*100)//Netto
            steuerzeile.setBrutto(brutto: steuerzeile.getProzentbetrag()+steuerzeile.getNetto())//Brutto
            
            reloadBruttoGesamt()

        case 3:
            steuerzeile.setBrutto(brutto: doubleString)
            steuerzeile.setNetto(netto: Double(steuerzeile.getBrutto()/(100+Double(steuerzeile.getProzent()))*100))//Nettto
            steuerzeile.setProzentbetrag(prozentbetrag: steuerzeile.getBrutto()-steuerzeile.getNetto())//MwSt
            
            reloadBruttoGesamt()
        default: print("Fehler")
        }
        
        
        bill?.merchChanges(tableDict: tableDict!)
        
        tableView.reloadData()
        
    }
    
    
    /// Reloads the gesamt Brutto field on behold of all the others.
    func reloadBruttoGesamt(){
        var gesamtBrutto = 0.00
        
        for zahl in 0 ..< bill!.getNumberOfSteuerzeilen(){
            let steuerzeile = tableDict![IndexPath.init(row: zahl+1, section: 2)] as! Steuerzeile
            gesamtBrutto = gesamtBrutto + steuerzeile.getBrutto()
            
            
        }
        bill?.gesamtBrutto = gesamtBrutto
        
    }
    
    
    func textFieldInCellSelected(matrixNumber matrix: (Int, Int)) {
//        if is isDetail == false{
            let pickerView = storyboard?.instantiateViewController(withIdentifier: "SpaltenPicker") as! ZeilenPickerViewController
            pickerView.delegate = self
            pickerView.matrix = matrix
            switch matrix.1{
            case 0: pickerView.label = "Bitte gib den Prozentsatz ein"
            case 1: pickerView.label = "Bitte gib den Nettobetrag ein"
            case 2: pickerView.label = "Bitte gib die Mehrwertsteuer ein"
            case 3: pickerView.label = "Bitte gib den Bruttobetrag ein"
            default:
                pickerView.label = "Fehler"
            }
            pickerView.modalPresentationStyle = .overCurrentContext
            present(pickerView, animated: false, completion: nil)
//        }
        print(matrix)
    }
    
    
    // call by the sheets...
    func userDidEdit(inIndexPath indexPath: IndexPath, changedText text: String?) {
        // cant be accessed when the isDetail is true.
        if text == "" {return}
        
        switch indexPath.section {
        case 0:
            // rechnungsersteller
            tableDict![indexPath] = Item.init(value: text!, description: nil)
            
            
            // reload the table and also update the headline
            // merching it directly into the billdata object
            bill?.merchChanges(tableDict: tableDict!)
            
            if (useCase == .detail) && (bill?.rechnungsersteller != "Bitte Rechnungsersteller eigeben.") {
                self.navigationItem.title = bill?.rechnungsersteller
            }
            
            tableView.reloadData()
            
            return
            
        case 1:
            // datum
            tableDict![indexPath] = Item.init(value: text!, description: nil)
        case 2:
            // steuerzeilen (einziger mehrzeiler)
            // neue Objekte Speichern...
            // eigenes Protokoll
            return
        case 3:
            // Kontierung
            tableDict![indexPath] = Item.init(value: text!, description: nil)
        case 4:
            // Bezahlart
            tableDict![indexPath] = Item.init(value: text!, description: nil)
            
        default:
            // something went wrong but seems to be not possible
            return
        }
        
        // merching it directly into the billdata object
        bill?.merchChanges(tableDict: tableDict!)
        
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // we dont want the user to edit now.
//        if isDetail {return}
        
        
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let pickerView = storyboard?.instantiateViewController(withIdentifier: "TextPicker") as! TextPickerViewController
            pickerView.delegate = self
            pickerView.indexPath = indexPath
            
            pickerView.label = "Bitte gib den Rechnungsersteller ein."
            pickerView.textFieldString = (self.bill?.rechnungsersteller)!
            
            pickerView.modalPresentationStyle = .overCurrentContext
            print(bill?.rechnungsersteller)
            present(pickerView, animated: false, completion: nil)
            
        case 1:
            let pickerView = storyboard?.instantiateViewController(withIdentifier: "DatePicker") as! DatePickerViewController
            pickerView.delegate = self
            pickerView.indexPath = indexPath
            let datum = tableDict![indexPath] as! Item
            pickerView.date = datum.value
            pickerView.modalPresentationStyle = .overCurrentContext
            present(pickerView, animated: false, completion: nil)
            
            
        case 3:
            let pickerView = storyboard?.instantiateViewController(withIdentifier: "KontierungsPicker") as! ChooseKontierungViewController
            pickerView.modalPresentationStyle = .overCurrentContext
            pickerView.delegate = self
            let nvc = UINavigationController.init(rootViewController: pickerView)
            present(nvc, animated: true, completion: nil)
            
        case 4:
            let pickerView = storyboard?.instantiateViewController(withIdentifier: "Bezahlformen") as! BezahlformenPickerViewController
            pickerView.modalPresentationStyle = .overCurrentContext
            pickerView.delegate = self
            pickerView.indexPath = indexPath
            
            present(pickerView, animated: false, completion: nil)
            
        default:
            return
        }
    }
    
    
}
