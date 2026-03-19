import 'package:equatable/equatable.dart';
import 'package:nexus_app/core/constants/app_constants.dart';

enum ProductTier {
  micro, // $5–$15 one-time
  arena, // $25/month
  legacy, // $1000+/year
}

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.productId,
    required this.title,
    required this.description,
    required this.priceString,
    required this.tier,
    this.isSubscription = false,
  });

  final String productId;
  final String title;
  final String description;
  final String priceString;
  final ProductTier tier;
  final bool isSubscription;

  static const List<ProductEntity> catalog = [
    ProductEntity(
      productId: AppConstants.arenaMonthlyId,
      title: 'Arena of Minds',
      description:
          'Unlimited battle simulations against Shadow Nexus. '
          'Master salary negotiations, hostile takeovers, and psychological warfare.',
      priceString: r'$25/month',
      tier: ProductTier.arena,
      isSubscription: true,
    ),
    ProductEntity(
      productId: AppConstants.analyzeWeaknessId,
      title: 'Analyze Weakness',
      description:
          'Instant deep-dive analysis of your opponent\'s psychological vulnerabilities '
          'in the current Arena session.',
      priceString: r'$5',
      tier: ProductTier.micro,
    ),
    ProductEntity(
      productId: AppConstants.toxicPersonaId,
      title: 'Toxic Partner Persona',
      description:
          'Unlock the Toxic Partner archetype — a simulator for navigating '
          'emotional manipulation and gaslighting in relationships.',
      priceString: r'$9.99',
      tier: ProductTier.micro,
    ),
    ProductEntity(
      productId: AppConstants.roughManagerPersonaId,
      title: 'The Brutal Executive',
      description:
          'Face an impossible boss. Train your assertiveness, boundary-setting, '
          'and negotiation skills under maximum pressure.',
      priceString: r'$9.99',
      tier: ProductTier.micro,
    ),
    ProductEntity(
      productId: AppConstants.legacyAnnualId,
      title: 'The Legacy Transference',
      description:
          'The ultra-VIP tier. Your entire Nexus journey — every pattern, '
          'insight, and persona — digitally certified and preserved as your '
          'permanent psychological legacy.',
      priceString: r'$1,000/year',
      tier: ProductTier.legacy,
      isSubscription: true,
    ),
  ];

  @override
  List<Object?> get props => [productId, tier];
}
