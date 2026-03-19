import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_event.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_state.dart';

class MonetizationBloc extends Bloc<MonetizationEvent, MonetizationState> {
  MonetizationBloc({required MonetizationRepository monetizationRepository})
    : _repo = monetizationRepository,
      super(const MonetizationInitial()) {
    on<LoadOfferings>(_onLoadOfferings);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<CheckEntitlements>(_onCheckEntitlements);
  }

  final MonetizationRepository _repo;

  Future<void> _onLoadOfferings(
    LoadOfferings event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(const MonetizationLoading());
    try {
      final products = await _repo.getOfferings();
      final arenaAccess = await _repo.hasArenaAccess();
      final legacyAccess = await _repo.hasLegacyAccess();
      emit(
        OfferingsLoaded(
          products: products,
          hasArenaAccess: arenaAccess,
          hasLegacyAccess: legacyAccess,
        ),
      );
    } catch (e) {
      emit(MonetizationError(e.toString()));
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProduct event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(PurchasePending(event.productId));
    try {
      await _repo.purchaseProduct(event.productId);
      emit(PurchaseSuccess(event.productId));
      // Refresh entitlements after successful purchase
      add(const LoadOfferings());
    } on MonetizationException catch (e) {
      emit(MonetizationError(e.message));
    } catch (e) {
      emit(MonetizationError(e.toString()));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(const MonetizationLoading());
    try {
      await _repo.restorePurchases();
      add(const LoadOfferings());
    } catch (e) {
      emit(MonetizationError(e.toString()));
    }
  }

  Future<void> _onCheckEntitlements(
    CheckEntitlements event,
    Emitter<MonetizationState> emit,
  ) async {
    try {
      final arenaAccess = await _repo.hasArenaAccess();
      final legacyAccess = await _repo.hasLegacyAccess();
      final products = await _repo.getOfferings();
      emit(
        OfferingsLoaded(
          products: products,
          hasArenaAccess: arenaAccess,
          hasLegacyAccess: legacyAccess,
        ),
      );
    } catch (e) {
      emit(MonetizationError(e.toString()));
    }
  }
}
