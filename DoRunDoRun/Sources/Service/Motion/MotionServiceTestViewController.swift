//
//  MotionServiceTestViewController.swift
//  DoRunDoRun
//
//  Created by zaehorang on 9/20/25.
//

import UIKit
import CoreMotion

final class MotionServiceTestViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let statusLabel = UILabel()
    private let stepsLabel = UILabel()
    private let distanceLabel = UILabel()
    private let elapsedLabel = UILabel()
    private let avgPaceLabel = UILabel()

    private let startButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)

    // MARK: - Motion
    private let motionService: MotionServiceProtocol = MotionService()
    private var task: Task<Void, Never>?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MotionService Test"
        view.backgroundColor = .systemBackground
        setupUI()
        updateStatus("Idle")
        renderInitial()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopStreaming()
    }

    // MARK: - Actions
    @objc private func startTapped() {
        guard task == nil else { return }
        updateStatus("Starting…")

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try motionService.startTracking()
                await MainActor.run { self.updateStatus("Streaming…") }

                for try await data in stream {
                    let steps = data.numberOfSteps.intValue
                    let dist = data.distance?.doubleValue ?? 0
                    let elapsed = data.endDate.timeIntervalSince(data.startDate)
                    // s/m -> s/km
                    let avgPaceSecPerKm: Double? = {
                        guard let paceSecPerMeter = data.averageActivePace?.doubleValue, paceSecPerMeter > 0 else { return nil }
                        return paceSecPerMeter * 1_000
                    }()

                    await MainActor.run {
                        self.stepsLabel.text = "Steps: \(steps)"
                        self.distanceLabel.text = String(format: "Distance: %.2f m (%.2f km)", dist, dist/1000)
                        self.elapsedLabel.text = String(format: "Elapsed: %.0f s", elapsed)
                        if let pace = avgPaceSecPerKm {
                            self.avgPaceLabel.text = String(format: "Avg Pace: %.1f s/km (%.0f:%02.0f /km)", pace, floor(pace/60), floor(pace.truncatingRemainder(dividingBy: 60)))
                        } else {
                            self.avgPaceLabel.text = "Avg Pace: –"
                        }
                    }
                }

                await MainActor.run { self.updateStatus("Finished") }
            } catch let e as MotionServiceError {
                await MainActor.run {
                    self.updateStatus("Error: \(e.localizedDescription)")
                    self.presentAlert(title: "Motion Error", message: e.localizedDescription)
                }
            } catch {
                await MainActor.run {
                    self.updateStatus("Error: \(error.localizedDescription)")
                    self.presentAlert(title: "Error", message: error.localizedDescription)
                }
            }
            await MainActor.run { [weak self] in self?.task = nil }
        }
    }

    @objc private func stopTapped() { stopStreaming() }

    private func stopStreaming() {
        task?.cancel()
        task = nil
        motionService.stopTracking()
        updateStatus("Stopped")
        renderInitial() // 값 초기화
    }
}

// MARK: - UI Helpers
private extension MotionServiceTestViewController {
    func setupUI() {
        // Scroll + Stack
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        // Labels
        [statusLabel, stepsLabel, distanceLabel, elapsedLabel, avgPaceLabel].forEach {
            $0.numberOfLines = 0
            $0.font = .preferredFont(forTextStyle: .body)
            stackView.addArrangedSubview($0)
        }
        statusLabel.font = .preferredFont(forTextStyle: .headline)

        // Buttons
        startButton.setTitle("Start", for: .normal)
        stopButton.setTitle("Stop", for: .normal)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [startButton, stopButton])
        buttons.axis = .horizontal
        buttons.spacing = 16
        buttons.distribution = .fillProportionally
        stackView.addArrangedSubview(buttons)
    }

    func updateStatus(_ text: String) { statusLabel.text = "Status: \(text)" }

    func renderInitial() {
        stepsLabel.text = "Steps: 0"
        distanceLabel.text = "Distance: –"
        elapsedLabel.text = "Elapsed: –"
        avgPaceLabel.text = "Avg Pace: –"
    }

    func presentAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
