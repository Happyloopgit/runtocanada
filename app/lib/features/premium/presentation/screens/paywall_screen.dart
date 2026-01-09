import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/core/widgets/glass_card.dart';
import 'package:run_to_canada/features/premium/data/services/premium_service.dart';
import 'package:run_to_canada/features/premium/presentation/providers/premium_providers.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String _selectedPlan = 'annual'; // 'monthly' or 'annual'
  bool _isLoading = false;
  Package? _monthlyPackage;
  Package? _annualPackage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await ref.read(subscriptionPackagesProvider.future);
    setState(() {
      _monthlyPackage = packages['monthly'];
      _annualPackage = packages['annual'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final pricingInfo = PremiumService.getPricingInfo();
    final benefits = PremiumService.getPremiumBenefits();
    final packagesAsync = ref.watch(subscriptionPackagesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Premium header with gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premium.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
                child: Column(
                  children: [
                    // Premium crown icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Hero(
                        tag: 'premium_icon',
                        child: Icon(
                          Icons.workspace_premium,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Run Further.\nExplore More.',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Unlock unlimited journeys and premium features',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Features list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ...benefits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final benefit = entry.value;
                      final icon = _getBenefitIcon(index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SolidCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: AppColors.premiumGradient,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.premium.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Pricing cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: packagesAsync.when(
                        data: (packages) {
                          final monthlyPackage = packages['monthly'];
                          final annualPackage = packages['annual'];

                          // Calculate savings if both packages available
                          String? savings;
                          String? monthlyEquivalent;

                          if (monthlyPackage != null && annualPackage != null) {
                            final revenueCatService = ref.read(revenueCatServiceProvider);
                            savings = revenueCatService.getAnnualSavings(monthlyPackage, annualPackage);
                            monthlyEquivalent = revenueCatService.getMonthlyEquivalent(annualPackage);
                          }

                          return Column(
                            children: [
                              // Annual plan (if available)
                              if (annualPackage != null) ...[
                                _buildPricingCard(
                                  'annual',
                                  'Annual Plan',
                                  annualPackage.storeProduct.priceString,
                                  monthlyEquivalent,
                                  savings != null ? 'Save $savings' : null,
                                  true, // Recommended
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Monthly plan (if available)
                              if (monthlyPackage != null)
                                _buildPricingCard(
                                  'monthly',
                                  'Monthly Plan',
                                  monthlyPackage.storeProduct.priceString,
                                  null,
                                  null,
                                  false,
                                ),

                              // Fallback if no packages loaded
                              if (monthlyPackage == null && annualPackage == null) ...[
                                _buildPricingCard(
                                  'annual',
                                  'Annual Plan',
                                  pricingInfo['annual']['displayPrice'],
                                  pricingInfo['annual']['monthlyCost'],
                                  'Save ${pricingInfo['annual']['savings']}',
                                  true,
                                ),
                                const SizedBox(height: 16),
                                _buildPricingCard(
                                  'monthly',
                                  'Monthly Plan',
                                  pricingInfo['monthly']['displayPrice'],
                                  null,
                                  null,
                                  false,
                                ),
                              ],
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Column(
                          children: [
                            // Fallback to static pricing on error
                            _buildPricingCard(
                              'annual',
                              'Annual Plan',
                              pricingInfo['annual']['displayPrice'],
                              pricingInfo['annual']['monthlyCost'],
                              'Save ${pricingInfo['annual']['savings']}',
                              true,
                            ),
                            const SizedBox(height: 16),
                            _buildPricingCard(
                              'monthly',
                              'Monthly Plan',
                              pricingInfo['monthly']['displayPrice'],
                              null,
                              null,
                              false,
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Subscribe button
                    CustomButton(
                      text: _getSubscribeButtonText(packagesAsync),
                      onPressed: _isLoading ? null : _handleSubscribe,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Restore purchases button
                    CustomButton(
                      text: 'Restore Purchases',
                      onPressed: _isLoading ? null : _handleRestorePurchases,
                      isOutlined: true,
                    ),

                    const SizedBox(height: 24),

                    // Terms and privacy
                    Text(
                      'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBenefitIcon(int index) {
    switch (index) {
      case 0:
        return Icons.all_inclusive; // Unlimited distance
      case 1:
        return Icons.block; // Ad-free
      case 2:
        return Icons.flag; // Detailed milestones
      case 3:
        return Icons.bar_chart; // Advanced statistics
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildPricingCard(
    String planId,
    String title,
    String price,
    String? subtitle,
    String? badge,
    bool isRecommended,
  ) {
    final isSelected = _selectedPlan == planId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.premium : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.premium.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? AppColors.premiumGradient : null,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                // Plan info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.premium : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.milestoneGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Best Value badge
          if (isRecommended)
            Positioned(
              top: -1,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premium.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'BEST VALUE',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getSubscribeButtonText(AsyncValue<Map<String, Package?>> packagesAsync) {
    return packagesAsync.when(
      data: (packages) {
        final selectedPackage = _selectedPlan == 'annual' ? packages['annual'] : packages['monthly'];
        if (selectedPackage != null) {
          return 'Subscribe for ${selectedPackage.storeProduct.priceString}';
        }
        final pricingInfo = PremiumService.getPricingInfo();
        return _selectedPlan == 'annual'
            ? 'Subscribe for ${pricingInfo['annual']['displayPrice']}'
            : 'Subscribe for ${pricingInfo['monthly']['displayPrice']}';
      },
      loading: () => 'Loading...',
      error: (error, stackTrace) {
        final pricingInfo = PremiumService.getPricingInfo();
        return _selectedPlan == 'annual'
            ? 'Subscribe for ${pricingInfo['annual']['displayPrice']}'
            : 'Subscribe for ${pricingInfo['monthly']['displayPrice']}';
      },
    );
  }

  Future<void> _handleSubscribe() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final revenueCatService = ref.read(revenueCatServiceProvider);
      final premiumService = ref.read(premiumServiceProvider);

      // Get the selected package
      final selectedPackage = _selectedPlan == 'annual' ? _annualPackage : _monthlyPackage;

      if (selectedPackage == null) {
        throw Exception('Selected package not available. Please try again.');
      }

      // Make the purchase
      final customerInfo = await revenueCatService.purchasePackage(selectedPackage);

      // Check if user now has premium access
      // Check for the "premium" entitlement
      final premiumEntitlement = customerInfo.entitlements.all['premium'];
      final hasPremium = premiumEntitlement?.isActive ?? false;

      if (hasPremium) {
        // Update premium status in Firestore
        await premiumService.updatePremiumStatus(true);

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to Premium! Enjoy unlimited journeys.'),
              backgroundColor: AppColors.success,
            ),
          );

          // Close the paywall
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        throw Exception('Purchase completed but premium access not granted');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Purchase failed. Please try again.';

        if (e.toString().contains('cancelled')) {
          errorMessage = 'Purchase was cancelled.';
        } else if (e.toString().contains('not allowed')) {
          errorMessage = 'Purchases are not allowed on this device.';
        } else if (e.toString().contains('pending')) {
          errorMessage = 'Payment is pending. Please check back later.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRestorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final revenueCatService = ref.read(revenueCatServiceProvider);
      final premiumService = ref.read(premiumServiceProvider);

      // Restore purchases
      final customerInfo = await revenueCatService.restorePurchases();

      // Check if user has premium access
      // Check for the "premium" entitlement
      final premiumEntitlement = customerInfo.entitlements.all['premium'];
      final hasPremium = premiumEntitlement?.isActive ?? false;

      if (hasPremium) {
        // Update premium status in Firestore
        await premiumService.updatePremiumStatus(true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Close the paywall
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
