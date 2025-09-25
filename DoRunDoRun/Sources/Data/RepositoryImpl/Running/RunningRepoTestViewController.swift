//
//  RunningRepoTestViewController.swift
//
//
//  Created by zaehorang on 9/26/25.
//


import UIKit

final class RunningRepoTestViewController: UIViewController {
    
    // MARK: - UI
    private let textView = UITextView()
    private let startButton  = UIButton(type: .system)
    private let pauseButton  = UIButton(type: .system)
    private let resumeButton = UIButton(type: .system)
    private let stopButton   = UIButton(type: .system)
    private let clearButton  = UIButton(type: .system)
    
    // MARK: - Dependencies
    // 필요 시 DI로 바꿔도 됩니다.
    private let repo: RunningRepositoryProtocol = MockRunningRepository()
    
    // MARK: - State
    private var streamTask: Task<Void, Never>?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Running Mock Stream"
        view.backgroundColor = .systemBackground
        setupUI()
        wireActions()
    }
    
    deinit {
        streamTask?.cancel()
        // actor/서비스 정리 필요 시:
        // await repo.stopRun() 형태로 정리 (현재 Mock은 class라 아래처럼 동기 호출)
        // repo.stopRun()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 버튼 바
        let bar = UIStackView(arrangedSubviews: [
            startButton, pauseButton, resumeButton, stopButton, clearButton
        ])
        bar.axis = .horizontal
        bar.alignment = .fill
        bar.distribution = .fillEqually
        bar.spacing = 8
        
        startButton.setTitle("Start", for: .normal)
        pauseButton.setTitle("Pause", for: .normal)
        resumeButton.setTitle("Resume", for: .normal)
        stopButton.setTitle("Stop", for: .normal)
        clearButton.setTitle("Clear", for: .normal)
        
        // 텍스트뷰
        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let root = UIStackView(arrangedSubviews: [bar, textView])
        root.axis = .vertical
        root.spacing = 8
        root.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            root.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            root.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            bar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func wireActions() {
        startButton.addTarget(self, action: #selector(tapStart), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(tapPause), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(tapResume), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(tapStop), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(tapClear), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func tapStart() {
        streamTask?.cancel()
        streamTask = Task { [weak self] in
            guard let self else { return }
            do {
                let stream = try await self.repo.startRun()
                await MainActor.run { self.appendLine("▶️ START STREAM") }

                var count = 0
                for try await snap in stream {
                    count += 1
                    await MainActor.run { self.appendSnapshot(snap, index: count) }
                }

                await MainActor.run { self.appendLine("⏹️ STREAM ENDED") }
            } catch is CancellationError {
                await MainActor.run { self.appendLine("🛑 STREAM CANCELLED") }
            } catch {
                await MainActor.run { self.appendLine("❌ ERROR: \(error)") }
            }
        }
    }

    @objc private func tapPause() {
        Task { [weak self] in
            guard let self else { return }
            await self.repo.pause()
            await MainActor.run { self.appendLine("⏸️ PAUSE") }
        }
    }

    @objc private func tapResume() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.repo.resume()
                await MainActor.run { self.appendLine("▶️ RESUME") }
            } catch {
                await MainActor.run { self.appendLine("❌ RESUME ERROR: \(error)") }
            }
        }
    }

    @objc private func tapStop() {
        Task { [weak self] in
            guard let self else { return }
            await self.repo.stopRun()
            self.streamTask?.cancel()
            await MainActor.run { self.appendLine("⏹️ STOP") }
        }
    }
    
    @objc private func tapClear() {
        textView.text = ""
    }
    
    // MARK: - Rendering
    private func appendSnapshot(_ s: RunningSnapshot, index: Int) {
        let ts = iso8601(s.timestamp)
        let km = s.metrics.totalDistanceMeters / 1000.0
        let dist = String(format: "%.3f km", km)
        
        let totalTimeText: String = {
            let totalSeconds = Int(s.metrics.elapsed.components.seconds)
            let hh = totalSeconds / 3600
            let mm = (totalSeconds % 3600) / 60
            let ss = totalSeconds % 60
            return String(format: "%02d:%02d:%02d", hh, mm, ss)
        }()
        
        let paceText: String = {
            let pace = s.metrics.avgPaceSecPerKm
            let m = Int(pace) / 60
            let s = Int(pace) % 60
            return String(format: "%d'%02d''", m, s)
        }()
        
        let cadence = String(format: "%.0f spm", s.metrics.cadenceSpm)
        let lat = s.lastPoint?.coordinate.latitude
        let lon = s.lastPoint?.coordinate.longitude
        
        let locText: String = {
            if let lat, let lon {
                return String(format: "(%.6f, %.6f)", lat, lon)
            } else {
                return "(—, —)"
            }
        }()
        
        appendLine("""
            [\(index)] \(ts)
              dist: \(dist)
              time: \(totalTimeText)
              pace: \(paceText)
              cadence: \(cadence)
              loc: \(locText)
            """)
    }
    
    private func appendLine(_ line: String) {
        textView.text.append(contentsOf: (textView.text.isEmpty ? "" : "\n") + line)
        // 맨 아래로 스크롤
        let range = NSRange(location: (textView.text as NSString).length - 1, length: 1)
        textView.scrollRangeToVisible(range)
    }
    
    // MARK: - Utils
    private func iso8601(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: date)
    }
}
