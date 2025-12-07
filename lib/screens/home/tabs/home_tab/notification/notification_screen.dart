import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/notification_response.dart';
import 'notification_bloc.dart';

class NotificationScreen extends BaseScreen {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState
    extends BaseState<NotificationScreen, NotificationBloc> {
  @override
  Widget body() {
    return SafeArea(
      child: FutureBuilder<NotificationResponse>(
        future: bloc.notifications(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return Text("data");
          }return SizedBox();
        }
      ),
    );
  }

  @override
  NotificationBloc provideBloc() {
    return NotificationBloc();
  }
}
