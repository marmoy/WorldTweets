//
//  ViewController.swift
//  WorldTweets
//
//  Created by David Marmoy on 10/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import UIKit
import MapKit

final class WTMapViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var worldTweetsMapView: MKMapView!
    @IBOutlet weak var verticalKeyboardOffsetLayoutConstraint: NSLayoutConstraint!

    private let annotationViewReuseIdentifier = "statusPin"

    private var streamingManager: WTStreamingManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotifications()
        searchBar.delegate = self

        worldTweetsMapView.delegate = self
        worldTweetsMapView.mapType = .satellite
        worldTweetsMapView.visibleMapRect = MKMapRectWorld

        // carriage return "\r\n" separates the statuses in the stream
        let parser = WTStatusParser(separator: "\r\n".data(using: .utf8)!)

        streamingManager = WTStreamingManager(parser: parser )
        streamingManager?.responseDelegate = self

        // Ensure that we are notified when the user returns to the app after being sent to Settings to fix their account setup
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteringForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beginStreamingStatuses()
    }

    /**
         Starts the streaming based on the supplied @queryText.
     
         - parameter queryText: The text to filter the stream by
     */
    private func beginStreamingStatuses(with queryText: String? = nil) {
        let streamingService: WTTwitterStreamService = queryText?.isEmpty ?? true ? .samples : .filter(track: queryText!)
        streamingManager?.beginStreaming(from: streamingService, errorHandler: handleStreamConnectionError)
    }

    /**
         Handles cases where the user has left the app to fix an error with their social accounts and return to the app afterwards
     */
    @objc private func appEnteringForeground() {
        beginStreamingStatuses(with: searchBar.text)
    }

    /**
         Handles stream startup error, either by informing the user, or by logging the error
     
         - parameter error: The error to be handled
     */
    private func handleStreamConnectionError(error: StreamingStartupError) {
        guard error == StreamingStartupError.accountAccessRejected || error == StreamingStartupError.noAccountsExist else {
            print(error.localizedDescription)
            return
        }

        let errorAlert = UIAlertController(title: error.description, message: nil, preferredStyle: .alert)

        let repeatAccountAccessPromptAction = UIAlertAction(title: NSLocalizedString("LetsFixIt", comment: ""), style: .default, handler: { (_) in
            if error == .accountAccessRejected {
                UIApplication.shared.open(URL(string: "App-Prefs:root=Privacy&path=TWITTER")!, options: [:])
            } else if error == .noAccountsExist {
                UIApplication.shared.open(URL(string: "App-Prefs:root=TWITTER")!, options: [:])
            }
        })

        errorAlert.addAction(repeatAccountAccessPromptAction)

        present(errorAlert, animated: true)
    }
}

// MARK: StatusResponseDelegate
extension WTMapViewController: WTStatusResponseDelegate {

    /**
         Schedules adding and removing annotations on the mapView
     
         - parameter statuses: The statuses to be placed on the map
     */
    func statusesReceived(statuses: [WTStatus]) {
        let annotations = statuses.flatMap { WTStatusViewModel(status: $0)?.annotation }

        DispatchQueue.main.async {
            self.worldTweetsMapView.addAnnotations(annotations)
        }

        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + WTConfiguration.annotationLifeSpanInSeconds), execute: {
            self.worldTweetsMapView.removeAnnotations(annotations)
        })
    }
}

// MARK: UISearchBarDelegate
extension WTMapViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        beginStreamingStatuses(with: searchBar.text)
    }
}

// MARK: MapViewDelegate
extension WTMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewReuseIdentifier) as? MKPinAnnotationView {
            return annotationView
        }

        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewReuseIdentifier)
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        return annotationView
    }
}

// MARK: Keyboard handling
extension WTMapViewController {
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(WTMapViewController.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WTMapViewController.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return }
        keyboardHeightWillUpdate(newKeyboardHeight: keyboardHeight)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeightWillUpdate(newKeyboardHeight: 0)
    }

    /**
         Animates resizing of the UI to follow the keyboard
     
         - parameter newKeyBoardHeight: The keyboard height to accommodate
         - parameter keyboardAnimationDuration: The duration of the resize animation. Default is 0.3 to match the keyboard animation duration
     */
    private func keyboardHeightWillUpdate(newKeyboardHeight: CGFloat, keyboardAnimationDuration: TimeInterval = 0.3) {
        verticalKeyboardOffsetLayoutConstraint.constant = newKeyboardHeight
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
