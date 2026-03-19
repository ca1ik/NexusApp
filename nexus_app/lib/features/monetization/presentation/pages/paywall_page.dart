import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/features/monetization/domain/entities/product_entity.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_event.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_state.dart';
import 'package:nexus_app/features/monetization/presentation/widgets/product_card_widget.dart';
import 'package:shimmer/shimmer.dart';

/// The Paywall — unlocks premium tiers.
/// Surfaced when user hits a locked feature or navigates to AppRoutes.paywall.
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MonetizationBloc, MonetizationState>(
      listener: (ctx, state) {
        if (state is PurchaseSuccess) {
          Get.snackbar(
            'ACCESS GRANTED',
            'Your nexus has been upgraded.',
            backgroundColor: ThemeConstants.arenaAccent.withAlpha(200),
            colorText: Colors.black,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 3),
          );
          ctx.read<MonetizationBloc>().add(const LoadOfferings());
        } else if (state is MonetizationError) {
          Get.snackbar(
            'TRANSACTION DENIED',
            state.message,
            backgroundColor: ThemeConstants.fracturePrimary.withAlpha(200),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.arenaBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildProductList(context)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: ThemeConstants.textSecondary,
                  size: 22,
                ),
                onPressed: () => Get.back<void>(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'UNLOCK THE NEXUS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeConstants.arenaAccent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          const Text(
            'Every level of power has its price.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeConstants.textSecondary,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<MonetizationBloc, MonetizationState>(
      builder: (ctx, state) {
        if (state is MonetizationLoading || state is MonetizationInitial) {
          return _buildLoadingShimmer();
        }

        List<ProductEntity> products;
        if (state is OfferingsLoaded) {
          products = state.products;
        } else {
          products = ProductEntity.catalog;
        }

        final purchasePending = state is PurchasePending ? state : null;
        final isPurchasing = purchasePending != null;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: products.length,
          itemBuilder: (ctx2, i) {
            final product = products[i];
            final isPopular = product.tier == ProductTier.arena;
            return Stack(
              children: [
                ProductCardWidget(
                  product: product,
                  isPopular: isPopular,
                  delay: Duration(milliseconds: 100 * i),
                ),
                if (isPurchasing &&
                    purchasePending.productId == product.productId)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black38,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ThemeConstants.arenaAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 4,
      itemBuilder: (_, i) => Shimmer.fromColors(
        baseColor: ThemeConstants.arenaSurface,
        highlightColor: ThemeConstants.arenaAccent.withAlpha(40),
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ThemeConstants.arenaSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              context.read<MonetizationBloc>().add(const RestorePurchases());
            },
            child: const Text(
              'Restore Purchases',
              style: TextStyle(
                color: ThemeConstants.textDisabled,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Subscriptions auto-renew unless cancelled 24h before period end.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeConstants.textDisabled,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
