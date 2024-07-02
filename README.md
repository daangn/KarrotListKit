# KarrotListKit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdaangn%2FKarrotListKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/daangn/KarrotListKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdaangn%2FKarrotListKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/daangn/KarrotListKit)

Welcome to our Karrot Listing Framework. This powerful tool is developed with UIKit, but it is designed to be used like a declarative UI API, providing a seamless transition to SwiftUI and reducing migration costs.

Our framework is built with an optimized diffing algorithm, thanks to its dependency on [DifferenceKit](https://github.com/ra1028/DifferenceKit). This ensures high performance and swift rendering of your lists, allowing your application to run smoothly, even when handling large changes of data.

The API is designed to be simple and intuitive, allowing for rapid development without sacrificing quality or functionality. This means you can spend less time wrestling with complex code and more time creating the perfect user experience.



## Installation

You can use The [Swift Package Manager](https://swift.org/package-manager/) to install this framework by following these steps:

1. Open up Xcode, and navigate to `Project` -> `Package dependencies` -> `Add Package Dependency (+)`.
1. In the search bar, enter the URL of this repository: `https://github.com/daangn/KarrotListKit`.
1. Specify the version you want to use. You can choose to use the latest version or a specific version.
1. Click `Next` and `Finish` to complete the installation. After the package is successfully added to your project, import the framework into the files where you want to use it:

```swift
import KarrotListKit
```

Now you're ready to start using the KarrotListKit Framework




## Getting Started
See the [KarrotListKit DocC documentation](https://swiftpackageindex.com/daangn/KarrotListKit/main/documentation/karrotlistkit) hosted on the [Swift Package Index](https://swiftpackageindex.com/).

### CollectionViewAdapter

The `CollectionViewAdapter` object serves as an adapter between the `UIColletionView` logic and the KarrotListKit logic, encapsulating the core implementation logic of the framework

```swift
private let configuration = CollectionViewAdapterConfiguration()
private let layoutAdapter = CollectionViewLayoutAdapter()

private lazy var collectionViewAdapter = CollectionViewAdapter(
  configuration: configuration,
  collectionView: collectionView,
  layoutAdapter: layoutAdapter
)

private lazy var collectionView = UICollectionView(
  frame: .zero,
  collectionViewLayout: UICollectionViewCompositionalLayout(
    sectionProvider: layoutAdapter.sectionLayout
  )
)
```



### Component

The Component is the smallest unit within the framework. 
It allows for the declarative representation of data and actions to be displayed on the screen. We no longer need to depend on `UICollectionViewCell` and `UICollectionReusableView`, can write component-based. 
The component has an interface very similar to `UIViewRepresentable`. This similarity allows us to reduce the cost of migrating to `SwiftUI` in the future.

```swift
struct ButtonComponent: Component {

  typealias Content = Button
  typealias ViewModel = Button.ViewModel
  typealias Coordinator = Void

  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  func renderContent(coordinator: Coordinator) -> Button {
    Button()
  }

  func render(in content: Button, coordinator: Coordinator) {
    content.configure(viewModel: viewModel)
  }

  var layoutMode: ContentLayoutMode {
    .flexibleHeight(estimatedHeight: 44.0)
  }
}
```



### Presentation

We represent the list UI using List / Section / Cell. Not only that, but we can also map actions and layouts using modifiers.

```swift
let list = List {
  Section(id: "Section1") {
    Cell(
      id: "Cell1",
      component: ButtonComponent(viewModel: .init(title: $0.rawValue))
    )
    Cell(
      id: "Cell2",
      component: ButtonComponent(viewModel: .init(title: $0.rawValue))
    )
    .didSelect { context in
      // handle selection
    }
    .willDisplay { context in
      // handle displaying
    }	
  }
  .withHeader(ButtonComponent(viewModel: .init(title: "Header")))
  .withFooter(ButtonComponent(viewModel: .init(title: "Footer")))
  .withSectionLayout(.vertical(spacing: 12.0))
}

collectionViewAdapter.apply(
  list,
  animatingDifferences: true
) {
  // after completion
}
```



### Sizing

The size of a View is actually adjusted when the View is displayed on the screen, and this can be adjusted through `sizeThatFits`. Until then, the component can represent its own size as an estimate.

```swift
struct ButtonComponent: Component {
  typealias Content = Button
  // ...
  var layoutMode: ContentLayoutMode {
    .flexibleHeight(estimatedHeight: 44.0)
  }
}

final class Button: UIControl {
  // ...
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    // return size of a Button
  }
}
```

SectionLayout is tightly coupled with `UICollectionViewCompositionalLayout`, providing a custom interface to return an `NSCollectionLayoutSection`.

```swift
Section(id: "Section1") {
  // ...
}
.withSectionLayout { [weak self] context -> NSCollectionLayoutSection? in
  // return NSCollectionLayoutSection object
}
```



### Prefetching

Provides prefetching of resources API to improve scroll performance.
The CollectionViewAdapter conforms to the `UICollectionViewDataSourcePrefetching`. The framework provides the `ComponentResourcePrefetchable` and `CollectionViewPrefetchingPlugin` protocols for compatibility.

Below is sample code for Image prefetching.

```swift
let collectionViewAdapter = CollectionViewAdapter(
  configuration: .init(),
  collectionView: collectionView,
  layoutAdapter: CollectionViewLayoutAdapter(),
  prefetchingPlugins: [
    RemoteImagePrefetchingPlugin(
      remoteImagePrefetcher: RemoteImagePrefetcher()
    )
  ]
)

extension ImagePrefetchableComponent: ComponentRemoteImagePrefetchable {
  var remoteImageURLs: [URL] {
    [
      URL(string: "imageURL"),
      URL(string: "imageURL"),
      URL(string: "imageURL")
    ]
  }
}
```



## Contributing

We warmly welcome and appreciate any contributions to this project!
Feel free to submit pull requests to enhance the functionalities of this project. 



## License

This project is licensed under the Apache License 2.0. See [LICENSE](https://github.com/daangn/KarrotListKit/blob/main/LICENSE) for details.

