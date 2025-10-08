import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/route_paths.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/product_image_builder.dart';
import '../../domain/entities/product.dart';
import '../providers/cart_controller.dart';
import '../providers/product_detail_controller.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final String productId;
  final Product? initialProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ProductDetailInput(id: productId, product: initialProduct);
    final provider = productDetailControllerProvider(input);
    final detailState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    ref.listen<ProductDetailState>(
      provider,
      (previous, next) {
        if (previous?.error != next.error && next.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(next.error!)));
        }
      },
    );

    final product = detailState.product;

    final Widget body;
    if (detailState.isLoading && product == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (product == null) {
      body = const Center(child: Text(AppStrings.productNotFound));
    } else {
      body = _ProductDetailContent(product: product, controller: controller);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? AppStrings.productDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppStrings.editProduct,
            onPressed: product == null
                ? null
                : () async {
                    final updated = await Navigator.of(context)
                        .push<Product>(MaterialPageRoute(builder: (_) {
                      return ProductFormScreen(product: product);
                    }));
                    if (updated != null) {
                      ref
                          .read(cartControllerProvider.notifier)
                          .syncProduct(updated);
                      await controller.refresh();
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.deleteProduct,
            onPressed: product == null
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(AppStrings.deleteProduct),
                          content: Text(
                            'Bạn có chắc muốn xóa "${product.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(AppStrings.deleteProduct),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed == true) {
                      await controller.deleteCurrent();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
          ),
        ],
      ),
      body: body,
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({
    required this.product,
    required this.controller,
  });

  final Product product;
  final ProductDetailController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: buildProductImage(
                product.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.vnd(product.price),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text(AppStrings.addToCart),
              onPressed: () {
                ref.read(cartControllerProvider.notifier).add(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm "${product.name}" vào giỏ hàng.'),
                    action: SnackBarAction(
                      label: AppStrings.viewCart,
                      onPressed: () {
                        Navigator.of(context).pushNamed(RoutePaths.cart);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
