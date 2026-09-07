import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/record_impact_usecase.dart';
import 'distribution_form_state.dart';

@injectable
class DistributionFormCubit extends Cubit<DistributionFormState> {
  final RecordImpactUseCase _recordImpactUseCase;

  DistributionFormCubit(this._recordImpactUseCase)
    : super(const DistributionFormState());

  /// Returns true on success.
  Future<bool> submit({
    required int orderId,
    required int familiesCount,
    required int individualsCount,
    required String area,
    String? notes,
  }) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _recordImpactUseCase(
      RecordImpactParams(
        id: orderId,
        familiesCount: familiesCount,
        individualsCount: individualsCount,
        area: area,
        notes: notes,
      ),
    );

    bool ok = false;
    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        ok = true;
        if (isClosed) return;
        emit(state.copyWith(status: BlocStatus.success));
      },
    );
    return ok;
  }
}
