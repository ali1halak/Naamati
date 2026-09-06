import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/get_donation_audit_usecase.dart';
import '../../domain/usecases/rate_donation_usecase.dart';
import 'donation_audit_state.dart';

@injectable
class DonationAuditCubit extends Cubit<DonationAuditState> {
  final GetDonationAuditUseCase _getDonationAuditUseCase;
  final RateDonationUseCase _rateDonationUseCase;

  DonationAuditCubit(this._getDonationAuditUseCase, this._rateDonationUseCase)
    : super(const DonationAuditState());

  /// Loads full audit information for the specified donation request id.
  Future<void> loadAudit(int id) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _getDonationAuditUseCase(
      GetDonationAuditParams(id: id),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (audit) => emit(state.copyWith(status: BlocStatus.success, audit: audit)),
    );
  }

  /// Submits charity evaluation (stars 1-5 and optional comment).
  Future<bool> rateCharity({
    required int id,
    required int stars,
    String? comment,
  }) async {
    emit(
      state.copyWith(
        isSubmittingRating: true,
        ratingErrorMessage: null,
        ratingSuccessMessage: null,
      ),
    );

    final result = await _rateDonationUseCase(
      RateDonationParams(id: id, stars: stars, comment: comment),
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSubmittingRating: false,
            ratingErrorMessage: failure.message,
          ),
        );
        return false;
      },
      (rating) {
        emit(
          state.copyWith(
            isSubmittingRating: false,
            ratingSuccessMessage: 'شكراً لتقييمك! تم إرسال التقييم بنجاح',
          ),
        );
        // Reload audit data to refresh canRateCharity and rating fields
        loadAudit(id);
        return true;
      },
    );
  }
}
