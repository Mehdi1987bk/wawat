import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'base_bloc.dart';
import 'base_screen.dart';

typedef bool ErrorHandler(Object error);

mixin ErrorDispatcher<Page extends BaseScreen, Bloc extends BaseBloc> on BaseState<Page, Bloc> {
  StreamSubscription? errorSubscription;

  @override
  void initState() {
    super.initState();
    errorSubscription = bloc.errorStream
        .transform(ThrottleStreamTransformer<Object>(
            (_) => TimerStream<Object>(true, const Duration(seconds: 2))))
        .listen((error) {
      if (error.runtimeType == DioError) {
        final dioError = error as DioError;
        final responseBody = dioError.response?.data;

        // Handle 500 error specifically
        if (dioError.response?.statusCode == 500 && responseBody is Map) {
          final message = responseBody["message"];
          if (message != null && message == "Call to undefined method App\\Models\\Customer::otpRequestds()") {
            showTopSnackbar("Error", message);
            return;
          }
        }
        // Handle 500 error specifically
        if (dioError.response?.statusCode == 404 && responseBody is Map) {
          final message = responseBody["message"];
          if (message != null ) {
            showTopSnackbar("Error", message);
            return;
          }
        }

        // Handle 422 errors and other common error responses
        if (dioError.response?.statusCode == 422 && responseBody is Map) {
          if (responseBody.containsKey("error")) {
            final errorMessage = responseBody["error"];
            if (errorMessage != null) {
              showTopSnackbar("Error", errorMessage);
              return;
            }
          }
          if (responseBody.containsKey("message")) {
            final errorMessage = responseBody["message"];
            if (errorMessage != null) {
              showTopSnackbar("Error", errorMessage);
              return;
            }
          }
          if (responseBody.containsKey("errors")) {
            final errors = responseBody["errors"];
            if (errors != null && errors is Map) {
              final errorMessages = <String>[];
              errors.forEach((field, messages) {
                if (messages is List) {
                  for (var message in messages) {
                    errorMessages.add("$message");
                  }
                }
              });
              if (errorMessages.isNotEmpty) {
                final formattedErrors = errorMessages.join("\n\n");
                showTopSnackbar("Error", formattedErrors);
                return;
              }
            }
          }
        }

        // Handle general error message display
        if (responseBody is Map && responseBody.containsKey("error")) {
          final errorMessage = responseBody["error"];
          if (errorMessage != null) {
            showTopSnackbar("Error", errorMessage);
          }
        }

        // Generic error handler
        if (errorHandler?.call(dioError) ?? true) {
          showTopSnackbar("Error", parseError(dioError, context));
          print("Error occurred");
        }
      }
    });
  }

  @override
  void dispose() {
    errorSubscription?.cancel();
    super.dispose();
  }

  ErrorHandler? get errorHandler => null;

  void showTopSnackbar(String title, String message) {
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
            top: MediaQuery.of(context).padding.top + 20 - (controller.value * 100),
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
                    color: Colors.red,
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
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                          color: Colors.red,
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
                                child: const Icon(Icons.close, color: Colors.red, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 20, top: 25, bottom: 25, left: 20),
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

  String parseError(Object error, BuildContext context) {
    return error.toString();
  }
}
