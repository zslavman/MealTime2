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
    
    var conta:NSManagedObjectContext! // заряжается в классе AppDelegate
    
    lazy var context:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var instances: [Happydate] = [] // массив экземпляров Happydate из Core Data
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM.dd.yy - HH:mm:ss"
        return dateFormater
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // если не указывать ячейку на сторибоарде, то ее нужно указать так:
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        fetchData()
    }
        
    
    
    
    
    // Получение данных из Core Data
    func fetchData(){
        let fetch_Raquest: NSFetchRequest<Happydate> = Happydate.fetchRequest()
        
        // создадим дискриптор, который выведет отстортированные данные по полю fixationTime, по убыванию
        let sortDescriptor = NSSortDescriptor(key: "fixationTime", ascending: false)
        fetch_Raquest.sortDescriptors = [sortDescriptor]
        
        do {
            instances = try context.fetch(fetch_Raquest)
            // instances.sort(by: {$0.fixationTime < $1.fixationTime})
            // instances.sortInPlace({ $0.fixationTime($1) == ComparisonResult.OrderedAscending })
            tableView.reloadData()
            countTF.text = String(instances.count)
        }
        catch { print("Не удалось получить данные ") }
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Время когда я ел вкусняшки"
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")
        let dateToPrint:Happydate = instances[indexPath.row]
        cell?.textLabel!.text = dateFormatter.string(from: dateToPrint.fixationTime as! Date)
        return cell!
    }
    
    
    
    // нажали на "+"
    @IBAction func onAddClick(_ sender: UIBarButtonItem) {
        let date = Date() // запоминаем дату во время нажатия на "+"
        let inst: Happydate = Happydate(context: context)
        inst.fixationTime = date as NSDate
        instances.insert(inst, at: 0)
        
        countTF.text = String(instances.count)
        do {
            try context.save()
            tableView.reloadData()
        }
        catch { print("Не удалось сохранить данные") }
    }
    
    
    
    // нажали на "Очист."
    @IBAction func onDeleteClick(_ sender: UIBarButtonItem) {
        
        //        медленный способ
        //        let fetchRequest = NSFetchRequest<Happydate>(entityName: "Happydate")
        //        do {
        //            let items = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
        //
        //            for item in items {
        //                context.delete(item)
        //            }
        //            try context.save()
        //            tableView.reloadData()
        //        }
        //        catch { print("Не удалось сохранить данные") }
        
        
        // быстрый способ - очистка всего контекста
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Happydate")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
            
            instances.removeAll()
            countTF.text = String(instances.count)
            
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
        
        // УДАЛЕНИЕ ячейки
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") {
            (action, IndexPath) in
            
            // удаление с БД
            let objectToDelete = self.instances[indexPath.row]
            self.context.delete(objectToDelete)

            self.instances.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.countTF.text = String(self.instances.count)
            
            do {
                try self.context.save()
            }
            catch{
                print("После удаления не удалось сохранить т.к. \(error.localizedDescription)")
            }
        }
        return [deleteAction]
    }







}




























