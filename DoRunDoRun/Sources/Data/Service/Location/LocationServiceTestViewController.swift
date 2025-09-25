//
//  LocationServiceTestViewController.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/21/25.
//

import CoreLocation
import UIKit

final class LocationServiceTestViewController: UIViewController {
    private let locationService = LocationService()
    private var streamTask: Task<Void, Never>?
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let startButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Start", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let stopButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Stop", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(textView)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            stopButton.topAnchor.constraint(equalTo: startButton.topAnchor),
            stopButton.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 16),
            
            textView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
    }
    
    @objc private func startTapped() {
        do {
            let stream = try locationService.startTracking()
            streamTask = Task {
                do {
                    for try await location in stream {
                        let coord = location.coordinate
                        await MainActor.run {
                            self.textView.text.append("lat: \(coord.latitude), lon: \(coord.longitude)\n")
                            let bottom = NSRange(location: self.textView.text.count - 1, length: 1)
                            self.textView.scrollRangeToVisible(bottom)
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.textView.text.append("Error: \(error)\n")
                    }
                }
            }
        } catch {
            textView.text.append("Failed to start tracking: \(error)\n")
        }
    }
    
    @objc private func stopTapped() {
        locationService.stopTracking()
        streamTask = nil
        textView.text.append("\n--- Stopped ---\n")
    }
}
