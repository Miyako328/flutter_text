import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SearchController extends GetxController {
  final List<String> suggestions = [
    'United States',
    'Germany',
    'Washington',
    'Paris',
    'Jakarta',
    'Australia',
    'India',
    'Czech Republic',
    'Lorem Ipsum',
  ];
  
  final List<String> statesOfIndia = [
    'Andhra Pradesh',
    'Assam',
    'Arunachal Pradesh',
    'Bihar',
    'Goa',
    'Gujarat',
    'Jammu and Kashmir',
    'Jharkhand',
    'West Bengal',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Orissa',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Tripura',
    'Uttaranchal',
    'Uttar Pradesh',
    'Haryana',
    'Himachal Pradesh',
    'Chhattisgarh'
  ];
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();
  
  RxString searchQuery = ''.obs;
  RxList<String> filteredSuggestions = <String>[].obs;
  RxBool isSearching = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    filteredSuggestions.value = suggestions;
  }
  
  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredSuggestions.value = suggestions;
    } else {
      filteredSuggestions.value = suggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
  
  void performSearch() {
    isSearching.value = true;
    // 模拟搜索延迟
    Future.delayed(Duration(milliseconds: 500), () {
      isSearching.value = false;
    });
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
