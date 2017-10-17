//
//  ViewController.swift
//  WorldTweets
//
//  Created by David Marmoy on 10/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

//
//  ViewController.swift
//  ProtocolOrientedProgramming
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import UIKit
import MapKit

class WTMapViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var worldTweetsMapView: MKMapView!
    @IBOutlet weak var verticalKeyboardOffsetLayoutConstraint: NSLayoutConstraint!

    private let annotationViewReuseIdentifier = "statusPin"
    var tweetSource = WTTweetSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotifications()
        searchBar.delegate = self

        worldTweetsMapView.delegate = self
        worldTweetsMapView.mapType = .satellite
        worldTweetsMapView.visibleMapRect = MKMapRectWorld

        // Ensure that we are notified when the user returns to the app after being sent to Settings to fix their account setup.
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteringForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getTweets()
    }

    /**
     Starts the streaming based on the supplied @queryText.
     
     - parameter queryText: The text to filter the stream by
     */
    private func getTweets(with keyword: String? = nil) {
        tweetSource.openStream(with: keyword, resultHandler: process)
    }

    /**
     Handles cases where the user has left the app to fix an error with their social accounts and return to the app afterwards
     */
    @objc private func appEnteringForeground() {
        getTweets(with: searchBar.text)
    }
}

// MARK: UISearchBarDelegate
extension WTMapViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        getTweets(with: searchBar.text)
        filter(annotations: worldTweetsMapView.annotations, on: worldTweetsMapView, with: searchBar.text)
    }

    /**
     Hides annotations whose titles don't contain the search query
     Shows annotations whose titles contain the search query
     
     - parameter annotations: The annotations to filter
     - parameter mapView: The mapView on which to filter the annotations
     - parameter query: The query to match on
     */
    func filter(annotations: [MKAnnotation], on mapView: MKMapView, with query: String?) {
        for annotation in annotations {
            let annotationTitle = (annotation.title ?? "") ?? ""
            if let query = query, !query.isEmpty {

                mapView.view(for: annotation)?.isHidden = !annotationTitle.contains(query)
            } else {
                mapView.view(for: annotation)?.isHidden = false
            }
        }
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

extension WTMapViewController: WTSink {
    /**
     Processes the result coming from the stream.
     - parameter result: The result coming from the stream. If success, result contains an array of tweets, otherwise it contains an error
     */
    func process(result: Result<[WTTweet]>) {
        guard let tweets = result.value else {
            handleError(error: result.error)
            return
        }

        let annotations = tweets.flatMap { $0.annotation }

        DispatchQueue.main.async {
            self.worldTweetsMapView.addAnnotations(annotations)
        }

        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + WTConfiguration.annotationLifeSpanInSeconds), execute: {
            self.worldTweetsMapView.removeAnnotations(annotations)
        })
    }

    /**
     Determines what to do with an error and does it. Options are to present the error to the user with or without a recovery option. If there is an option for the user to recover, this method attempts to help them
     - parameter error: The error to handle
     */
    func handleError(error: Error?) {
        let errorPrompt = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .alert)

        if let error = error as? RecoverableError, error.isRecoverable {
            let recoverAction = UIAlertAction(title: error.recoverySuggestion, style: .default, handler: { (_) in
                error.recover()
            })
            errorPrompt.addAction(recoverAction)
        } else {
            let acceptAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                self.getTweets(with: self.searchBar.text)
            }
            errorPrompt.addAction(acceptAction)
        }
        present(errorPrompt, animated: true)
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

    /**
     Hides the keyboard when the user touches anywhere outside the keyboard.
     Replace if the UI is changed to include more text fields/views in the future
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}
