import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/route_paths.dart';
import '../../core/widgets/app_navigation_bar.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/product_card.dart';
import '../../domain/entities/product.dart';
import '../providers/cart_controller.dart';
import '../providers/product_list_controller.dart';
import 'product_form_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ProviderSubscription<ProductListState> _listSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(productListControllerProvider.notifier)
          .fetchProducts(forceRefresh: true);
    });

    _listSubscription = ref.listenManual<ProductListState>(
      productListControllerProvider,
      (prev, next) {
        if (!mounted) return;
        if (prev?.error != next.error && next.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(next.error!)));
        }
        if (_searchController.text != next.query) {
          _searchController.text = next.query;
        }
      },
    );
  }

  @override
  void dispose() {
    _listSubscription.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListControllerProvider);
    final products = ref.watch(filteredProductsProvider);
    final cartState = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(AppStrings.productsTitle),
        actions: [
          IconButton(
            icon: Badge.count(
              count: cartState.itemCount,
              isLabelVisible: cartState.itemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.of(context).pushNamed(RoutePaths.cart),
            tooltip: AppStrings.cartTitle,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: AppStrings.searchPlaceholder,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: ref
                  .read(productListControllerProvider.notifier)
                  .setSearchQuery,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(productListControllerProvider.notifier)
                  .fetchProducts(forceRefresh: true),
              child: state.isLoading && products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                      ? const EmptyView(
                          message: AppStrings.emptyProducts,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = _calculateCrossAxisCount(
                              constraints.maxWidth,
                              MediaQuery.of(context).orientation,
                            );
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () => _openDetail(product),
                                  onAddToCart: () => ref
                                      .read(cartControllerProvider.notifier)
                                      .add(product),
                                  onLongPress: () =>
                                      _showProductActions(context, product),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<Product>(
            MaterialPageRoute(
              builder: (_) => const ProductFormScreen(),
            ),
          );
          if (created != null) {
            ref.read(productListControllerProvider.notifier).fetchProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addProduct),
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 0),
    );
  }

  void _openDetail(Product product) {
    Navigator.of(context).pushNamed(
      '${RoutePaths.products}/${product.id}',
      arguments: product,
    );
  }

  Future<void> _showProductActions(
      BuildContext context, Product product) async {
    final notifier = ref.read(productListControllerProvider.notifier);
    final cartNotifier = ref.read(cartControllerProvider.notifier);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Sửa'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Xóa'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (action == 'edit') {
      final updated = await Navigator.of(context).push<Product>(
        MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
      );
      if (updated != null) {
        cartNotifier.syncProduct(updated);
      }
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text('Bạn có chắc muốn xóa "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await notifier.delete(product.id);
        cartNotifier.removeIfExists(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã xóa "${product.name}"')),
          );
        }
      }
    }
  }

  int _calculateCrossAxisCount(double maxWidth, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return maxWidth < 500 ? 2 : 3;
    }
    if (maxWidth > 1200) {
      return 5;
    }
    return 4;
  }
}
