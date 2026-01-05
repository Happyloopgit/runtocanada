import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Trophy icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Upgrade to Premium',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'You\'ve reached the 100km free tier limit!\nUpgrade to continue your journey to Canada.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Benefits list
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Benefits',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...benefits.map((benefit) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          benefit,
                                          style: AppTextStyles.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Show loading or pricing cards
                      packagesAsync.when(
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

                      const SizedBox(height: 32),

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
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // Plan info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BEST VALUE',
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
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (badge != null)
                      Text(
                        badge,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
