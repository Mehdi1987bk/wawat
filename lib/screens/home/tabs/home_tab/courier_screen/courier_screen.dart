import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_documents_tab.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_offers_tab.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_profile_card.dart';
import 'package:buking/screens/home/tabs/home_tab/courier_screen/widget/courier_ratings_tab.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/offer_models.dart';
import '../../../../../data/network/response/partner_user_response.dart';
import 'courier_details_bloc.dart';

class CourierDetailsScreen extends BaseScreen {
  final OfferModel courier;

  CourierDetailsScreen({
    Key? key,
    required this.courier,
  }) : super(key: key);

  @override
  State<CourierDetailsScreen> createState() => _CourierDetailsScreenState();
}

class _CourierDetailsScreenState
    extends BaseState<CourierDetailsScreen, CourierDetailsBloc> {
  int _selectedTab = 0;

  @override
  Widget body() {
    return SafeArea(
      child: FutureBuilder<PartnerUserResponse>(
        future: bloc.getUserById(widget.courier.user?.id ?? 0),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 16),
                  CourierProfileCard(data: data),
                  const SizedBox(height: 16),
                  _buildTabButtons(),
                  const SizedBox(height: 16),
                  _buildTabContent(data),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF5B5BFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Написать',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabButton(index: 0, icon: Icons.description),
          _buildTabButton(index: 1, icon: Icons.star_outline),
          _buildTabButton(index: 2, icon: Icons.location_on_outlined),
        ],
      ),
    );
  }

  Widget _buildTabButton({required int index, required IconData icon}) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
            isSelected ? const Color(0xFF5B5BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[400],
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Data data) {
    switch (_selectedTab) {
      case 0:
        return CourierDocumentsTab(data: data);
      case 1:
        return CourierRatingsTab(data: data);
      case 2:
        return CourierOffersTab(data: data);
      default:
        return const SizedBox();
    }
  }

  @override
  CourierDetailsBloc provideBloc() {
    return CourierDetailsBloc();
  }
}