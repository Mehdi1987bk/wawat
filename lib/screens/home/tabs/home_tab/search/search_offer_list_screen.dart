import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../profile_tab/widgte/delivery_card.dart';
import 'search_offer_bloc.dart';

class SearchOfferListScreen extends BaseScreen {
  final String? offerType;
  final String? packageType;
  final int? cityFromId;
  final int? cityToId;
  final String? dateFrom;
  final String? dateTo;

  SearchOfferListScreen({
    Key? key,
    this.offerType,
    this.packageType,
    this.cityFromId,
    this.cityToId,
    this.dateFrom,
    this.dateTo,
  }) : super(key: key);

  @override
  State<SearchOfferListScreen> createState() => _SearchOfferListScreenState();
}

class _SearchOfferListScreenState
    extends BaseState<SearchOfferListScreen, SearchOfferBloc> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Устанавливаем параметры поиска
    bloc.setSearchParams(
      offerType: widget.offerType,
      packageType: widget.packageType,
      cityFromId: widget.cityFromId,
      cityToId: widget.cityToId,
      dateFrom: widget.dateFrom,
      dateTo: widget.dateTo,
    );

    // Загружаем первую страницу
    bloc.load();

    // Добавляем listener для пагинации при скролле
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Загружаем следующую страницу когда пользователь приближается к концу списка
      bloc.load();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Результаты поиска',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget body() {
    return RefreshIndicator(
      onRefresh: () => bloc.load(refresh: true),
      color: const Color(0xFF7C6FFF),
      child: StreamBuilder<List<OfferModel>>(
        stream: bloc.paginableList,
        builder: (context, snapshot) {
          if (!snapshot.hasData && bloc.data.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C6FFF),
              ),
            );
          }

          final offers = snapshot.data ?? bloc.data;

          if (offers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: offers.length + 1, // +1 для индикатора загрузки
            itemBuilder: (context, index) {
              if (index == offers.length) {
                // Индикатор загрузки внизу списка
                return StreamBuilder<bool>(
                  stream: bloc.loadingStream,
                  builder: (context, loadingSnapshot) {
                    final isLoading = loadingSnapshot.data ?? false;
                    if (isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF7C6FFF),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              }

              final offer = offers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOfferCard(offer),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ничего не найдено',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Попробуйте изменить параметры поиска',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(OfferModel offer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с типом и иконкой
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A5FFF), Color(0xFFB74CFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  offer.packageType?.icon ?? '📦',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.offerType?.title ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        offer.packageType?.title ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${offer.pricePerKg}/кг',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Основная информация
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Маршрут
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF7C6FFF), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${offer.cityFrom?.name ?? ''} → ${offer.cityTo?.name ?? ''}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Дата
                if (offer.mainDate != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFB0B0B0), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(offer.mainDate!),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      if (offer.mainTime != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, color: Color(0xFFB0B0B0), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(offer.mainTime!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Вес
                Row(
                  children: [
                    const Icon(Icons.scale, color: Color(0xFFB0B0B0), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'До ${offer.maxWeightKg} кг',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),

                // Описание
                if (offer.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 12),
                  Text(
                    offer.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Информация о пользователе
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF7C6FFF).withOpacity(0.1),
                      child: Text(
                        offer.user?.fullname?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C6FFF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                offer.user?.fullname ?? 'Пользователь',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              if (offer.user?.isVerified ?? false) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF7C6FFF),
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          if ((offer.user?.ratingAvg ?? 0) > 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFFFA726), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${offer.user?.ratingAvg?.toStringAsFixed(1)} (${offer.user?.ratingCount ?? 0})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFB0B0B0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      offer.isFavourite ?? false
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: offer.isFavourite ?? false
                          ? Colors.red
                          : Color(0xFFB0B0B0),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }

  @override
  SearchOfferBloc provideBloc() {
    return SearchOfferBloc();
  }
}
