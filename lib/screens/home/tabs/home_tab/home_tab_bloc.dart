import 'package:intl/intl.dart';

import 'package:rxdart/rxdart.dart';

import '../../../../data/network/response/all_request_data.dart';
import '../../../../data/network/response/packages_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_bloc.dart';

class HomeTabBloc extends BaseBloc {
  final userRepository = sl.get<AuthRepository>();

  late final Stream<User> userDetails =
      ValueConnectableStream(userRepository.userDetails).autoConnect();


  @override
  void init() {
     super.init();
     customersMe();
  }

  Future<void> customersMe() => userRepository.customersMe();

  Stream<AllrequestData> allRequest() {
    final dateTimeNow = DateTime.now();
    final dateFormat = DateFormat('y-M-d');
    return userRepository.allRequest(dateFormat.format(dateTimeNow).toString());
  }

}
