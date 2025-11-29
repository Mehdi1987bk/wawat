import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../profile_tab/widgte/delivery_card.dart';
import '../widget/auth_modal_utils.dart';
import '../widget/wawat_courier_card.dart';
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
            padding: const EdgeInsets.only(top: 20,bottom: 20),
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
              return WawatCourierCard(
                courier: offer,
                onDetails: () async {
                  final isLogged = await sl.get<AuthRepository>().isLogged();
                  if (!isLogged) {
                    return AuthModalUtils.showAuthRequiredModal(context);
                  } else {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return Container(
                            child: Text("Details"),
                          );
                        },
                      ),
                    );
                  }
                },
                onMessage: () async {
                  final isLogged = await sl.get<AuthRepository>().isLogged();
                  if (!isLogged) {
                    return AuthModalUtils.showAuthRequiredModal(context);
                  } else {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return Container(
                            child: Text("Messagesss"),
                          );
                        },
                      ),
                    );
                  }
                },
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




  @override
  SearchOfferBloc provideBloc() {
    return SearchOfferBloc();
  }
}
