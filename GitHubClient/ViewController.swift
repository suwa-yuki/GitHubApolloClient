//
//  ViewController.swift
//  GitHubClient
//
//  Created by suwa.yuki on 2/14/19.
//  Copyright © 2019 suwa.yuki. All rights reserved.
//

import UIKit
import Apollo

class ApolloClientViewController: UIViewController {
    
    static let githubToken = "<YOUR TOKEN HERE>"
    
    let apollo: ApolloClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(ApolloClientViewController.githubToken)"]
        let url = URL(string: "https://api.github.com/graphql")!
        return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
    }()
    
}

class ViewController: ApolloClientViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        apollo.fetch(query: ShowViewerQuery()) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if let viewer = result?.data?.viewer {
                strongSelf.nameLabel.text = viewer.name
                print(viewer.id)
                do {
                    let url = URL(string: viewer.avatarUrl)!
                    let data = try Data(contentsOf: url)
                    strongSelf.imageView.image = UIImage(data: data)!
                } catch {
                    print(error)
                }
            }
        }
    }

}

class ProjectsViewController: ApolloClientViewController, UITableViewDataSource, CreateProjectViewControllerDelegate {
    
    var projects: [String?]?
    var ownerId: GraphQLID?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
    
    func fetch() {
        apollo.fetch(query: ShowViewerQuery(), cachePolicy: .fetchIgnoringCacheData) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if let viewer = result?.data?.viewer {
                let nodes = viewer.projects.nodes?.map({ (node) -> String? in
                    return node?.name
                })
                strongSelf.ownerId = viewer.id
                strongSelf.projects = nodes
                strongSelf.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.selectionStyle = .none
        let item = projects?[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? CreateProjectViewController {
            viewController.delegate = self
            viewController.ownerId = ownerId
        }
    }
    
    func createProjectDidFinish() {
        navigationController?.popViewController(animated: true)
        fetch()
    }
    
}

class CreateProjectViewController: ApolloClientViewController {
    
    var ownerId: GraphQLID!
    var delegate: CreateProjectViewControllerDelegate?
    
    @IBOutlet weak var projectNameTextField: UITextField!
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        let input = CreateProjectMutation(ownerId: ownerId, name: projectNameTextField.text ?? "")
        apollo.perform(mutation: input) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print(error)
            } else {
                strongSelf.delegate?.createProjectDidFinish()
            }
        }
    }
}

protocol CreateProjectViewControllerDelegate {
    
    func createProjectDidFinish()
    
}
