import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cache/cache_helper.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ar'));

  void loadSavedLocale() {
    final bool isAr = CacheHelper.isArabic;
    emit(Locale(isAr ? 'ar' : 'en'));
  }

  Future<void> toggleLanguage() async {
    final bool currentlyAr = state.languageCode == 'ar';
    final bool nextIsAr = !currentlyAr;
    await CacheHelper.setIsArabic(nextIsAr);
    emit(Locale(nextIsAr ? 'ar' : 'en'));
  }
}
