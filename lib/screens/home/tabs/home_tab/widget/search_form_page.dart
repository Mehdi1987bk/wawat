import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../wawat/screens/search_results_screen.dart';

class SearchFormWidget extends StatefulWidget {
  @override
  State<SearchFormWidget> createState() => _SearchFormWidgetState();
}

class _SearchFormWidgetState extends State<SearchFormWidget> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(text: 'Все категории');

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: _buildSearchForm(),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Откуда
          _buildFieldLabel('Откуда'),
          SizedBox(height: 10),
          _buildTextField(
            controller: _departureController,
            placeholder: 'Город отправления',
          ),
          SizedBox(height: 20),

          // Куда
          _buildFieldLabel('Куда'),
          SizedBox(height: 10),
          _buildTextField(
            controller: _arrivalController,
            placeholder: 'Город назначения',
          ),
          SizedBox(height: 20),

          // Дата с
          _buildFieldLabel('Дата с'),
          SizedBox(height: 10),
          _buildTextField(
            controller: _dateFromController,
            placeholder: 'ДД.МММ.ГГГГ',
          ),
          SizedBox(height: 20),

          // Дата по
          _buildFieldLabel('Дата по'),
          SizedBox(height: 10),
          _buildTextField(
            controller: _dateToController,
            placeholder: 'ДД.МММ.ГГГГ',
          ),
          SizedBox(height: 20),

          // Категория
          _buildFieldLabel('Категория'),
          SizedBox(height: 10),
          _buildCategoryField(),
          SizedBox(height: 28),

          // Кнопка поиск
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        height: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          fontSize: 16,
          color: Color(0xFFB0B0B0),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        fillColor: Color(0xFFFAFAFA),
        filled: true,
      ),
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildCategoryField() {
    return TextField(
      controller: _categoryController,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Icon(
            Icons.search,
            color: Color(0xFF7C6FFF),
            size: 20,
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(
            Icons.arrow_drop_down,
            color: Color(0xFFB0B0B0),
            size: 24,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        fillColor: Color(0xFFFAFAFA),
        filled: true,
      ),
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A5FFF), Color(0xFFB74CFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0x334A5FFF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        // onTap: () => Navigator.push(
        //   context,
        //   CupertinoPageRoute(
        //     builder: (BuildContext context) {
        //       return SearchResultsScreen();
        //     },
        //   ),
        // ),

        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Поиск',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
