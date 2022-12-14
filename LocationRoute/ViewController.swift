//
//  ViewController.swift
//  LocationRoute
//
//  Created by Artyom Potapov on 06.11.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    lazy var setNewAddressButton: UIButton = setButton(systemName: "plus.square.fill.on.square.fill", isHidden: false)
    
    lazy var buildRouteButton: UIButton = setButton(systemName: "arrowshape.bounce.forward.fill")
    
    lazy var deleteAllAddressesButton: UIButton = setButton(systemName: "multiply.square.fill")
    
    var annotationArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        mapView.delegate = self
        setConstraints()
        addTargetsToButtons()
    }

    func setButton(systemName: String, isHidden: Bool = true) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 35)
        button.tintColor = UIColor(named: "darkRed")
        button.setImage(UIImage(systemName: systemName, withConfiguration: imageConfig ), for: .normal)
        button.isHidden = isHidden
        return button
    }
    
    func setViews(){
        view.addSubview(mapView)
        mapView.addSubview(setNewAddressButton)
        mapView.addSubview(buildRouteButton)
        mapView.addSubview(deleteAllAddressesButton)
    }
    
    func addTargetsToButtons(){
        setNewAddressButton.addTarget(self, action: #selector(setNewAddressButtonTapped), for: .touchUpInside)
        buildRouteButton.addTarget(self, action: #selector(buildRouteButtonTapped), for: .touchUpInside)
        deleteAllAddressesButton.addTarget(self, action: #selector(deleteAllAddressButtonTapped), for: .touchUpInside)
    }
    
    @objc func setNewAddressButtonTapped(){
        addAddressAlert(title: "?????????? ??????????", placeholder: "?????????????? ??????????") { address in
            self.setPlacemark(address: address)
        }
    }
    
    @objc func buildRouteButtonTapped(){
        for i in 0...annotationArray.count-2 {
            createDirectionRequest(firstCoordinate: annotationArray[i].coordinate, secondCoordinate: annotationArray[i+1].coordinate)
        }
    }
    
    @objc func deleteAllAddressButtonTapped(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationArray = []
        buildRouteButton.isHidden = true
        deleteAllAddressesButton.isHidden = true
    }
    
    func setConstraints(){
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            setNewAddressButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 20),
            setNewAddressButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            setNewAddressButton.heightAnchor.constraint(equalToConstant: 50),
            setNewAddressButton.widthAnchor.constraint(equalToConstant: 50),
            
            buildRouteButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 90),
            buildRouteButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            buildRouteButton.heightAnchor.constraint(equalToConstant: 50),
            buildRouteButton.widthAnchor.constraint(equalToConstant: 50),
            
            deleteAllAddressesButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 160),
            deleteAllAddressesButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            deleteAllAddressesButton.heightAnchor.constraint(equalToConstant: 50),
            deleteAllAddressesButton.widthAnchor.constraint(equalToConstant: 50)
            
        ])
    }

    private func setPlacemark(address: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { [self] placemarks, error in
            if let error = error {
                print(error)
                showErrorAlert(title: "????????????", message: "???????????? ????????????????????")
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let  annotation = MKPointAnnotation()
            annotation.title = "\(address)"
            guard let placemarkLocation = placemark.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            annotationArray.append(annotation)
            
            if annotationArray.count > 2 {
                buildRouteButton.isHidden = false
                deleteAllAddressesButton.isHidden = false
            }
            
            mapView.showAnnotations(annotationArray, animated: false)
            
        }
    }
    func createDirectionRequest(firstCoordinate: CLLocationCoordinate2D,
                                secondCoordinate: CLLocationCoordinate2D){
        
        let firstCoordinate = MKPlacemark(coordinate: firstCoordinate)
        let secondCoordinate = MKPlacemark(coordinate: secondCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: firstCoordinate)
        request.destination = MKMapItem(placemark: secondCoordinate)
        request.transportType = .walking
        request.requestsAlternateRoutes = true

        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showErrorAlert(title: "???????????? ????????????????", message: "?????????????? ???????????? ????????????")
                return
            }
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
        }
        
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .systemRed
        return renderer
    }
}
