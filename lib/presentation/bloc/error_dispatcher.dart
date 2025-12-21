import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../resourses/app_colors.dart';
import '../../services/theme_manager.dart';
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
      if (error is DioException) {
        final response = error.response;
        final data = response?.data;
        String message = "Something went wrong";

        print("🔍 [ErrorDispatcher] StatusCode: ${response?.statusCode}");
        print("🔍 [ErrorDispatcher] Data type: ${data.runtimeType}");
        print("🔍 [ErrorDispatcher] Data: $data");

        // ✅ Обработка JSON с ключом "message"
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data.containsKey('error')) {
            message = data['error'].toString();
          } else {
            // Если есть другие ключи, показываем первый
            message = data.values.first.toString();
          }
        }
        // ✅ Обработка простой строки
        else if (data is String && data.isNotEmpty) {
          message = data.trim();
        }
        // ✅ Обработка списка ошибок валидации
        else if (data is List && data.isNotEmpty) {
          message = data.first.toString();
        }

        showTopSnackbar(message, false, context);
        print("❌ [ErrorDispatcher] DioException: $message");
        return;
      }

      // ✅ Обработка других ошибок
      showTopSnackbar(error.toString(), false, context);
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
/// Показывает красивый snackbar сверху экрана с поддержкой темной/светлой темы
///
void showTopSnackbar(
    String message,
    bool isSuccess,
    BuildContext context,
    ) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  // Определяем текущую тему через Provider (как в create_post_screen)
  final isDark = Provider.of<ThemeManager>(context, listen: false).isDarkMode;

  final controller = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 400),
  );

  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final slideValue = Curves.easeOutBack.transform(controller.value);

        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Transform.translate(
            offset: Offset(0, -100 * (1 - slideValue)),
            child: Opacity(
              opacity: controller.value,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -10) {
                    controller.reverse().then((_) {
                      if (overlayEntry.mounted) {
                        overlayEntry.remove();
                      }
                    });
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSuccess
                            ? const Color(0xFF5B51FF).withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? const Color(0xFF5B51FF).withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSuccess ? Icons.check_circle : Icons.error,
                              color: isSuccess
                                  ? const Color(0xFF5B51FF)
                                  : Colors.red,
                              size: 24,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              top: 16,
                              bottom: 16,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSuccess ? 'Успешно!' : 'Ошибка',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFB0B0B0)
                                        : const Color(0xFF8E8E93),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFFC7C7CC),
                            size: 20,
                          ),
                          onPressed: () {
                            controller.reverse().then((_) {
                              if (overlayEntry.mounted) {
                                overlayEntry.remove();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  overlay.insert(overlayEntry);
  controller.forward();

  Future.delayed(const Duration(seconds: 4), () {
    if (overlayEntry.mounted) {
      controller.reverse().then((_) {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  });
}