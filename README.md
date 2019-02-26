# GitHubApolloClient

GitHub API v4 (GraphQL) Client App

# How To Build

First, install apollo-tooling (apollo-cli).

```bash
$ yarn install
```

Install dependencies with Carthage.

```bash
$ carthage update --platform iOS
```

Edit source code below.

```swift
import UIKit
import Apollo

class ApolloClientViewController: UIViewController {
    
    static let githubToken = "<YOUR TOKEN HERE>"
    
    ...
    
}
```

Final, run Xcode.
