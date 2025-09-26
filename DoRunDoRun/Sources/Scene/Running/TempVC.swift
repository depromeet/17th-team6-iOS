//
//  TempVC.swift
//  DoRunDoRun
//
//  Created by Inho Choi on 9/23/25.
//

import NMapsMap
import UIKit

final class TempVC: UIViewController {
    private let map: NMFMapView = {
        let view = NMFMapView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(map)

        NSLayoutConstraint.activate([
            map.topAnchor.constraint(equalTo: view.topAnchor),
            map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
