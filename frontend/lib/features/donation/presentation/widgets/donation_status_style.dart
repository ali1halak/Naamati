import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/donation_status.dart';

/// Single source of truth for donation-status colors so the list badges,
/// the status chip, and the filter chips always agree.
///
/// [foreground] is the text/dot color, [background] the pill fill.
final Map<DonationStatus, ({Color foreground, Color background})>
kDonationStatusStyles = {
  DonationStatus.pending: (
    foreground: AppColors.secondaryDark,
    background: AppColors.warningContainer,
  ),
  DonationStatus.accepted: (
    foreground: AppColors.success,
    background: AppColors.successContainer,
  ),
  DonationStatus.pickedUp: (
    foreground: AppColors.brandGreen,
    background: AppColors.primaryContainer,
  ),
  DonationStatus.completed: (
    foreground: Colors.white,
    background: AppColors.brandGreen,
  ),
  DonationStatus.expired: (
    foreground: AppColors.textSecondaryLight,
    background: AppColors.surfaceVariantLight,
  ),
  DonationStatus.cancelled: (
    foreground: AppColors.error,
    background: AppColors.errorContainer,
  ),
  DonationStatus.noShow: (
    foreground: AppColors.error,
    background: AppColors.errorContainer,
  ),
};
