import 'package:equatable/equatable.dart';
import 'package:nexus_app/features/monetization/domain/entities/product_entity.dart';

sealed class MonetizationState extends Equatable {
  const MonetizationState();

  @override
  List<Object?> get props => const [];
}

final class MonetizationInitial extends MonetizationState {
  const MonetizationInitial();
}

final class MonetizationLoading extends MonetizationState {
  const MonetizationLoading();
}

final class OfferingsLoaded extends MonetizationState {
  const OfferingsLoaded({
    required this.products,
    required this.hasArenaAccess,
    required this.hasLegacyAccess,
  });

  final List<ProductEntity> products;
  final bool hasArenaAccess;
  final bool hasLegacyAccess;

  @override
  List<Object?> get props => [products, hasArenaAccess, hasLegacyAccess];
}

final class PurchaseSuccess extends MonetizationState {
  const PurchaseSuccess(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class PurchasePending extends MonetizationState {
  const PurchasePending(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class MonetizationError extends MonetizationState {
  const MonetizationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
