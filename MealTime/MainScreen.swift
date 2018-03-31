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
    var count:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.tableHeaderView?.backgroundColor = .clear

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
        return "Пожиратели пищи:"
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
        cell?.textLabel?.text = eaterToShow.name
        
        //задаем цвет выделения ячейки при клике на нее
        let backgroundView = UIView()
        backgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        cell?.selectedBackgroundView = backgroundView
        
        tableView.separatorColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        
        cell?.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)

        
        // делаем ячейки прозрачного цвета
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
    
    
    
    
    // кликнули на "+"
    @IBAction func onPlusClick(_ sender: UIBarButtonItem) {
        
        let instance: Person = Person(context: context)
        instance.creationDate = NSDate() // запоминаем дату во время нажатия на "+" в экземпляр
        instance.name = "Вася\(count)"
        count += 1
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
        return [deleteAction]
    }
    
    
    
    // клик по ячейке
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // убираем выделение ячейки
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    


}

































