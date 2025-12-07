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
  final int courierId;

  CourierDetailsScreen({
    Key? key,
    required this.courierId,
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
        future: bloc.getUserById(widget.courierId ?? 0),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.requireData.data;
            return SingleChildScrollView(
              child: Column(
                children: [
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