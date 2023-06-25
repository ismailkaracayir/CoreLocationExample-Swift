//
//  ViewController.swift
//  coreLocationExample
//
//  Created by ismail karaçayır on 22.06.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class MapsViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapKİt: MKMapView!
    var locationmaneger = CLLocationManager()
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var selectLatitude = Double()
    var selectLongutude = Double()
    var selectedName = ""
    var selectedId : UUID?
    var annotationTitle = ""
    var annotationSubTitle = ""
    var annonationLatitute = Double()
    var annonationLongutude = Double()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKİt.delegate = self
        locationmaneger.delegate = self
        locationmaneger.desiredAccuracy = kCLLocationAccuracyBest
        locationmaneger.requestWhenInUseAuthorization()
        locationmaneger.startUpdatingLocation()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(locationSet(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 2
        mapKİt.addGestureRecognizer(gestureRecognizer)
        if selectedName != ""{
            if let uuidString = selectedId?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let Fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                Fetchrequest.predicate = NSPredicate(format: "id = %@", uuidString)
                Fetchrequest.returnsObjectsAsFaults = false
                do{
                    let results = try context.fetch(Fetchrequest)
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String,let subtitle = result.value(forKey: "note") as? String,let latitude = result.value(forKey: "latitude") as? Double,let longitude = result.value(forKey: "longitude") as? Double{
                            annotationTitle = name
                            annotationSubTitle = subtitle
                            annonationLatitute = latitude
                            annonationLongutude = longitude
                            let  annotation = MKPointAnnotation()
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubTitle
                            let cordinate = CLLocationCoordinate2D(latitude: annonationLatitute, longitude: annonationLongutude)
                            annotation.coordinate = cordinate
                            mapKİt.addAnnotation(annotation)
                            nameTextField.text = annotationTitle
                            noteTextField.text = annotationSubTitle
                            locationmaneger.stopUpdatingLocation()
                            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            let region = MKCoordinateRegion(center: cordinate, span: span)
                            mapKİt.setRegion(region, animated: true)

                        }
                    }
                }catch{
                    print("mapview fetchrequest error")
                }
                
            }
            
        }else{
            
        }
    }
    
    @objc func locationSet(gestureRecognizer : UILongPressGestureRecognizer ){
        if gestureRecognizer.state == .began{
            let contactPoint = gestureRecognizer.location(in: mapKİt)
            let contactLocation = mapKİt.convert(contactPoint, toCoordinateFrom: mapKİt)
            let anatation = MKPointAnnotation()
            selectLatitude = contactLocation.latitude
            selectLongutude = contactLocation.longitude
            anatation.coordinate = contactLocation
            if let name = nameTextField.text , let note = noteTextField.text{
                anatation.title = name
                anatation.subtitle = note
            }
            mapKİt.addAnnotation(anatation)
            
            

        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedName == ""{
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude:locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapKİt.setRegion(region, animated: true)
        }
        

    }
    

    @IBAction func saveLocation(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        if let name = nameTextField.text ,let note = noteTextField.text  {
            newLocation.setValue(name, forKey: "name")
            newLocation.setValue(note, forKey: "note")
            newLocation.setValue(selectLatitude, forKey: "latitude")
            newLocation.setValue(selectLongutude, forKey: "longitude")
            newLocation.setValue(UUID(), forKey: "id")
            
        }
        do{
            try context.save()
            print("Coredate Save success")

        }catch{
            print("Coredate Save Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newLocation"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
}

