import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/get_order_audit_usecase.dart';
import 'charity_order_audit_state.dart';

@injectable
class CharityOrderAuditCubit extends Cubit<CharityOrderAuditState> {
  final GetOrderAuditUseCase _getOrderAuditUseCase;

  CharityOrderAuditCubit(this._getOrderAuditUseCase)
    : super(const CharityOrderAuditState());

  Future<void> loadAudit(int id) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _getOrderAuditUseCase(GetOrderAuditParams(id: id));

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
      (audit) {
        if (isClosed) return;
        emit(state.copyWith(status: BlocStatus.success, audit: audit));
      },
    );
  }
}
