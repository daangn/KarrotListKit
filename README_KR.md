# KarrotListKit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdaangn%2FKarrotListKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/daangn/KarrotListKit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fdaangn%2FKarrotListKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/daangn/KarrotListKit)

당근 리스트 프레임워크에 오신 것을 환영합니다. 이 강력한 도구는 UIKit으로 개발되었지만, 선언적 UI API처럼 사용할 수 있도록 설계되어 SwiftUI로의 원활한 전환과 마이그레이션 비용 절감을 제공합니다.

우리 프레임워크는 [DifferenceKit](https://github.com/ra1028/DifferenceKit)에 의존하여 최적화된 차이 비교 알고리즘으로 구축되었습니다. 이를 통해 높은 성능과 빠른 리스트 렌더링을 보장하여, 대량의 데이터 변경을 처리할 때도 애플리케이션이 부드럽게 실행됩니다.

API는 간단하고 직관적으로 설계되어 품질이나 기능을 희생하지 않으면서도 빠른 개발을 가능하게 합니다. 이는 복잡한 코드와 씨름하는 시간을 줄이고 완벽한 사용자 경험을 만드는 데 더 많은 시간을 할애할 수 있음을 의미합니다.



## 설치

[Swift Package Manager](https://swift.org/package-manager/)를 사용하여 다음 단계를 따라 이 프레임워크를 설치할 수 있습니다:

1. Xcode를 열고 `Project` -> `Package dependencies` -> `Add Package Dependency (+)`로 이동합니다.
1. 검색 바에 이 저장소의 URL을 입력합니다: `https://github.com/daangn/KarrotListKit`.
1. 사용하려는 버전을 지정합니다. 최신 버전 또는 특정 버전을 선택할 수 있습니다.
1. `Next`와 `Finish`를 클릭하여 설치를 완료합니다. 패키지가 프로젝트에 성공적으로 추가된 후, 사용하려는 파일에 프레임워크를 import합니다:

```swift
import KarrotListKit
```

이제 KarrotListKit 프레임워크를 사용할 준비가 되었습니다.



## 시작하기
[Swift Package Index](https://swiftpackageindex.com/)에서 호스팅되는 [KarrotListKit DocC 문서](https://swiftpackageindex.com/daangn/KarrotListKit/main/documentation/karrotlistkit)를 참조하세요.

### CollectionViewAdapter

`CollectionViewAdapter` 객체는 `UIColletionView` 로직과 KarrotListKit 로직 사이의 어댑터 역할을 하며, 프레임워크의 핵심 구현 로직을 캡슐화합니다.

```swift
private lazy var collectionView = UICollectionView(
  frame: .zero,
  collectionViewLayout: UICollectionViewCompositionalLayout(
    sectionProvider: collectionViewAdapter.sectionLayout
  )
)

private let collectionViewAdapter = CollectionViewAdapter<CompositionalLayout>(
  configuration: CollectionViewAdapterConfiguration()
)

override func viewDidLoad() {
  super.viewDidLoad()
  
  // 어뎁터에 컬렉션 뷰를 등록합니다.
  collectionViewAdapter.register(collectionView: collectionView)
}
```



### Component

Component는 프레임워크 내에서 가장 작은 단위입니다.
화면에 표시될 데이터와 액션을 선언적으로 표현할 수 있게 해줍니다. 더 이상 `UICollectionViewCell`과 `UICollectionReusableView`에 의존하지 않고 컴포넌트 기반으로 작성할 수 있습니다.
이 컴포넌트는 `UIViewRepresentable`과 매우 유사한 인터페이스를 가지고 있습니다. 이러한 유사성을 통해 향후 `SwiftUI`로 마이그레이션하는 비용을 줄일 수 있습니다.

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
}
```



### 표현

List / Section / Cell을 사용하여 리스트 UI를 표현합니다. 뿐만 아니라 수정자를 사용하여 액션과 레이아웃을 매핑할 수도 있습니다.

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
      // 선택 처리
    }
    .willDisplay { context in
      // 표시 처리
    }
  }
  .withHeader(ButtonComponent(viewModel: .init(title: "Header")))
  .withFooter(ButtonComponent(viewModel: .init(title: "Footer")))
  .withSectionLayout { context in
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44.0)
    )
    let item = NSCollectionLayoutItem(
      layoutSize: size
    )
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: size,
      subitems: [item]
    )
    return NSCollectionLayoutSection(group: group)
  }
}

collectionViewAdapter.apply(
  list,
  updateStrategy: .animatedBatchUpdates  // 기본값은 animatedBatchUpdates입니다
) {
  // 완료 후 처리
}
```

첫 번째 매개변수인 `list`는 UICollectionView에 표시될 섹션, 셀 및 해당 컴포넌트를 정의하는 새로운 List 구조를 나타냅니다.

두 번째 매개변수인 `updateStrategy`는 `CollectionViewAdapterUpdateStrategy` 타입의 열거형으로, 사용자가 컬렉션 뷰가 내용을 업데이트하는 방법을 제어할 수 있게 해줍니다.

세 가지 옵션이 제공됩니다:
 - `case animatedBatchUpdates:` 새로운 콘텐츠로 `performBatchUpdates(…)`를 호출하여 애니메이션이 있는 배치 업데이트를 수행합니다. 이 방법은 셀의 삽입, 삭제 및 이동을 애니메이션화하여 부드러운 사용자 경험을 만듭니다.
 - `case nonanimatedBatchUpdates:` `UIView.performWithoutAnimation(…)` 블록으로 감싸서 애니메이션 없이 배치 업데이트를 수행합니다. 이는 모든 보이는 셀의 전체 재구성을 피하므로 reloadData()보다 성능이 좋습니다.
 - `case reloadData:` `reloadData()`를 사용하여 데이터의 전체 다시 로드를 수행합니다. 이는 모든 보이는 셀을 재구성하며, 성능상의 이유로 데이터 업데이트에는 일반적으로 권장되지 않습니다. UIKit 엔지니어들은 전체 다시 로드보다 배치 업데이트를 선호할 것을 권장합니다.

기본적으로 값은 `.animatedBatchUpdates`로 설정되어 있으며, 이는 데이터가 변경될 때 컬렉션 뷰를 업데이트하는 시각적으로 부드럽고 성능이 좋은 방법을 제공합니다.

세 번째 매개변수는 완료 핸들러 역할을 하는 후행 클로저입니다. 이 블록은 컬렉션 뷰가 변경사항 적용을 완료한 후에 실행됩니다.


### 크기 조정

View의 크기는 실제로 View가 화면에 표시될 때 조정되며, 이는 `sizeThatFits`를 통해 조정할 수 있습니다. 그때까지 컴포넌트는 자신의 크기를 추정치로 나타낼 수 있습니다.

```swift
struct ButtonComponent: Component {
  typealias Content = Button
  // ...
}

final class Button: UIControl {
  // ...
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    // Button의 크기를 반환
  }
}
```


### 페이지네이션
`KarrotListKit`은 다음 페이지의 데이터를 로드할 때 페이지네이션을 처리하기 위한 사용하기 쉬운 인터페이스를 제공합니다.
전통적으로는 `scrollViewDidScroll` 메서드 내에서 구현될 수 있지만, `KarrotListKit`은 이 목적을 위한 더 구조화된 메커니즘을 제공합니다.

`List`는 리스트의 끝에 도달했을 때 호출되는 `onReachEnd` 수정자를 제공합니다. 이 수정자는 `List`에 첨부할 수 있습니다.

```swift
List(sections: [])
  .onReachEnd(
    offset: .absolute(100.0),
    handler: { _ in
      // 리스트 끝에 도달했을 때 트리거되는 클로저
    }
  )
```

첫 번째 매개변수인 `offset`은 `ReachedEndEvent.OffsetFromEnd` 타입의 열거형으로, 사용자가 트리거 조건을 설정할 수 있게 해줍니다.

두 가지 옵션이 제공됩니다:

- `case relativeToContainerSize(multiplier: CGFloat)`: 사용자가 콘텐츠 뷰 높이의 배수 내에서 스크롤할 때 이벤트를 트리거합니다.
- `case absolute(CGFloat)`: 사용자가 끝에서 절대 포인트 값 내에서 스크롤할 때 이벤트를 트리거합니다.

기본적으로 값은 `.relativeToContainerSize(multiplier: 2.0)`으로 설정되어 있으며, 이는 스크롤 위치가 리스트 끝에서 리스트 뷰 높이의 두 배 내에 있을 때 이벤트를 트리거합니다.

두 번째 매개변수인 `handler`는 리스트 끝에 도달했을 때 비동기 액션을 수행하는 콜백 핸들러입니다.



### 프리페칭

스크롤 성능을 향상시키기 위한 리소스 프리페칭 API를 제공합니다.
CollectionViewAdapter는 `UICollectionViewDataSourcePrefetching`을 준수합니다. 프레임워크는 호환성을 위해 `ComponentResourcePrefetchable`과 `CollectionViewPrefetchingPlugin` 프로토콜을 제공합니다.

다음은 이미지 프리페칭을 위한 샘플 코드입니다.

```swift
let collectionViewAdapter = CollectionViewAdapter<CompositionalLayout>(
  configuration: .init(
    prefetchingPlugins: [
      RemoteImagePrefetchingPlugin(
        remoteImagePrefetcher: RemoteImagePrefetcher()
      )
    ]
  )
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



## 기여하기

이 프로젝트에 대한 모든 기여를 따뜻하게 환영하고 감사합니다!
이 프로젝트의 기능을 향상시키기 위한 풀 리퀘스트를 자유롭게 제출해 주세요.



## 라이선스

이 프로젝트는 Apache License 2.0에 따라 라이선스가 부여됩니다. 자세한 내용은 [LICENSE](https://github.com/daangn/KarrotListKit/blob/main/LICENSE)를 참조하세요.
