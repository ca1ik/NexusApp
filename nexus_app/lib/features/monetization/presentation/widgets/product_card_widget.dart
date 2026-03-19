import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/features/monetization/domain/entities/product_entity.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_event.dart';

/// A single product card rendered in the Paywall.
class ProductCardWidget extends StatelessWidget {
  const ProductCardWidget({
    super.key,
    required this.product,
    required this.isPopular,
    required this.delay,
  });

  final ProductEntity product;
  final bool isPopular;
  final Duration delay;

  Color get _glowColor {
    return switch (product.tier) {
      ProductTier.micro => ThemeConstants.mirrorAccent,
      ProductTier.arena => ThemeConstants.arenaAccent,
      ProductTier.legacy => const Color(0xFFFFD700), // gold
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ThemeConstants.arenaSurface,
        border: Border.all(
          color: _glowColor.withAlpha(isPopular ? 200 : 80),
          width: isPopular ? 1.5 : 1.0,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: _glowColor.withAlpha(60),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.read<MonetizationBloc>().add(
              PurchaseProduct(product.productId),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _glowColor.withAlpha(40),
                            border: Border.all(
                              color: _glowColor.withAlpha(150),
                            ),
                          ),
                          child: Text(
                            'MOST POPULAR',
                            style: TextStyle(
                              color: _glowColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      Text(
                        product.title,
                        style: const TextStyle(
                          color: ThemeConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(
                          color: ThemeConstants.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.priceString,
                      style: TextStyle(
                        color: _glowColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (product.isSubscription)
                      const Text(
                        'per period',
                        style: TextStyle(
                          color: ThemeConstants.textDisabled,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: delay).slideY(begin: 0.15);
  }
}
