import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../resourses/app_colors.dart';
import 'base_bloc.dart';
import 'base_screen.dart';

typedef bool ErrorHandler(Object error);

mixin ErrorDispatcher<Page extends BaseScreen, Bloc extends BaseBloc>
on BaseState<Page, Bloc> {
  StreamSubscription? errorSubscription;

  @override
  void initState() {
    super.initState();

    errorSubscription = bloc.errorStream
        .transform(
      ThrottleStreamTransformer<Object>(
            (_) => TimerStream<Object>(true, const Duration(seconds: 2)),
      ),
    )
        .listen((error) {
      if (error is DioError) {
        final response = error.response;
        final data = response?.data;
        String message = "Something went wrong";

        // ✅ если сервер вернул просто строку
        if (data is String && data.isNotEmpty) {
          message = data.trim();
        }
        // ✅ если сервер вернул JSON с ключом "message"
        else if (data is Map && data['message'] is String) {
          message = data['message'];
        }


        showTopSnackbar("Error", message, false, context);
        print("❌ [ErrorDispatcher] DioError: $message");
        return;
      }

      // ✅ если ошибка не DioError
      showTopSnackbar("Error", error.toString(), false, context);
      print("❌ [ErrorDispatcher] ${error.toString()}");
    });
  }

  @override
  void dispose() {
    errorSubscription?.cancel();
    super.dispose();
  }

  ErrorHandler? get errorHandler => null;
}

///
/// Показывает красивый snackbar сверху экрана
///
void showTopSnackbar(
    String title, String message, bool isSuccess, BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  final controller = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 300),
  );

  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top +
              20 -
              (controller.value * 100),
          left: 16,
          right: 16,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < -10) {
                controller.forward().then((_) => overlayEntry.remove());
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.appColor : Colors.red,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                        color: isSuccess ? AppColors.appColor : Colors.red,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSuccess ? Icons.check : Icons.close,
                                color: isSuccess
                                    ? AppColors.appColor
                                    : Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                            right: 20, top: 25, bottom: 25, left: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                              ),
                              maxLines: null,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3), () {
    controller.forward().then((_) => overlayEntry.remove());
  });
}
