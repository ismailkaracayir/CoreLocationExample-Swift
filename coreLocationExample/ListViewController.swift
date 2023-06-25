//
//  ListViewController.swift
//  coreLocationExample
//
//  Created by ismail karaçayır on 23.06.2023.
//

import UIKit
import CoreData
class ListViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedName = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate  = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickBarButtonAdd))
        fetchToData()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchToData), name:NSNotification.Name("newLocation"), object: nil)
    }
   @objc func fetchToData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(request)
            if results.count > 0 {
                nameArray.removeAll(keepingCapacity: false)
                idArray.removeAll(keepingCapacity: false)
                for result in results as![NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String {
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                }
                tableView.reloadData()
            }
            
        }catch{
            print(" fetch to data error")
        }
        
    }
    @objc func clickBarButtonAdd(){
        selectedName = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    

   

}
extension ListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedId = idArray[indexPath.row]
        selectedName = nameArray[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.selectedId = selectedId
            destinationVC.selectedName = selectedName
        }
    }
    
   
    
    
}
