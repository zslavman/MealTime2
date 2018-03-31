//
//  ViewController.swift
//  MealTime
//
//  Created by zslavman on 25.03.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countTF: UILabel!
    
    var context:NSManagedObjectContext! // заряжается в классе AppDelegate

    var person:Person! // персона, к которой будут применены операции с приемом пищи, по сути, это и есть массив, в котором будут храниться все приемы пищи (экземпляры Meals)
    var personName = "Max"
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM.dd.yy - HH:mm:ss"
        return dateFormater
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // если не указывать ячейку непосредственно в сторибоарде, то ее нужно указать кодом:
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        fetchData()
    }
        
    
    
    
    
    // Получение данных из Core Data
    func fetchData(){

        // проверяем наличие значений(имен) Person в CoreData, если нету - создаем
        let fetch_Request:NSFetchRequest<Person> = Person.fetchRequest()
        fetch_Request.predicate = NSPredicate(format: "name == %@", personName)
        
        do {
            let results = try context.fetch(fetch_Request)
            if results.isEmpty {
                person = Person(context: context)// создаем экземляр класса Person и помещаем его в context
                person.name = personName
                try context.save()
            }
            else {
                person = results.first // здесь всегда будет единственное значение, т.к. имя человека должно быть уникальное
                let sortDescriptor = NSSortDescriptor(key: "date_eating", ascending: false)
                person.meals?.sortedArray(using: [sortDescriptor])
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Время когда я ел вкусняшки"
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let mealsCount = person.meals{
            countTF.text = String(mealsCount.count)
            return mealsCount.count
        }
        countTF.text = String(0)
        return 1
    }
        
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")
        // берем конкретный прием пищи и помещаем его в Meal (если таковой существует)
        guard let meal = person.meals?[indexPath.row] as? Meal, let mealDate = meal.date_eating as? Date
            else {
                return cell! // отображаем пустую ячейку
        }
                
        cell?.textLabel!.text = dateFormatter.string(from: mealDate)
        return cell!
    }
    
    
    
    // нажали на "+"
    @IBAction func onAddClick(_ sender: UIBarButtonItem) {
        
        // создаем новый экземпляр приема пищи и записываем в него текущую дату
        let meal = Meal(context: context)
        meal.date_eating = NSDate() // запоминаем дату во время нажатия на "+" в экземпляр
        
        let meals = person.meals?.mutableCopy() as? NSMutableOrderedSet // по умолчанию наш meals имеет тип NSOrderedSet с уже имеющимися значениями, и для его изменения нужно чтоб он был MutableOrderedSet
        meals?.insert(meal, at: 0) // записываем наш meal в новый meals (в начало коллекции)
        person.meals = meals // переопределяем имеющийся сэт новым сэтом, который только что создали скопировав наш старый сэт, добавив в него еще одно значение

        do {
            try context.save()
        }
        catch { print("Не удалось сохранить данные") }
        
        tableView.reloadData()
    }
    
    
    
    
    
    // нажали на "Очист."
    @IBAction func onDeleteClick(_ sender: UIBarButtonItem) {
        
        // очистка всего контекста
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
            
            person = nil
            person = Person(context: context)// создаем экземляр класса Person и помещаем его в context
            person.name = personName
        
            tableView.reloadData()
        }
        catch { print("Не удалось сохранить данные") }
    }
        
    
    
    
    
    // клик по ячейке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // убираем выделение ячейки
        tableView.deselectRow(at: indexPath, animated: true)
    }
        

    
    
    
    
    
    // добавляем фунуции к ячейке при свайпе влево
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // получаем экземпляр, который хотим удалить
        let objectToDelete = person.meals?[indexPath.row] as? Meal

        // УДАЛЕНИЕ ячейки
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") {
            (action, IndexPath) in
            
            // удаление с БД
            self.context.delete(objectToDelete!)
            
            do {
                try self.context.save()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            catch{
                print("После удаления не удалось сохранить т.к. \(error.localizedDescription)")
            }
        }
        return [deleteAction]
    }







}




























