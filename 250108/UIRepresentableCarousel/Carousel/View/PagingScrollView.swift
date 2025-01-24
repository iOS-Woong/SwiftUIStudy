
import SwiftUI

final class UIKitPagingCollectionViewCell: UICollectionViewCell {
    static let identifier = "UIKitPagingCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
struct UIKitPagingCollectionView: UIViewRepresentable {
    @Binding var floatIndex: CGFloat
    var colors: [UIColor] // <-- 여기서 UIColor 배열
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewLayout()
        )
        
        collectionView.register(
            UIKitPagingCollectionViewCell.self,
            forCellWithReuseIdentifier: UIKitPagingCollectionViewCell.identifier
        )
        
        collectionView.collectionViewLayout = createLayout()
        context.coordinator.dataSource = createDataSource(collectionView: collectionView)
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        configureSnapshot(colors: colors, context: context)
    }
    
    // MARK: - Coordinator
    class Coordinator {
        var dataSource: UICollectionViewDiffableDataSource<Int, UIColor>?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}


extension UIKitPagingCollectionView {
    private func configureSnapshot(
        colors: [UIColor],
        context: Context
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, UIColor>()
        snapshot.appendSections([0])
        snapshot.appendItems(colors)
        
        context.coordinator.dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func createDataSource(collectionView: UICollectionView)
    -> UICollectionViewDiffableDataSource<Int, UIColor> {
        
        UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, color in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UIKitPagingCollectionViewCell.identifier,
                for: indexPath
            ) as? UIKitPagingCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.backgroundColor = color
            
            return cell
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                  heightDimension: .fractionalHeight(1.0))
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(0.8),
                                  heightDimension: .fractionalHeight(1.0)),
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            section.visibleItemsInvalidationHandler = { items, offset, environment in
                // 뭔가 더 좋은 방법이 없을까? (오차가 존재한다)
                let groupWidth = environment.container.contentSize.width * 0.8 + 10
                let startOffset = 40.333333333333336
                let floatIndex = (offset.x + startOffset) / groupWidth
                self.floatIndex = floatIndex
            }
            
            return section
        }
    }
}
