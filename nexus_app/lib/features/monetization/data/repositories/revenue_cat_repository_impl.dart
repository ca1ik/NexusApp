import 'package:logger/logger.dart';
import 'package:nexus_app/core/constants/app_constants.dart';
import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/features/monetization/domain/entities/product_entity.dart';
import 'package:nexus_app/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatRepositoryImpl implements MonetizationRepository {
  const RevenueCatRepositoryImpl({required Logger logger}) : _log = logger;

  final Logger _log;

  @override
  Future<List<ProductEntity>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return ProductEntity.catalog;

      // Map RevenueCat packages to our domain entities, preserving live prices
      final enriched = <ProductEntity>[];
      for (final pkg in current.availablePackages) {
        final skuId = pkg.storeProduct.identifier;
        final local = ProductEntity.catalog
            .where((p) => p.productId == skuId)
            .firstOrNull;
        if (local != null) {
          enriched.add(
            ProductEntity(
              productId: local.productId,
              title: pkg.storeProduct.title,
              description: pkg.storeProduct.description,
              priceString: pkg.storeProduct.priceString,
              tier: local.tier,
              isSubscription: local.isSubscription,
            ),
          );
        }
      }
      return enriched.isNotEmpty ? enriched : ProductEntity.catalog;
    } catch (e) {
      _log.w('getOfferings failed, using local catalog: $e');
      return ProductEntity.catalog;
    }
  }

  @override
  Future<void> purchaseProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final pkg = offerings.current?.availablePackages
          .where((p) => p.storeProduct.identifier == productId)
          .firstOrNull;

      if (pkg == null) {
        throw MonetizationException(message: 'Product not found: $productId');
      }

      await Purchases.purchase(PurchaseParams.package(pkg));
    } on PurchasesErrorCode catch (e) {
      throw MonetizationException(message: 'Purchase error: ${e.name}');
    } catch (e) {
      throw MonetizationException(message: 'Purchase failed: $e');
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      throw MonetizationException(message: 'Restore failed: $e');
    }
  }

  @override
  Future<bool> hasArenaAccess() async {
    final entitlements = await getActiveEntitlements();
    return entitlements.contains(AppConstants.arenaEntitlement);
  }

  @override
  Future<bool> hasLegacyAccess() async {
    final entitlements = await getActiveEntitlements();
    return entitlements.contains(AppConstants.legacyEntitlement);
  }

  @override
  Future<Set<String>> getActiveEntitlements() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.keys.toSet();
    } catch (e) {
      _log.w('Could not fetch entitlements: $e');
      return const {};
    }
  }
}
