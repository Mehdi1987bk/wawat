import 'package:flutter/material.dart';
import 'dart:io';

/// Виджет профильного изображения с градиентом и кнопкой камеры
///
/// Параметры:
/// - [imageUrl] - ссылка на изображение из сети
/// - [localFile] - локальный файл с изображением
/// - [onCameraPressed] - callback при нажатии на кнопку камеры
/// - [size] - размер виджета (по умолчанию 120)
/// - [borderRadius] - радиус скругления (по умолчанию 24)
/// - [cameraIconSize] - размер иконки камеры (по умолчанию 20)
///
/// Пример использования:
/// ```dart
/// ProfileImageWidget(
///   imageUrl: 'https://example.com/image.jpg',
///   onCameraPressed: () {
///     // Обработка нажатия на камеру
///   },
/// )
/// ```
class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final VoidCallback onCameraPressed;
  final double size;
  final double borderRadius;
  final double cameraIconSize;
  final bool showShadow;

  const ProfileImageWidget({
    Key? key,
    this.imageUrl,
    this.localFile,
    required this.onCameraPressed,
    this.size = 120,
    this.borderRadius = 24,
    this.cameraIconSize = 20,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCameraPressed,
      child: Stack(
        children: [
          // Основной контейнер с градиентом
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B4FFF), Color(0xFFD946EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: showShadow
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5B4FFF).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: _buildImageContent(),
            ),
          ),
          // Кнопка камеры
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF5B4FFF),
                borderRadius: BorderRadius.circular(borderRadius / 2),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: showShadow
                    ? [
                        BoxShadow(
                          color: const Color(0xFF5B4FFF).withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              padding: EdgeInsets.all(size / 15),
              child: Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: cameraIconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Вспомогательный метод для отображения контента
  Widget _buildImageContent() {
    // Приоритет: локальный файл > сетевое изображение > placeholder
    if (localFile != null && localFile!.existsSync()) {
      return Image.file(
        localFile!,
        key: ValueKey(localFile!.path),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        key: ValueKey(imageUrl!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B4FFF), Color(0xFFD946EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B4FFF), Color(0xFFD946EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.image,
              size: 50,
              color: Colors.white38,
            ),
          );
        },
      );
    } else {
      // Placeholder
      return Container(
        alignment: Alignment.center,
        child: Icon(
          Icons.person,
          size: size * 0.5,
          color: Colors.white,
        ),
      );
    }
  }
}
