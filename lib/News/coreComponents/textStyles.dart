import 'package:flutter/material.dart';

import 'appColors.dart';
import 'fontSize.dart';



class Family {
  static const String regular = "Poppins-Regular";
  static const String medium = "Poppins-Medium";
  static const String semiBold = "Poppins-SemiBold";
  static const String bold = "Poppins-Bold";
  static const String extraBold = "Poppins-ExtraBold";
}

class TextStyles {
  //Regular
  static const TextStyle regular10GreyText = TextStyle(
      color: AppColors.grey50,
      fontSize: S.s10,
      fontFamily: Family.regular);
  static const TextStyle regular12Black = TextStyle(
      color: AppColors.black,
      fontSize: S.s12,
      fontFamily: Family.regular);

  static const TextStyle regular14Black = TextStyle(
      color: AppColors.black,
      fontSize: S.s14,
      fontFamily: Family.regular);
  static const TextStyle regularTextHint = TextStyle(
      color: AppColors.grey50,
      fontSize: S.s14,
      fontFamily: Family.regular);
  static const TextStyle regular12Hint = TextStyle(
      color: AppColors.grey50,
      fontSize: S.s12,
      fontFamily: Family.regular);


  static const TextStyle regular16Black = TextStyle(
      color: AppColors.black,
      fontSize: S.s16,
      fontFamily: Family.regular);
  static const TextStyle regular14Charcoal= TextStyle(
      color: AppColors.charcoal,
      fontSize: S.s14,
      fontFamily: Family.regular);




  //medium
  static const TextStyle medium14Black = TextStyle(
      color: AppColors.black,
      fontSize: S.s14,
      fontFamily: Family.medium);

  static const TextStyle medium14White= TextStyle(
      color: AppColors.white,
      fontSize: S.s14,
      fontFamily: Family.medium);


  //SemiBold
  static const TextStyle semiBold16Black = TextStyle(
      color: AppColors.black,
      fontSize: S.s16,
      fontFamily: Family.semiBold);
  static const TextStyle semiBold20Black = TextStyle(
      color: AppColors.black,
      fontSize: S.s20,
      fontFamily: Family.semiBold);

//Bold

//extra Bold
}