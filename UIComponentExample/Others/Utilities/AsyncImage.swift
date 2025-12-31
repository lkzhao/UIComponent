//  Created by Luke Zhao on 11/5/25.

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import Kingfisher

struct AsyncImage: ComponentBuilder {
    let url: URL?

    public func build() -> AnyComponentOfView<UIImageView> {
        ViewComponent<UIImageView>()
            .update {
                KF.url(url).set(to: $0)
            }
            .eraseToAnyComponentOfView()
    }
}
#endif
