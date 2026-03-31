import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/currency_service.dart';
import '../buyer_controller.dart';
import '../../../routes/app_pages.dart';

String _formatPrice(double value) {
  final absValue = value.abs();
  final decimals = absValue < 1
      ? 3
      : absValue < 100
      ? 2
      : 0;
  return value
      .toStringAsFixed(decimals)
      .replaceAllMapped(
        RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
        (Match m) => "${m[1]},",
      );
}

class SearchView extends GetView<BuyerController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController =
        TextEditingController(text: controller.searchQuery.value)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: controller.searchQuery.value.length),
          );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary, width: 1),
          ),
          child: TextField(
            controller: searchController,
            autofocus: controller.searchQuery.value.isEmpty,
            onChanged: controller.updateSearchSuggestions,
            onSubmitted: controller.executeSearch,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: Obx(
                () => controller.searchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchController.clear();
                          controller.clearSearch();
                        },
                        child: const Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.searchQuery.value.isNotEmpty &&
            controller.searchResults.isEmpty &&
            !controller.isSearching.value) {
          // Show Suggestions
          return _buildSuggestions();
        } else if (controller.isSearching.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.searchResults.isNotEmpty) {
          // Show Results
          return _buildSearchResults();
        } else {
          return _buildEmptyState();
        }
      }),
    );
  }

  Widget _buildSuggestions() {
    return ListView.separated(
      itemCount: controller.searchSuggestions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = controller.searchSuggestions[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: () => controller.executeSearch(product.name),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final product = controller.searchResults[index];
              return GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.productDetails,
                  arguments: {'product': product},
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image Section (Left)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details Section (Right)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if ((product.store?.name ??
                                    product.seller?.businessName) !=
                                null) ...[
                              const SizedBox(height: 4),
                              Text(
                                product.store?.name ??
                                    product.seller?.businessName ??
                                    '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '¥',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  Text(
                                    product.effectiveYuan > 0
                                        ? _formatPrice(product.effectiveYuan)
                                        : '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '(≈ ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  Obx(() {
                                    // Ensure GetX tracks location changes for fallback or symbol updates
                                    CurrencyService.to.currentLocation.value;

                                    final localPrice = product.effectiveLocal;
                                    if (localPrice == 0) {
                                      return Container(
                                        width: 60,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      );
                                    }

                                    return Text(
                                      '${product.effectiveSymbol}${_formatPrice(localPrice)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                  Text(
                                    ')',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  if ((product.moqTiers != null &&
                                          product.moqTiers!.isNotEmpty) ||
                                      (product.minQty != null &&
                                          product.minQty! > 1))
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        '${product.moqTiers?.first.minQty ?? product.minQty} pcs',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '10K+ sold',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Search for items from China',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
