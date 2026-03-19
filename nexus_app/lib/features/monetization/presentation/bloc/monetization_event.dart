import 'package:equatable/equatable.dart';

sealed class MonetizationEvent extends Equatable {
  const MonetizationEvent();

  @override
  List<Object?> get props => const [];
}

final class LoadOfferings extends MonetizationEvent {
  const LoadOfferings();
}

final class PurchaseProduct extends MonetizationEvent {
  const PurchaseProduct(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class RestorePurchases extends MonetizationEvent {
  const RestorePurchases();
}

final class CheckEntitlements extends MonetizationEvent {
  const CheckEntitlements();
}
