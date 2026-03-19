import 'package:nexus_app/features/monetization/domain/entities/product_entity.dart';

abstract interface class MonetizationRepository {
  /// Returns the local product catalog enriched with live RevenueCat prices.
  Future<List<ProductEntity>> getOfferings();

  /// Initiates a RevenueCat purchase flow for [productId].
  Future<void> purchaseProduct(String productId);

  /// Restores previous purchases (required by App Store / Play Store policies).
  Future<void> restorePurchases();

  /// Returns true if the user has an active Arena subscription.
  Future<bool> hasArenaAccess();

  /// Returns true if the user has an active Legacy subscription.
  Future<bool> hasLegacyAccess();

  /// Returns all active entitlement IDs for the current user.
  Future<Set<String>> getActiveEntitlements();
}
