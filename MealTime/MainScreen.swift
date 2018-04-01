//
//  MainScreen.swift
//  MealTime2
//
//  Created by Viacheslav on 31.03.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import CoreData

class MainScreen: UITableViewController {

    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var eaterName:String = ""
    var eaters: [Person] = []
    let favColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = favColor

        // Получение данных из Core Data
        let fetch_Request:NSFetchRequest<Person> = Person.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetch_Request.sortDescriptors = [sortDescriptor]
        
        do {
            eaters = try context.fetch(fetch_Request)
            tableView.reloadData()
        }
        catch { print("Не удалось получить данные ") }
    }
        
    
    
   
    
    // заглавье для таблицы
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Пациенты:"
    }
    // задаем цвет фона заглавья таблицы
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
         (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = #colorLiteral(red: 0.790307343, green: 0.8363640904, blue: 1, alpha: 1)
    }

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eaters.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fCell")
        let eaterToShow = eaters[indexPath.row]
        
        //обращаемся к текстовым лейблам кастомной ячейки чере tag'и
        let label_1 = cell?.viewWithTag(1) as! UILabel
        let label_2 = cell?.viewWithTag(2) as! UILabel
       
        label_1.text = eaterToShow.name           // Имя Фамилия
        
        if eaterToShow.meals != nil{
            if eaterToShow.meals!.count == 0{
                label_2.text = ""
            }
            else{
                label_2.text = String(eaterToShow.meals!.count)
            }
        }
        else{
             label_2.text = ""
        }
        
        //задаем цвет выделения ячейки при клике на нее
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(0.5)
        cell?.selectedBackgroundView = backgroundView
        
        tableView.separatorColor = favColor

        // делаем ячейки прозрачного цвета
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
    
    
    
    
    // кликнули на "+"
    @IBAction func onPlusClick(_ sender: UIBarButtonItem) {
        
        
        let alertController = UIAlertController(title: "Новый пациент", message: "Введите имя и фамилию пациента", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) {
            (action) in
            let textField = alertController.textFields?[0]
            self.addPatient(textField!.text!)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        
        alertController.addTextField {
            textField in
//            textField.keyboardType = .alphabet // определяем тип клавиатуры который нам нужен
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
   
    
    
    
    func addPatient(_ patName:String){
        // проверить есть ли экземпляры класса Person c именем patName
        for each_eater in eaters{
            if each_eater.name == patName {
                return
            }
        }
        
        let instance: Person = Person(context: context)
        instance.creationDate = NSDate() // запоминаем дату во время нажатия на "+" в экземпляр
        instance.name = patName
        eaters.append(instance)
        
        do {
            try context.save()
            tableView.reloadData()
        }
        catch { print("Не удалось сохранить данные") }
    }
    
    
    
    // кликнули на ячейку с именем едока
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // если осуществляем переход по сегвею с названием detailSegue
        if segue.identifier == "concreteEater"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationVievController = segue.destination as! ViewController
                
                destinationVievController.personName = eaters[indexPath.row].name!
                tableView.deselectRow(at: indexPath, animated: true) // убирем выделение
            }
        }
    }
    
    
    
    
    
    
    // добавляем фунуции к ячейке при свайпе влево
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // получаем экземпляр, который хотим удалить
        let objectToDelete = eaters[indexPath.row]
        
        // УДАЛЕНИЕ ячейки
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") {
            (action, IndexPath) in

            // удаляем с таблицы
            self.eaters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // удаляем с кордаты
            do {
                self.context.delete(objectToDelete)
                try self.context.save()
            }
            catch{
                print("После удаления не удалось сохранить т.к. \(error.localizedDescription)")
            }
        }
        
        // РЕДАКТИР. ячейки
        let editAction = UITableViewRowAction(style: .default, title: "Редакт.") {
            (action, IndexPath) in
        
            let ac = UIAlertController(title: "Редактирование", message: "Доступно в будущих обновлениях", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            ac.addAction(ok)
            self.present(ac, animated: true, completion: nil)
        }
        
        editAction.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 0.8554148707)
        deleteAction.backgroundColor = #colorLiteral(red: 0.9610336423, green: 0.2900479734, blue: 0.2988267541, alpha: 0.8554148707)
        
        return [deleteAction, editAction]
    }
    
    
    
    // клик по ячейке
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // убираем выделение ячейки
        tableView.deselectRow(at: indexPath, animated: true)
    }
    



}

































