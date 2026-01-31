// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection`
  String get noInternetConnection {
    return Intl.message(
      'No internet connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Login to account`
  String get LoginQiris {
    return Intl.message(
      'Login to account',
      name: 'LoginQiris',
      desc: '',
      args: [],
    );
  }

  /// `In publishing and graphic design, Lorem ipsum is a placeholder text commonly`
  String get loginDescribtion {
    return Intl.message(
      'In publishing and graphic design, Lorem ipsum is a placeholder text commonly',
      name: 'loginDescribtion',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get emailAddresiniziDaxilEdin {
    return Intl.message(
      'Enter your email address',
      name: 'emailAddresiniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get ifrniziDaxilEdin {
    return Intl.message(
      'Enter your password',
      name: 'ifrniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password`
  String get ifrmiUnutdum {
    return Intl.message(
      'Forgot password',
      name: 'ifrmiUnutdum',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get rli {
    return Intl.message('Next', name: 'rli', desc: '', args: []);
  }

  /// `Email address`
  String get emailAdres {
    return Intl.message(
      'Email address',
      name: 'emailAdres',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Register`
  String get qeydiyyatdanKein {
    return Intl.message(
      'Register',
      name: 'qeydiyyatdanKein',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get ifr {
    return Intl.message('Password', name: 'ifr', desc: '', args: []);
  }

  /// `Forgot password`
  String get ifrmiUnutmusam {
    return Intl.message(
      'Forgot password',
      name: 'ifrmiUnutmusam',
      desc: '',
      args: [],
    );
  }

  /// `Hello`
  String get salam {
    return Intl.message('Hello', name: 'salam', desc: '', args: []);
  }

  /// `We wish you happy shopping today`
  String get buGnSizXoAlverilrArzuEdirik {
    return Intl.message(
      'We wish you happy shopping today',
      name: 'buGnSizXoAlverilrArzuEdirik',
      desc: '',
      args: [],
    );
  }

  /// `Product code`
  String get mhsulunKodu {
    return Intl.message(
      'Product code',
      name: 'mhsulunKodu',
      desc: '',
      args: [],
    );
  }

  /// `Status:`
  String get status {
    return Intl.message('Status:', name: 'status', desc: '', args: []);
  }

  /// `SC status: `
  String get scStatus {
    return Intl.message('SC status: ', name: 'scStatus', desc: '', args: []);
  }

  /// `Price: `
  String get qiymt {
    return Intl.message('Price: ', name: 'qiymt', desc: '', args: []);
  }

  /// `Cargo weight: `
  String get kargoKisi {
    return Intl.message(
      'Cargo weight: ',
      name: 'kargoKisi',
      desc: '',
      args: [],
    );
  }

  /// `Product link`
  String get mhsulunLinki {
    return Intl.message(
      'Product link',
      name: 'mhsulunLinki',
      desc: '',
      args: [],
    );
  }

  /// `Place order`
  String get sifariVer {
    return Intl.message('Place order', name: 'sifariVer', desc: '', args: []);
  }

  /// `Invoice`
  String get fakturaLavEt {
    return Intl.message('Invoice', name: 'fakturaLavEt', desc: '', args: []);
  }

  /// `Choose Image`
  String get chooseImage {
    return Intl.message(
      'Choose Image',
      name: 'chooseImage',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Download`
  String get endirin {
    return Intl.message('Download', name: 'endirin', desc: '', args: []);
  }

  /// `My packages`
  String get balamalarm {
    return Intl.message('My packages', name: 'balamalarm', desc: '', args: []);
  }

  /// `All my packages`
  String get btnBalamalarm {
    return Intl.message(
      'All my packages',
      name: 'btnBalamalarm',
      desc: '',
      args: [],
    );
  }

  /// `Store: `
  String get maaza {
    return Intl.message('Store: ', name: 'maaza', desc: '', args: []);
  }

  /// `Product type: `
  String get mhsulunTipi {
    return Intl.message(
      'Product type: ',
      name: 'mhsulunTipi',
      desc: '',
      args: [],
    );
  }

  /// `Shipping cost: `
  String get kargoQiymti {
    return Intl.message(
      'Shipping cost: ',
      name: 'kargoQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get qeyd {
    return Intl.message('Note', name: 'qeyd', desc: '', args: []);
  }

  /// `Pay`
  String get dniEdin {
    return Intl.message('Pay', name: 'dniEdin', desc: '', args: []);
  }

  /// `Please grant accessing storage permission to continue`
  String get pleaseGrantAccessingStoragePermissionToContinue {
    return Intl.message(
      'Please grant accessing storage permission to continue',
      name: 'pleaseGrantAccessingStoragePermissionToContinue',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Add`
  String get lavEt {
    return Intl.message('Add', name: 'lavEt', desc: '', args: []);
  }

  /// `Code`
  String get kod {
    return Intl.message('Code', name: 'kod', desc: '', args: []);
  }

  /// `Add invoice code`
  String get fakturaKodunuLavEdin {
    return Intl.message(
      'Add invoice code',
      name: 'fakturaKodunuLavEdin',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get dzli {
    return Intl.message('Edit', name: 'dzli', desc: '', args: []);
  }

  /// `KGO9920xxxxxx`
  String get kgo9920xxxxxx {
    return Intl.message(
      'KGO9920xxxxxx',
      name: 'kgo9920xxxxxx',
      desc: '',
      args: [],
    );
  }

  /// `Product price (TL)`
  String get mhsulunQiymtiTl {
    return Intl.message(
      'Product price (TL)',
      name: 'mhsulunQiymtiTl',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get qiymti {
    return Intl.message('Price', name: 'qiymti', desc: '', args: []);
  }

  /// `Invoice`
  String get faktura {
    return Intl.message('Invoice', name: 'faktura', desc: '', args: []);
  }

  /// `Details`
  String get trafl {
    return Intl.message('Details', name: 'trafl', desc: '', args: []);
  }

  /// `Invoice amount`
  String get fakturaQiymti {
    return Intl.message(
      'Invoice amount',
      name: 'fakturaQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Cargo tracking NO.`
  String get kargoTakipNo {
    return Intl.message(
      'Cargo tracking NO.',
      name: 'kargoTakipNo',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get ki {
    return Intl.message('Weight', name: 'ki', desc: '', args: []);
  }

  /// `Delivery`
  String get atdrlma {
    return Intl.message('Delivery', name: 'atdrlma', desc: '', args: []);
  }

  /// `Product quantity`
  String get mhsulunSay {
    return Intl.message(
      'Product quantity',
      name: 'mhsulunSay',
      desc: '',
      args: [],
    );
  }

  /// `Additional services`
  String get lavXidmtlr {
    return Intl.message(
      'Additional services',
      name: 'lavXidmtlr',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get kateqoriya {
    return Intl.message('Category', name: 'kateqoriya', desc: '', args: []);
  }

  /// `Payment`
  String get dm {
    return Intl.message('Payment', name: 'dm', desc: '', args: []);
  }

  /// `SC status`
  String get scStatuss {
    return Intl.message('SC status', name: 'scStatuss', desc: '', args: []);
  }

  /// `Status`
  String get statuss {
    return Intl.message('Status', name: 'statuss', desc: '', args: []);
  }

  /// `Operations`
  String get mliyyatlar {
    return Intl.message('Operations', name: 'mliyyatlar', desc: '', args: []);
  }

  /// `Add invoice`
  String get fakturaLavEdin {
    return Intl.message(
      'Add invoice',
      name: 'fakturaLavEdin',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get yaddaSaxla {
    return Intl.message('Save', name: 'yaddaSaxla', desc: '', args: []);
  }

  /// `Packages`
  String get balamalar {
    return Intl.message('Packages', name: 'balamalar', desc: '', args: []);
  }

  /// `Orders`
  String get sifarilr {
    return Intl.message('Orders', name: 'sifarilr', desc: '', args: []);
  }

  /// `Order courier`
  String get kuryerSifariEt {
    return Intl.message(
      'Order courier',
      name: 'kuryerSifariEt',
      desc: '',
      args: [],
    );
  }

  /// `My services`
  String get xidmtlrimi {
    return Intl.message('My services', name: 'xidmtlrimi', desc: '', args: []);
  }

  /// `Login`
  String get giriEt {
    return Intl.message('Login', name: 'giriEt', desc: '', args: []);
  }

  /// `Other sections`
  String get digrBlmlr {
    return Intl.message(
      'Other sections',
      name: 'digrBlmlr',
      desc: '',
      args: [],
    );
  }

  /// `Your balance`
  String get balansnz {
    return Intl.message('Your balance', name: 'balansnz', desc: '', args: []);
  }

  /// `AZN balance`
  String get aznBalans {
    return Intl.message('AZN balance', name: 'aznBalans', desc: '', args: []);
  }

  /// `250.0`
  String get aznnnn {
    return Intl.message('250.0', name: 'aznnnn', desc: '', args: []);
  }

  /// `TL balance`
  String get tlBalans {
    return Intl.message('TL balance', name: 'tlBalans', desc: '', args: []);
  }

  /// `Personal account`
  String get xsiKabinet {
    return Intl.message(
      'Personal account',
      name: 'xsiKabinet',
      desc: '',
      args: [],
    );
  }

  /// `© 2021 Kango | All Rights Reserved`
  String get oluxBtnHquqlarQorunur {
    return Intl.message(
      '© 2021 Kango | All Rights Reserved',
      name: 'oluxBtnHquqlarQorunur',
      desc: '',
      args: [],
    );
  }

  /// `My personal information`
  String get xsiMlumatlarm {
    return Intl.message(
      'My personal information',
      name: 'xsiMlumatlarm',
      desc: '',
      args: [],
    );
  }

  /// `My foreign addresses`
  String get xariciNvanlarm {
    return Intl.message(
      'My foreign addresses',
      name: 'xariciNvanlarm',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get ifrniDyi {
    return Intl.message(
      'Change password',
      name: 'ifrniDyi',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get xEt {
    return Intl.message('Log out', name: 'xEt', desc: '', args: []);
  }

  /// `Courier order`
  String get kuryerSifarii {
    return Intl.message(
      'Courier order',
      name: 'kuryerSifarii',
      desc: '',
      args: [],
    );
  }

  /// `Online shipping payment`
  String get onlaynDamaHaqqDnii {
    return Intl.message(
      'Online shipping payment',
      name: 'onlaynDamaHaqqDnii',
      desc: '',
      args: [],
    );
  }

  /// `Tariffs`
  String get tariflr {
    return Intl.message('Tariffs', name: 'tariflr', desc: '', args: []);
  }

  /// `News`
  String get xbrlr {
    return Intl.message('News', name: 'xbrlr', desc: '', args: []);
  }

  /// `Kango branches`
  String get kangoFiliallar {
    return Intl.message(
      'Kango branches',
      name: 'kangoFiliallar',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get laq {
    return Intl.message('Contact', name: 'laq', desc: '', args: []);
  }

  /// `History`
  String get tarixsi {
    return Intl.message('History', name: 'tarixsi', desc: '', args: []);
  }

  /// `Courier tariffs`
  String get kuryerTariflri {
    return Intl.message(
      'Courier tariffs',
      name: 'kuryerTariflri',
      desc: '',
      args: [],
    );
  }

  /// `Express delivery service`
  String get srtliPotDamaXidmti {
    return Intl.message(
      'Express delivery service',
      name: 'srtliPotDamaXidmti',
      desc: '',
      args: [],
    );
  }

  /// `Within Baku city`
  String get bakHrDaxili {
    return Intl.message(
      'Within Baku city',
      name: 'bakHrDaxili',
      desc: '',
      args: [],
    );
  }

  /// `Baku suburbs`
  String get bakKndlri {
    return Intl.message('Baku suburbs', name: 'bakKndlri', desc: '', args: []);
  }

  /// `Kango Tel: 012 525 43 43`
  String get kangoTel0125254343 {
    return Intl.message(
      'Kango Tel: 012 525 43 43',
      name: 'kangoTel0125254343',
      desc: '',
      args: [],
    );
  }

  /// `Note: You will pay the courier in cash upon delivery`
  String get qeydKuryerDiniNdKildBalamanzAtdranKuryerDycksiniz {
    return Intl.message(
      'Note: You will pay the courier in cash upon delivery',
      name: 'qeydKuryerDiniNdKildBalamanzAtdranKuryerDycksiniz',
      desc: '',
      args: [],
    );
  }

  /// `Courier order is only available for Narimanov branch`
  String get kuryerSifariiSadcNrimanovFilialNKerlidir {
    return Intl.message(
      'Courier order is only available for Narimanov branch',
      name: 'kuryerSifariiSadcNrimanovFilialNKerlidir',
      desc: '',
      args: [],
    );
  }

  /// `Enter your address`
  String get nvannzQeydEdin {
    return Intl.message(
      'Enter your address',
      name: 'nvannzQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Your name`
  String get adnz {
    return Intl.message('Your name', name: 'adnz', desc: '', args: []);
  }

  /// `Enter your name`
  String get adnzDaxilEdin {
    return Intl.message(
      'Enter your name',
      name: 'adnzDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Your surname`
  String get soyadnz {
    return Intl.message('Your surname', name: 'soyadnz', desc: '', args: []);
  }

  /// `Enter your surname`
  String get soyadnzDaxilEdin {
    return Intl.message(
      'Enter your surname',
      name: 'soyadnzDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Date of birth`
  String get doumTarixiniz {
    return Intl.message(
      'Date of birth',
      name: 'doumTarixiniz',
      desc: '',
      args: [],
    );
  }

  /// `Your gender`
  String get cinsiniz {
    return Intl.message('Your gender', name: 'cinsiniz', desc: '', args: []);
  }

  /// `Your email address`
  String get emailAdresiniz {
    return Intl.message(
      'Your email address',
      name: 'emailAdresiniz',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address`
  String get emailAdresiniziDaxilEdin {
    return Intl.message(
      'Enter your email address',
      name: 'emailAdresiniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Enter your date of birth`
  String get doumTarixiniziQeydEdin {
    return Intl.message(
      'Enter your date of birth',
      name: 'doumTarixiniziQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get kii {
    return Intl.message('Male', name: 'kii', desc: '', args: []);
  }

  /// `Female`
  String get qadn {
    return Intl.message('Female', name: 'qadn', desc: '', args: []);
  }

  /// `Add invoice`
  String get fakturaLavEtcsa {
    return Intl.message(
      'Add invoice',
      name: 'fakturaLavEtcsa',
      desc: '',
      args: [],
    );
  }

  /// `Cargo number`
  String get kargoNmrsi {
    return Intl.message('Cargo number', name: 'kargoNmrsi', desc: '', args: []);
  }

  /// `Confirm`
  String get tsdiqEt {
    return Intl.message('Confirm', name: 'tsdiqEt', desc: '', args: []);
  }

  /// `Confirm and order`
  String get tsdiqlVSifariEt {
    return Intl.message(
      'Confirm and order',
      name: 'tsdiqlVSifariEt',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get anaShif {
    return Intl.message('Home', name: 'anaShif', desc: '', args: []);
  }

  /// `Our tariffs -`
  String get tariflrimiz {
    return Intl.message(
      'Our tariffs -',
      name: 'tariflrimiz',
      desc: '',
      args: [],
    );
  }

  /// `Delivery from Turkey`
  String get trkiydnAtdrlma {
    return Intl.message(
      'Delivery from Turkey',
      name: 'trkiydnAtdrlma',
      desc: '',
      args: [],
    );
  }

  /// `For Baku and Sumgait cities`
  String get bakVSumqaytHrlriZr {
    return Intl.message(
      'For Baku and Sumgait cities',
      name: 'bakVSumqaytHrlriZr',
      desc: '',
      args: [],
    );
  }

  /// `For Ganja, Mingachevir and Lankaran cities`
  String get gncMingevirVLnkranHrlriZr {
    return Intl.message(
      'For Ganja, Mingachevir and Lankaran cities',
      name: 'gncMingevirVLnkranHrlriZr',
      desc: '',
      args: [],
    );
  }

  /// `Standard delivery and liquid products`
  String get standartAtdrlmaVMayeMhsullarZr {
    return Intl.message(
      'Standard delivery and liquid products',
      name: 'standartAtdrlmaVMayeMhsullarZr',
      desc: '',
      args: [],
    );
  }

  /// `VOLUMETRIC products`
  String get hcmslMhsullarZr {
    return Intl.message(
      'VOLUMETRIC products',
      name: 'hcmslMhsullarZr',
      desc: '',
      args: [],
    );
  }

  /// `Packages with a total of three sides (width, length, height) exceeding 1 meter are calculated as volumetric weight. Volumetric weight = Width x Length x Height / 6000. Currently volumetric weight is not calculated.`
  String get trfininEnUzunluHndrlkCmi1MetrdnOxOlanBalamalar {
    return Intl.message(
      'Packages with a total of three sides (width, length, height) exceeding 1 meter are calculated as volumetric weight. Volumetric weight = Width x Length x Height / 6000. Currently volumetric weight is not calculated.',
      name: 'trfininEnUzunluHndrlkCmi1MetrdnOxOlanBalamalar',
      desc: '',
      args: [],
    );
  }

  /// `0 gr - 100 gr`
  String get Qr100Qrc {
    return Intl.message('0 gr - 100 gr', name: 'Qr100Qrc', desc: '', args: []);
  }

  /// `101 gr - 250 gr`
  String get Qr250Qr {
    return Intl.message('101 gr - 250 gr', name: 'Qr250Qr', desc: '', args: []);
  }

  /// `251 gr - 500 gr`
  String get Qr500Qr {
    return Intl.message('251 gr - 500 gr', name: 'Qr500Qr', desc: '', args: []);
  }

  /// `501 gr - 1 kg`
  String get Qr1Kq {
    return Intl.message('501 gr - 1 kg', name: 'Qr1Kq', desc: '', args: []);
  }

  /// `Over 1 kg`
  String get KqZrind {
    return Intl.message('Over 1 kg', name: 'KqZrind', desc: '', args: []);
  }

  /// `Repeat password`
  String get tkrarIfrniz {
    return Intl.message(
      'Repeat password',
      name: 'tkrarIfrniz',
      desc: '',
      args: [],
    );
  }

  /// `Re-enter the password you set`
  String get tyinEtdiyinizGiriIfrsiniTkrarDaxilEdin {
    return Intl.message(
      'Re-enter the password you set',
      name: 'tyinEtdiyinizGiriIfrsiniTkrarDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Your password`
  String get ifrniz {
    return Intl.message('Your password', name: 'ifrniz', desc: '', args: []);
  }

  /// `Set your login password`
  String get giriIfrniziTyinEdin {
    return Intl.message(
      'Set your login password',
      name: 'giriIfrniziTyinEdin',
      desc: '',
      args: [],
    );
  }

  /// `Your mobile number`
  String get mobilNmrniz {
    return Intl.message(
      'Your mobile number',
      name: 'mobilNmrniz',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get cins {
    return Intl.message('Gender', name: 'cins', desc: '', args: []);
  }

  /// `Store`
  String get maazae {
    return Intl.message('Store', name: 'maazae', desc: '', args: []);
  }

  /// `kg`
  String get kq {
    return Intl.message('kg', name: 'kq', desc: '', args: []);
  }

  /// `Store`
  String get maazavd {
    return Intl.message('Store', name: 'maazavd', desc: '', args: []);
  }

  /// `TL`
  String get tl {
    return Intl.message('TL', name: 'tl', desc: '', args: []);
  }

  /// `Package:`
  String get balama {
    return Intl.message('Package:', name: 'balama', desc: '', args: []);
  }

  /// `Name, Surname:`
  String get adSoyad {
    return Intl.message('Name, Surname:', name: 'adSoyad', desc: '', args: []);
  }

  /// `Address:`
  String get nvan {
    return Intl.message('Address:', name: 'nvan', desc: '', args: []);
  }

  /// `Back`
  String get geri {
    return Intl.message('Back', name: 'geri', desc: '', args: []);
  }

  /// `ID card serial number`
  String get xsiyytVsiqsininSeriyaNmrsi {
    return Intl.message(
      'ID card serial number',
      name: 'xsiyytVsiqsininSeriyaNmrsi',
      desc: '',
      args: [],
    );
  }

  /// `ID card FIN code`
  String get xsiyytVsiqsininFnKodu {
    return Intl.message(
      'ID card FIN code',
      name: 'xsiyytVsiqsininFnKodu',
      desc: '',
      args: [],
    );
  }

  /// `Select branch`
  String get filialSein {
    return Intl.message(
      'Select branch',
      name: 'filialSein',
      desc: '',
      args: [],
    );
  }

  /// `ID serial number`
  String get vNinSeriyaNmrsi {
    return Intl.message(
      'ID serial number',
      name: 'vNinSeriyaNmrsi',
      desc: '',
      args: [],
    );
  }

  /// `Enter your address`
  String get nvannzDaxilEdin {
    return Intl.message(
      'Enter your address',
      name: 'nvannzDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `A letter about the next step has been sent to the email you entered!`
  String get daxilEtdiyini {
    return Intl.message(
      'A letter about the next step has been sent to the email you entered!',
      name: 'daxilEtdiyini',
      desc: '',
      args: [],
    );
  }

  /// `+994 12 525 43 43`
  String get number1 {
    return Intl.message(
      '+994 12 525 43 43',
      name: 'number1',
      desc: '',
      args: [],
    );
  }

  /// `Our phone numbers`
  String get telefonNmrlrimiz {
    return Intl.message(
      'Our phone numbers',
      name: 'telefonNmrlrimiz',
      desc: '',
      args: [],
    );
  }

  /// `+994 50 253 8907`
  String get number2 {
    return Intl.message(
      '+994 50 253 8907',
      name: 'number2',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get nvand {
    return Intl.message('Address', name: 'nvand', desc: '', args: []);
  }

  /// `Baku city, Narimanov district, Agha Neymatulla st. 44/2 (next to Metropark shopping center)`
  String get bakHriNrimanovRayonuAaNeymatullaB442MetroparkTm {
    return Intl.message(
      'Baku city, Narimanov district, Agha Neymatulla st. 44/2 (next to Metropark shopping center)',
      name: 'bakHriNrimanovRayonuAaNeymatullaB442MetroparkTm',
      desc: '',
      args: [],
    );
  }

  /// `+994 50 253 89 07`
  String get number3 {
    return Intl.message(
      '+994 50 253 89 07',
      name: 'number3',
      desc: '',
      args: [],
    );
  }

  /// `My notifications`
  String get bildirilrim {
    return Intl.message(
      'My notifications',
      name: 'bildirilrim',
      desc: '',
      args: [],
    );
  }

  /// `Balance history`
  String get balansKemii {
    return Intl.message(
      'Balance history',
      name: 'balansKemii',
      desc: '',
      args: [],
    );
  }

  /// `Balance history`
  String get balansTarixsi {
    return Intl.message(
      'Balance history',
      name: 'balansTarixsi',
      desc: '',
      args: [],
    );
  }

  /// `Balance top-up`
  String get balansArtm {
    return Intl.message(
      'Balance top-up',
      name: 'balansArtm',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get bala {
    return Intl.message('Close', name: 'bala', desc: '', args: []);
  }

  /// `Top up balance`
  String get balansArtrn {
    return Intl.message(
      'Top up balance',
      name: 'balansArtrn',
      desc: '',
      args: [],
    );
  }

  /// `Enter the desired amount`
  String get stdiyinizMbliDaxilEdin {
    return Intl.message(
      'Enter the desired amount',
      name: 'stdiyinizMbliDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Deducted from TL balance`
  String get tlBalansnzdanXld {
    return Intl.message(
      'Deducted from TL balance',
      name: 'tlBalansnzdanXld',
      desc: '',
      args: [],
    );
  }

  /// `Added to TL balance`
  String get tlBalansnzaLavOlundu {
    return Intl.message(
      'Added to TL balance',
      name: 'tlBalansnzaLavOlundu',
      desc: '',
      args: [],
    );
  }

  /// `Added to AZN balance`
  String get aznBalansnzaLavOlundu {
    return Intl.message(
      'Added to AZN balance',
      name: 'aznBalansnzaLavOlundu',
      desc: '',
      args: [],
    );
  }

  /// `Deducted from AZN balance`
  String get aznBalansnzdanXld {
    return Intl.message(
      'Deducted from AZN balance',
      name: 'aznBalansnzdanXld',
      desc: '',
      args: [],
    );
  }

  /// `Product price`
  String get mhsulunQiymti {
    return Intl.message(
      'Product price',
      name: 'mhsulunQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Total amount`
  String get toplamMbl {
    return Intl.message('Total amount', name: 'toplamMbl', desc: '', args: []);
  }

  /// `Package consolidation`
  String get paketBirlesmesi {
    return Intl.message(
      'Package consolidation',
      name: 'paketBirlesmesi',
      desc: '',
      args: [],
    );
  }

  /// `Cargo value`
  String get kargoDyri {
    return Intl.message('Cargo value', name: 'kargoDyri', desc: '', args: []);
  }

  /// `Your order has been updated and saved`
  String get sifariinizYenilndiVYaddaaVerildi {
    return Intl.message(
      'Your order has been updated and saved',
      name: 'sifariinizYenilndiVYaddaaVerildi',
      desc: '',
      args: [],
    );
  }

  /// `Changes saved`
  String get dyiikliklrQeydAlnd {
    return Intl.message(
      'Changes saved',
      name: 'dyiikliklrQeydAlnd',
      desc: '',
      args: [],
    );
  }

  /// `Product`
  String get mhsul {
    return Intl.message('Product', name: 'mhsul', desc: '', args: []);
  }

  /// `Product size`
  String get mhsulunLs {
    return Intl.message('Product size', name: 'mhsulunLs', desc: '', args: []);
  }

  /// `Enter product size`
  String get mhsulunLsnQeydEdin {
    return Intl.message(
      'Enter product size',
      name: 'mhsulunLsnQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Enter product link`
  String get mhsulunLinkiniQeydEdin {
    return Intl.message(
      'Enter product link',
      name: 'mhsulunLinkiniQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `New product`
  String get yeniMhsul {
    return Intl.message('New product', name: 'yeniMhsul', desc: '', args: []);
  }

  /// `Enter product quantity`
  String get mhsulunSaynQeydEdin {
    return Intl.message(
      'Enter product quantity',
      name: 'mhsulunSaynQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Enter product price`
  String get mhsulunQiymtiQeydEdin {
    return Intl.message(
      'Enter product price',
      name: 'mhsulunQiymtiQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Other product details`
  String get mhsulunDigrDetallar {
    return Intl.message(
      'Other product details',
      name: 'mhsulunDigrDetallar',
      desc: '',
      args: [],
    );
  }

  /// `Enter other product details`
  String get mhsulunDigrDetallarnQeydEdin {
    return Intl.message(
      'Enter other product details',
      name: 'mhsulunDigrDetallarnQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get sifariEt {
    return Intl.message('Order', name: 'sifariEt', desc: '', args: []);
  }

  /// `When entering the product price, you must add the domestic Turkey shipping cost. Otherwise, the amount will be deducted from your balance upon purchase.`
  String get mhsulunQiymtiniQeydEdirknTrkiyDaxiliKargonuDaZrinGlib {
    return Intl.message(
      'When entering the product price, you must add the domestic Turkey shipping cost. Otherwise, the amount will be deducted from your balance upon purchase.',
      name: 'mhsulunQiymtiniQeydEdirknTrkiyDaxiliKargonuDaZrinGlib',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get geriy {
    return Intl.message('Back', name: 'geriy', desc: '', args: []);
  }

  /// `Total price`
  String get toplamQiymt {
    return Intl.message('Total price', name: 'toplamQiymt', desc: '', args: []);
  }

  /// `Total product price`
  String get mumiMhsulQiymti {
    return Intl.message(
      'Total product price',
      name: 'mumiMhsulQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Total service fee (3%)`
  String get mumiXidmtHaqq5 {
    return Intl.message(
      'Total service fee (3%)',
      name: 'mumiXidmtHaqq5',
      desc: '',
      args: [],
    );
  }

  /// `Total product quantity`
  String get mumiMhsulSay {
    return Intl.message(
      'Total product quantity',
      name: 'mumiMhsulSay',
      desc: '',
      args: [],
    );
  }

  /// `Urgent order`
  String get tciliSifari {
    return Intl.message(
      'Urgent order',
      name: 'tciliSifari',
      desc: '',
      args: [],
    );
  }

  /// `* Payment for additional services is made upon order delivery.`
  String get lavXidmtlrinDniiniSifariinThviliZamanEdilir {
    return Intl.message(
      '* Payment for additional services is made upon order delivery.',
      name: 'lavXidmtlrinDniiniSifariinThviliZamanEdilir',
      desc: '',
      args: [],
    );
  }

  /// `Selected services`
  String get seilmiXidmtlr {
    return Intl.message(
      'Selected services',
      name: 'seilmiXidmtlr',
      desc: '',
      args: [],
    );
  }

  /// `+1`
  String get one {
    return Intl.message('+1', name: 'one', desc: '', args: []);
  }

  /// `* The order amount will be determined when your cargo arrives at the Turkey office.`
  String get sifariinMbliKargonuzTrkiyOfisinAtdqdaBlliOlacaqdr {
    return Intl.message(
      '* The order amount will be determined when your cargo arrives at the Turkey office.',
      name: 'sifariinMbliKargonuzTrkiyOfisinAtdqdaBlliOlacaqdr',
      desc: '',
      args: [],
    );
  }

  /// `* Please accept the distance sales agreement.`
  String get zhmtOlmasaMsafliSatSzlmsiniQbulEdin {
    return Intl.message(
      '* Please accept the distance sales agreement.',
      name: 'zhmtOlmasaMsafliSatSzlmsiniQbulEdin',
      desc: '',
      args: [],
    );
  }

  /// `I accept the distance sales agreement.`
  String get msafliSatSzlmsiniQbulEdirm {
    return Intl.message(
      'I accept the distance sales agreement.',
      name: 'msafliSatSzlmsiniQbulEdirm',
      desc: '',
      args: [],
    );
  }

  /// `Add to cart`
  String get sbtLavEt {
    return Intl.message('Add to cart', name: 'sbtLavEt', desc: '', args: []);
  }

  /// `Pay`
  String get dniEt {
    return Intl.message('Pay', name: 'dniEt', desc: '', args: []);
  }

  /// `My cart`
  String get sbtim {
    return Intl.message('My cart', name: 'sbtim', desc: '', args: []);
  }

  /// `Quantity`
  String get say {
    return Intl.message('Quantity', name: 'say', desc: '', args: []);
  }

  /// `Size:`
  String get l {
    return Intl.message('Size:', name: 'l', desc: '', args: []);
  }

  /// `Personal information`
  String get xsiMlumatlar {
    return Intl.message(
      'Personal information',
      name: 'xsiMlumatlar',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get ad {
    return Intl.message('Name', name: 'ad', desc: '', args: []);
  }

  /// `Surname`
  String get soyad {
    return Intl.message('Surname', name: 'soyad', desc: '', args: []);
  }

  /// `Branch`
  String get filial {
    return Intl.message('Branch', name: 'filial', desc: '', args: []);
  }

  /// `Our branches`
  String get filiallarmz {
    return Intl.message(
      'Our branches',
      name: 'filiallarmz',
      desc: '',
      args: [],
    );
  }

  /// `Kango Tel:`
  String get kangoTel {
    return Intl.message('Kango Tel:', name: 'kangoTel', desc: '', args: []);
  }

  /// `You have no packages`
  String get sizinPaxdur {
    return Intl.message(
      'You have no packages',
      name: 'sizinPaxdur',
      desc: '',
      args: [],
    );
  }

  /// `Package added`
  String get paketElaveOlundu {
    return Intl.message(
      'Package added',
      name: 'paketElaveOlundu',
      desc: '',
      args: [],
    );
  }

  /// `Package has been added`
  String get paketLavEdilmidir {
    return Intl.message(
      'Package has been added',
      name: 'paketLavEdilmidir',
      desc: '',
      args: [],
    );
  }

  /// `Total price:`
  String get mumiQiymt {
    return Intl.message('Total price:', name: 'mumiQiymt', desc: '', args: []);
  }

  /// `You have no packages at Baku office`
  String get bakOfisindBalamalarnzYoxdur {
    return Intl.message(
      'You have no packages at Baku office',
      name: 'bakOfisindBalamalarnzYoxdur',
      desc: '',
      args: [],
    );
  }

  /// `Product weight:`
  String get mhsulunKisi {
    return Intl.message(
      'Product weight:',
      name: 'mhsulunKisi',
      desc: '',
      args: [],
    );
  }

  /// `Additional service:`
  String get lavXidmt {
    return Intl.message(
      'Additional service:',
      name: 'lavXidmt',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this product?`
  String get buMhsuluSimkIstdiyinizMinsiniz {
    return Intl.message(
      'Are you sure you want to delete this product?',
      name: 'buMhsuluSimkIstdiyinizMinsiniz',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get beli {
    return Intl.message('Yes', name: 'beli', desc: '', args: []);
  }

  /// `No`
  String get heir {
    return Intl.message('No', name: 'heir', desc: '', args: []);
  }

  /// `Online delivery`
  String get onlaynDama {
    return Intl.message(
      'Online delivery',
      name: 'onlaynDama',
      desc: '',
      args: [],
    );
  }

  /// `Head office address`
  String get nvanBaOfis {
    return Intl.message(
      'Head office address',
      name: 'nvanBaOfis',
      desc: '',
      args: [],
    );
  }

  /// `Our services`
  String get xidmetlerimiz {
    return Intl.message(
      'Our services',
      name: 'xidmetlerimiz',
      desc: '',
      args: [],
    );
  }

  /// `My orders`
  String get sifarilrim {
    return Intl.message('My orders', name: 'sifarilrim', desc: '', args: []);
  }

  /// `Tax number`
  String get vergiNumaras {
    return Intl.message('Tax number', name: 'vergiNumaras', desc: '', args: []);
  }

  /// `Mobile phone`
  String get mobilTelefon {
    return Intl.message(
      'Mobile phone',
      name: 'mobilTelefon',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get lke {
    return Intl.message('Country', name: 'lke', desc: '', args: []);
  }

  /// `District`
  String get semt {
    return Intl.message('District', name: 'semt', desc: '', args: []);
  }

  /// `Address title`
  String get adresBal {
    return Intl.message('Address title', name: 'adresBal', desc: '', args: []);
  }

  /// `District`
  String get le {
    return Intl.message('District', name: 'le', desc: '', args: []);
  }

  /// `ZIP/Post code`
  String get zippostKodu {
    return Intl.message(
      'ZIP/Post code',
      name: 'zippostKodu',
      desc: '',
      args: [],
    );
  }

  /// `My Turkey address`
  String get trkiyNvanm {
    return Intl.message(
      'My Turkey address',
      name: 'trkiyNvanm',
      desc: '',
      args: [],
    );
  }

  /// `Province - city`
  String get lEhir {
    return Intl.message('Province - city', name: 'lEhir', desc: '', args: []);
  }

  /// `Rejected`
  String get imtinaEdilib {
    return Intl.message('Rejected', name: 'imtinaEdilib', desc: '', args: []);
  }

  /// `Created`
  String get yaradilib {
    return Intl.message('Created', name: 'yaradilib', desc: '', args: []);
  }

  /// `Paid`
  String get odenisEdilib {
    return Intl.message('Paid', name: 'odenisEdilib', desc: '', args: []);
  }

  /// `At Turkey office`
  String get turkiyeOfisindedir {
    return Intl.message(
      'At Turkey office',
      name: 'turkiyeOfisindedir',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get alinib {
    return Intl.message('Received', name: 'alinib', desc: '', args: []);
  }

  /// `In transit`
  String get kargodadir {
    return Intl.message('In transit', name: 'kargodadir', desc: '', args: []);
  }

  /// `At Baku office`
  String get bakiOfisindedir {
    return Intl.message(
      'At Baku office',
      name: 'bakiOfisindedir',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get tehvilVerilib {
    return Intl.message('Delivered', name: 'tehvilVerilib', desc: '', args: []);
  }

  /// `Shipping paid`
  String get dasinmaHaqqiOdenilib {
    return Intl.message(
      'Shipping paid',
      name: 'dasinmaHaqqiOdenilib',
      desc: '',
      args: [],
    );
  }

  /// `Problem package`
  String get problemliBaglama {
    return Intl.message(
      'Problem package',
      name: 'problemliBaglama',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete?`
  String get silmkIstdiyinizMinsiniz {
    return Intl.message(
      'Are you sure you want to delete?',
      name: 'silmkIstdiyinizMinsiniz',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get rddEtmk {
    return Intl.message('Reject', name: 'rddEtmk', desc: '', args: []);
  }

  /// `I confirm`
  String get tesdiqEdirem {
    return Intl.message('I confirm', name: 'tesdiqEdirem', desc: '', args: []);
  }

  /// `Copied`
  String get kopyaland {
    return Intl.message('Copied', name: 'kopyaland', desc: '', args: []);
  }

  /// `Branches`
  String get filiallar {
    return Intl.message('Branches', name: 'filiallar', desc: '', args: []);
  }

  /// `Total product value`
  String get mumiMhsulDyri {
    return Intl.message(
      'Total product value',
      name: 'mumiMhsulDyri',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Kango family`
  String get kanqoAilsinXoGlmisiniz {
    return Intl.message(
      'Welcome to Kango family',
      name: 'kanqoAilsinXoGlmisiniz',
      desc: '',
      args: [],
    );
  }

  /// `Enter ID card FIN code`
  String get xsiyytVsiqsininFnKoduDaxilEdin {
    return Intl.message(
      'Enter ID card FIN code',
      name: 'xsiyytVsiqsininFnKoduDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Password (minimum 6 characters)`
  String get ifrnizMinimum6SimvolOlmaldr {
    return Intl.message(
      'Password (minimum 6 characters)',
      name: 'ifrnizMinimum6SimvolOlmaldr',
      desc: '',
      args: [],
    );
  }

  /// `You have no orders`
  String get sizinSifariinizYoxdur {
    return Intl.message(
      'You have no orders',
      name: 'sizinSifariinizYoxdur',
      desc: '',
      args: [],
    );
  }

  /// `You have no packages`
  String get sizinBalamanizYoxdur {
    return Intl.message(
      'You have no packages',
      name: 'sizinBalamanizYoxdur',
      desc: '',
      args: [],
    );
  }

  /// `Quick order`
  String get srtliSifari {
    return Intl.message('Quick order', name: 'srtliSifari', desc: '', args: []);
  }

  /// `Password mismatch`
  String get parolUyunsuzluu {
    return Intl.message(
      'Password mismatch',
      name: 'parolUyunsuzluu',
      desc: '',
      args: [],
    );
  }

  /// `Wrong password`
  String get parolShvdir {
    return Intl.message(
      'Wrong password',
      name: 'parolShvdir',
      desc: '',
      args: [],
    );
  }

  /// `Not selected`
  String get seilmyib {
    return Intl.message('Not selected', name: 'seilmyib', desc: '', args: []);
  }

  /// `Show number`
  String get nmrniGstr {
    return Intl.message('Show number', name: 'nmrniGstr', desc: '', args: []);
  }

  /// `Enter your number`
  String get nmrniziDaxilEdin {
    return Intl.message(
      'Enter your number',
      name: 'nmrniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `This number has been assigned to you`
  String get buNmrSizinNAyrld {
    return Intl.message(
      'This number has been assigned to you',
      name: 'buNmrSizinNAyrld',
      desc: '',
      args: [],
    );
  }

  /// `Attention! The app version has been updated. You need to update the app to continue.`
  String get diqqtTtbiqVersiyasYenilnmidirDavamEdBilmkNTtbiqiYenilmlisiniz {
    return Intl.message(
      'Attention! The app version has been updated. You need to update the app to continue.',
      name: 'diqqtTtbiqVersiyasYenilnmidirDavamEdBilmkNTtbiqiYenilmlisiniz',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get davamEtmk {
    return Intl.message('Continue', name: 'davamEtmk', desc: '', args: []);
  }

  /// `Update app`
  String get ttbiqiYenilyinmk {
    return Intl.message(
      'Update app',
      name: 'ttbiqiYenilyinmk',
      desc: '',
      args: [],
    );
  }

  /// `Neighborhood`
  String get mahalle {
    return Intl.message('Neighborhood', name: 'mahalle', desc: '', args: []);
  }

  /// `Delete profile`
  String get profiliSilmk {
    return Intl.message(
      'Delete profile',
      name: 'profiliSilmk',
      desc: '',
      args: [],
    );
  }

  /// `Dear customer, please note that by deleting your account, you will forfeit all packages associated with your account. You confirm this.`
  String get hrmtliMtriBildirmkIstyirikKiSizHesabiSilmekleHesabnzaBal {
    return Intl.message(
      'Dear customer, please note that by deleting your account, you will forfeit all packages associated with your account. You confirm this.',
      name: 'hrmtliMtriBildirmkIstyirikKiSizHesabiSilmekleHesabnzaBal',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languandff {
    return Intl.message('Language', name: 'languandff', desc: '', args: []);
  }

  /// `🟢 Verified`
  String get fvdgd {
    return Intl.message('🟢 Verified', name: 'fvdgd', desc: '', args: []);
  }

  /// `courier`
  String get frefd {
    return Intl.message('courier', name: 'frefd', desc: '', args: []);
  }

  /// `sender`
  String get fvvdf {
    return Intl.message('sender', name: 'fvvdf', desc: '', args: []);
  }

  /// `buyer`
  String get fvgbfdb {
    return Intl.message('buyer', name: 'fvgbfdb', desc: '', args: []);
  }

  /// `Continue`
  String get vfdvd {
    return Intl.message('Continue', name: 'vfdvd', desc: '', args: []);
  }

  /// `Find a courier who’s flying — send your parcel quickly and safely.\nFlying yourself? Carry parcels and earn money.`
  String get vvvvvf {
    return Intl.message(
      'Find a courier who’s flying — send your parcel quickly and safely.\nFlying yourself? Carry parcels and earn money.',
      name: 'vvvvvf',
      desc: '',
      args: [],
    );
  }

  /// `Fast and safe parcel delivery worldwide`
  String get r43 {
    return Intl.message(
      'Fast and safe parcel delivery worldwide',
      name: 'r43',
      desc: '',
      args: [],
    );
  }

  /// `Registration required`
  String get t54 {
    return Intl.message(
      'Registration required',
      name: 't54',
      desc: '',
      args: [],
    );
  }

  /// `To access this feature, you need to register or log in`
  String get rft43 {
    return Intl.message(
      'To access this feature, you need to register or log in',
      name: 'rft43',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get ffr4 {
    return Intl.message('Register', name: 'ffr4', desc: '', args: []);
  }

  /// `Log in`
  String get fr43 {
    return Intl.message('Log in', name: 'fr43', desc: '', args: []);
  }

  /// `Cancel`
  String get fre45 {
    return Intl.message('Cancel', name: 'fre45', desc: '', args: []);
  }

  /// `Enter email`
  String get email {
    return Intl.message('Enter email', name: 'email', desc: '', args: []);
  }

  /// `Code sent to $email`
  String get emailfre {
    return Intl.message(
      'Code sent to \$email',
      name: 'emailfre',
      desc: '',
      args: [],
    );
  }

  /// `Enter 6-digit code`
  String get rfred2 {
    return Intl.message(
      'Enter 6-digit code',
      name: 'rfred2',
      desc: '',
      args: [],
    );
  }

  /// `Password minimum 6 characters`
  String get vfd4 {
    return Intl.message(
      'Password minimum 6 characters',
      name: 'vfd4',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get vfdv3 {
    return Intl.message(
      'Passwords do not match',
      name: 'vfdv3',
      desc: '',
      args: [],
    );
  }

  /// `Password successfully changed!`
  String get rfewf43 {
    return Intl.message(
      'Password successfully changed!',
      name: 'rfewf43',
      desc: '',
      args: [],
    );
  }

  /// `Code resent`
  String get nhtf34 {
    return Intl.message('Code resent', name: 'nhtf34', desc: '', args: []);
  }

  /// `Enter code`
  String get vfd3 {
    return Intl.message('Enter code', name: 'vfd3', desc: '', args: []);
  }

  /// `Forgot password?`
  String get vfd23 {
    return Intl.message('Forgot password?', name: 'vfd23', desc: '', args: []);
  }

  /// `New password`
  String get vfddfvd2 {
    return Intl.message('New password', name: 'vfddfvd2', desc: '', args: []);
  }

  /// `Enter the email your account is registered with`
  String get emailvfd {
    return Intl.message(
      'Enter the email your account is registered with',
      name: 'emailvfd',
      desc: '',
      args: [],
    );
  }

  /// `EMAIL`
  String get emailbngf {
    return Intl.message('EMAIL', name: 'emailbngf', desc: '', args: []);
  }

  /// `Sending...`
  String get bgf3 {
    return Intl.message('Sending...', name: 'bgf3', desc: '', args: []);
  }

  /// `Send code`
  String get mut3 {
    return Intl.message('Send code', name: 'mut3', desc: '', args: []);
  }

  /// `Code sent to`
  String get bvgf2 {
    return Intl.message('Code sent to', name: 'bvgf2', desc: '', args: []);
  }

  /// `Resend`
  String get bgf24 {
    return Intl.message('Resend', name: 'bgf24', desc: '', args: []);
  }

  /// `Verifying...`
  String get bgf2 {
    return Intl.message('Verifying...', name: 'bgf2', desc: '', args: []);
  }

  /// `Confirm`
  String get vfd245 {
    return Intl.message('Confirm', name: 'vfd245', desc: '', args: []);
  }

  /// `Create a new password`
  String get uy3 {
    return Intl.message(
      'Create a new password',
      name: 'uy3',
      desc: '',
      args: [],
    );
  }

  /// `NEW PASSWORD`
  String get fvrdevfd54 {
    return Intl.message('NEW PASSWORD', name: 'fvrdevfd54', desc: '', args: []);
  }

  /// `Minimum 6 characters`
  String get my65 {
    return Intl.message(
      'Minimum 6 characters',
      name: 'my65',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM PASSWORD`
  String get uj334 {
    return Intl.message('CONFIRM PASSWORD', name: 'uj334', desc: '', args: []);
  }

  /// `Repeat password`
  String get ujt3 {
    return Intl.message('Repeat password', name: 'ujt3', desc: '', args: []);
  }

  /// `Saving...`
  String get nbhty3 {
    return Intl.message('Saving...', name: 'nbhty3', desc: '', args: []);
  }

  /// `Save password`
  String get ukj3 {
    return Intl.message('Save password', name: 'ukj3', desc: '', args: []);
  }

  /// `Login`
  String get umt645 {
    return Intl.message('Login', name: 'umt645', desc: '', args: []);
  }

  /// `EMAIL`
  String get emailbgf {
    return Intl.message('EMAIL', name: 'emailbgf', desc: '', args: []);
  }

  /// `PASSWORD`
  String get nty35 {
    return Intl.message('PASSWORD', name: 'nty35', desc: '', args: []);
  }

  /// `Minimum 6 characters`
  String get nfngfngf645 {
    return Intl.message(
      'Minimum 6 characters',
      name: 'nfngfngf645',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get kiyt3 {
    return Intl.message('Forgot password?', name: 'kiyt3', desc: '', args: []);
  }

  /// `Logging in...`
  String get ykuj3 {
    return Intl.message('Logging in...', name: 'ykuj3', desc: '', args: []);
  }

  /// `Log in`
  String get iykuj34 {
    return Intl.message('Log in', name: 'iykuj34', desc: '', args: []);
  }

  /// `No account? Register`
  String get myt3 {
    return Intl.message(
      'No account? Register',
      name: 'myt3',
      desc: '',
      args: [],
    );
  }

  /// `Registration`
  String get nyt7 {
    return Intl.message('Registration', name: 'nyt7', desc: '', args: []);
  }

  /// `Join us`
  String get nty3 {
    return Intl.message('Join us', name: 'nty3', desc: '', args: []);
  }

  /// `FULL NAME`
  String get btr3 {
    return Intl.message('FULL NAME', name: 'btr3', desc: '', args: []);
  }

  /// `Enter your name`
  String get nbgf3 {
    return Intl.message('Enter your name', name: 'nbgf3', desc: '', args: []);
  }

  /// `PHONE`
  String get bgf34 {
    return Intl.message('PHONE', name: 'bgf34', desc: '', args: []);
  }

  /// `PASSWORD`
  String get bgf35 {
    return Intl.message('PASSWORD', name: 'bgf35', desc: '', args: []);
  }

  /// `Minimum 6 characters`
  String get bgfbvgfd3 {
    return Intl.message(
      'Minimum 6 characters',
      name: 'bgfbvgfd3',
      desc: '',
      args: [],
    );
  }

  /// `CONFIRM PASSWORD`
  String get bg334 {
    return Intl.message('CONFIRM PASSWORD', name: 'bg334', desc: '', args: []);
  }

  /// `Repeat password`
  String get vbrgf2 {
    return Intl.message('Repeat password', name: 'vbrgf2', desc: '', args: []);
  }

  /// `Registering...`
  String get bgfd3 {
    return Intl.message('Registering...', name: 'bgfd3', desc: '', args: []);
  }

  /// `Create account`
  String get bgd2 {
    return Intl.message('Create account', name: 'bgd2', desc: '', args: []);
  }

  /// `Already have an account?`
  String get muj56 {
    return Intl.message(
      'Already have an account?',
      name: 'muj56',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get ujt4 {
    return Intl.message('Log in', name: 'ujt4', desc: '', args: []);
  }

  /// `Select country`
  String get nbtynt7 {
    return Intl.message('Select country', name: 'nbtynt7', desc: '', args: []);
  }

  /// `Search country...`
  String get mjh5y {
    return Intl.message('Search country...', name: 'mjh5y', desc: '', args: []);
  }

  /// `Select`
  String get nhgngn5 {
    return Intl.message('Select', name: 'nhgngn5', desc: '', args: []);
  }

  /// `Languages loading. Try again later.`
  String get vfd34 {
    return Intl.message(
      'Languages loading. Try again later.',
      name: 'vfd34',
      desc: '',
      args: [],
    );
  }

  /// `Languages not loaded. Try again later.`
  String get bgdfbgfd3 {
    return Intl.message(
      'Languages not loaded. Try again later.',
      name: 'bgdfbgfd3',
      desc: '',
      args: [],
    );
  }

  /// `Select languages`
  String get bgvfd3 {
    return Intl.message('Select languages', name: 'bgvfd3', desc: '', args: []);
  }

  /// `Languages not found`
  String get bdg3 {
    return Intl.message(
      'Languages not found',
      name: 'bdg3',
      desc: '',
      args: [],
    );
  }

  /// `Unknown language`
  String get nhtg5 {
    return Intl.message('Unknown language', name: 'nhtg5', desc: '', args: []);
  }

  /// `Code:`
  String get bmy5 {
    return Intl.message('Code:', name: 'bmy5', desc: '', args: []);
  }

  /// `Apply`
  String get bnht {
    return Intl.message('Apply', name: 'bnht', desc: '', args: []);
  }

  /// `Loading...`
  String get bgfbgfb4 {
    return Intl.message('Loading...', name: 'bgfbgfb4', desc: '', args: []);
  }

  /// `Select`
  String get gbfbgfbfg4 {
    return Intl.message('Select', name: 'gbfbgfbfg4', desc: '', args: []);
  }

  /// `Package types loading. Try again later.`
  String get t53grvfe5 {
    return Intl.message(
      'Package types loading. Try again later.',
      name: 't53grvfe5',
      desc: '',
      args: [],
    );
  }

  /// `Package types not loaded. Try again later.`
  String get bgfbgfbgf4 {
    return Intl.message(
      'Package types not loaded. Try again later.',
      name: 'bgfbgfbgf4',
      desc: '',
      args: [],
    );
  }

  /// `Select specialization`
  String get bfgbgfb3 {
    return Intl.message(
      'Select specialization',
      name: 'bfgbgfb3',
      desc: '',
      args: [],
    );
  }

  /// `Package types not found`
  String get bgbffgb3 {
    return Intl.message(
      'Package types not found',
      name: 'bgbffgb3',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get bgfbggfbfg3 {
    return Intl.message('Apply', name: 'bgfbggfbfg3', desc: '', args: []);
  }

  /// `Start a conversation`
  String get vgfbgf4 {
    return Intl.message(
      'Start a conversation',
      name: 'vgfbgf4',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to send`
  String get bgfbfgb4 {
    return Intl.message(
      'Are you sure you want to send',
      name: 'bgfbfgb4',
      desc: '',
      args: [],
    );
  }

  /// `a request to rate your services?`
  String get bfgbgbgy6 {
    return Intl.message(
      'a request to rate your services?',
      name: 'bfgbgbgy6',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bgbgfgb43 {
    return Intl.message('Cancel', name: 'bgbgfgb43', desc: '', args: []);
  }

  /// `Review request sent!`
  String get bgfbfg3 {
    return Intl.message(
      'Review request sent!',
      name: 'bgfbfg3',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get cdsdssde3 {
    return Intl.message('Send', name: 'cdsdssde3', desc: '', args: []);
  }

  /// `Inbox`
  String get vfdvfd3 {
    return Intl.message('Inbox', name: 'vfdvfd3', desc: '', args: []);
  }

  /// `Archive`
  String get vfdvfdvf3 {
    return Intl.message('Archive', name: 'vfdvfdvf3', desc: '', args: []);
  }

  /// `No chats`
  String get vfgdvfd3 {
    return Intl.message('No chats', name: 'vfgdvfd3', desc: '', args: []);
  }

  /// `Chat actions`
  String get vfdvfddvfdvf3 {
    return Intl.message(
      'Chat actions',
      name: 'vfdvfddvfdvf3',
      desc: '',
      args: [],
    );
  }

  /// `Unpin`
  String get htyyhttyh7 {
    return Intl.message('Unpin', name: 'htyyhttyh7', desc: '', args: []);
  }

  /// `Pin`
  String get juyjy7 {
    return Intl.message('Pin', name: 'juyjy7', desc: '', args: []);
  }

  /// `Unarchive`
  String get yjyj67 {
    return Intl.message('Unarchive', name: 'yjyj67', desc: '', args: []);
  }

  /// `Archive`
  String get mkuuj7 {
    return Intl.message('Archive', name: 'mkuuj7', desc: '', args: []);
  }

  /// `Unblock`
  String get jnyjyjyu8 {
    return Intl.message('Unblock', name: 'jnyjyjyu8', desc: '', args: []);
  }

  /// `Block`
  String get ynmjymjy8 {
    return Intl.message('Block', name: 'ynmjymjy8', desc: '', args: []);
  }

  /// `Delete chat`
  String get mymuyy7 {
    return Intl.message('Delete chat', name: 'mymuyy7', desc: '', args: []);
  }

  /// `Delete chat?`
  String get mumju7 {
    return Intl.message('Delete chat?', name: 'mumju7', desc: '', args: []);
  }

  /// `Are you sure you want to delete the conversation with`
  String get njmuy5 {
    return Intl.message(
      'Are you sure you want to delete the conversation with',
      name: 'njmuy5',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bhtgbht55 {
    return Intl.message('Cancel', name: 'bhtgbht55', desc: '', args: []);
  }

  /// `Delete`
  String get nhtntt5 {
    return Intl.message('Delete', name: 'nhtntt5', desc: '', args: []);
  }

  /// `Block user?`
  String get bgfbfbg5 {
    return Intl.message('Block user?', name: 'bgfbfbg5', desc: '', args: []);
  }

  /// `Are you sure you want to block`
  String get bghfbgb5 {
    return Intl.message(
      'Are you sure you want to block',
      name: 'bghfbgb5',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bgtbgtbgbtg4 {
    return Intl.message('Cancel', name: 'bgtbgtbgbtg4', desc: '', args: []);
  }

  /// `Block`
  String get bghfgbg4 {
    return Intl.message('Block', name: 'bghfgbg4', desc: '', args: []);
  }

  /// `Unblock user?`
  String get gbfgbfgfb34 {
    return Intl.message(
      'Unblock user?',
      name: 'gbfgbfgfb34',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to unblock`
  String get bgfbgffg4 {
    return Intl.message(
      'Are you sure you want to unblock',
      name: 'bgfbgffg4',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get bvgfbf4 {
    return Intl.message('Cancel', name: 'bvgfbf4', desc: '', args: []);
  }

  /// `Unblock`
  String get hythy4 {
    return Intl.message('Unblock', name: 'hythy4', desc: '', args: []);
  }

  /// `Message...`
  String get yhtrhtrtrh4 {
    return Intl.message('Message...', name: 'yhtrhtrtrh4', desc: '', args: []);
  }

  /// `Photo`
  String get bgfbgfbg4 {
    return Intl.message('Photo', name: 'bgfbgfbg4', desc: '', args: []);
  }

  /// `File`
  String get bgfbgfgf4 {
    return Intl.message('File', name: 'bgfbgfgf4', desc: '', args: []);
  }

  /// `Verified`
  String get bgfbgf4 {
    return Intl.message('Verified', name: 'bgfbgf4', desc: '', args: []);
  }

  /// `new messages`
  String get bgbgffbgfg4 {
    return Intl.message(
      'new messages',
      name: 'bgbgffbgfg4',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get vfdvfdvfd {
    return Intl.message('Account', name: 'vfdvfdvfd', desc: '', args: []);
  }

  /// `Favorites`
  String get gbfbgfgb {
    return Intl.message('Favorites', name: 'gbfbgfgb', desc: '', args: []);
  }

  /// `Post`
  String get nhnnh5 {
    return Intl.message('Post', name: 'nhnnh5', desc: '', args: []);
  }

  /// `Chats`
  String get mjhmhjmj5 {
    return Intl.message('Chats', name: 'mjhmhjmj5', desc: '', args: []);
  }

  /// `Search`
  String get nhhfge4 {
    return Intl.message('Search', name: 'nhhfge4', desc: '', args: []);
  }

  /// `Error loading offer types:`
  String get bgfdbf3 {
    return Intl.message(
      'Error loading offer types:',
      name: 'bgfdbf3',
      desc: '',
      args: [],
    );
  }

  /// `Error loading cities:`
  String get bgvrgrbgr3 {
    return Intl.message(
      'Error loading cities:',
      name: 'bgvrgrbgr3',
      desc: '',
      args: [],
    );
  }

  /// `Error loading package types:`
  String get vfdvfdvfdv3 {
    return Intl.message(
      'Error loading package types:',
      name: 'vfdvfdvfdv3',
      desc: '',
      args: [],
    );
  }

  /// `Create a listing to find a courier or\nclient`
  String get bgfbgbgfbgf {
    return Intl.message(
      'Create a listing to find a courier or\nclient',
      name: 'bgfbgbgfbgf',
      desc: '',
      args: [],
    );
  }

  /// `Package type:`
  String get nhgnhg4 {
    return Intl.message('Package type:', name: 'nhgnhg4', desc: '', args: []);
  }

  /// `From`
  String get hythyt4 {
    return Intl.message('From', name: 'hythyt4', desc: '', args: []);
  }

  /// `Departure city`
  String get kiukiuku6 {
    return Intl.message(
      'Departure city',
      name: 'kiukiuku6',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get kiuykiu67 {
    return Intl.message('To', name: 'kiuykiu67', desc: '', args: []);
  }

  /// `Destination city`
  String get lkiuliuu6 {
    return Intl.message(
      'Destination city',
      name: 'lkiuliuu6',
      desc: '',
      args: [],
    );
  }

  /// `Price per kg`
  String get bgfbgf34 {
    return Intl.message('Price per kg', name: 'bgfbgf34', desc: '', args: []);
  }

  /// `Description`
  String get vfdbg2r3 {
    return Intl.message('Description', name: 'vfdbg2r3', desc: '', args: []);
  }

  /// `Tell us about your delivery services...`
  String get bdfbd2w {
    return Intl.message(
      'Tell us about your delivery services...',
      name: 'bdfbd2w',
      desc: '',
      args: [],
    );
  }

  /// `Publish listing`
  String get bgfbgf3 {
    return Intl.message('Publish listing', name: 'bgfbgf3', desc: '', args: []);
  }

  /// `dd.mm.yyyy`
  String get bgbgfg334 {
    return Intl.message('dd.mm.yyyy', name: 'bgbgfg334', desc: '', args: []);
  }

  /// `Departure time`
  String get bgfbgf3434 {
    return Intl.message(
      'Departure time',
      name: 'bgfbgf3434',
      desc: '',
      args: [],
    );
  }

  /// `Delivery date from`
  String get bgdfbg345 {
    return Intl.message(
      'Delivery date from',
      name: 'bgdfbg345',
      desc: '',
      args: [],
    );
  }

  /// `dd.mm.yyyy`
  String get bgfbgf4554 {
    return Intl.message('dd.mm.yyyy', name: 'bgfbgf4554', desc: '', args: []);
  }

  /// `dd.mm.yyyy`
  String get bgfdbgf345 {
    return Intl.message('dd.mm.yyyy', name: 'bgfdbgf345', desc: '', args: []);
  }

  /// `Delivery date to`
  String get bgfgbfbgf345 {
    return Intl.message(
      'Delivery date to',
      name: 'bgfgbfbgf345',
      desc: '',
      args: [],
    );
  }

  /// `Purchase date from`
  String get bgfb3 {
    return Intl.message(
      'Purchase date from',
      name: 'bgfb3',
      desc: '',
      args: [],
    );
  }

  /// `dd.mm.yyyy`
  String get bgfbggfbgf34 {
    return Intl.message('dd.mm.yyyy', name: 'bgfbggfbgf34', desc: '', args: []);
  }

  /// `Purchase date to`
  String get vfdv34 {
    return Intl.message('Purchase date to', name: 'vfdv34', desc: '', args: []);
  }

  /// `hh:mm (24-hour format)`
  String get vfdvfddfv24 {
    return Intl.message(
      'hh:mm (24-hour format)',
      name: 'vfdvfddfv24',
      desc: '',
      args: [],
    );
  }

  /// `Listing published!`
  String get vfdvfd24 {
    return Intl.message(
      'Listing published!',
      name: 'vfdvfd24',
      desc: '',
      args: [],
    );
  }

  /// `Error:`
  String get vfdvf423 {
    return Intl.message('Error:', name: 'vfdvf423', desc: '', args: []);
  }

  /// `Error loading data`
  String get dsvfsd {
    return Intl.message(
      'Error loading data',
      name: 'dsvfsd',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get fds {
    return Intl.message('Try again', name: 'fds', desc: '', args: []);
  }

  /// `Verified`
  String get h46h46 {
    return Intl.message('Verified', name: 'h46h46', desc: '', args: []);
  }

  /// `Deliveries`
  String get gbgrbyhe435 {
    return Intl.message('Deliveries', name: 'gbgrbyhe435', desc: '', args: []);
  }

  /// `Rating`
  String get hgg4235gb {
    return Intl.message('Rating', name: 'hgg4235gb', desc: '', args: []);
  }

  /// `Reviews`
  String get bgfh364 {
    return Intl.message('Reviews', name: 'bgfh364', desc: '', args: []);
  }

  /// `On site`
  String get htr345gfd {
    return Intl.message('On site', name: 'htr345gfd', desc: '', args: []);
  }

  /// `days`
  String get bgfbg33 {
    return Intl.message('days', name: 'bgfbg33', desc: '', args: []);
  }

  /// `Select language`
  String get vgfb35 {
    return Intl.message('Select language', name: 'vgfb35', desc: '', args: []);
  }

  /// `Theme`
  String get fggdf345 {
    return Intl.message('Theme', name: 'fggdf345', desc: '', args: []);
  }

  /// `Dark theme enabled`
  String get bfd4r53gfd {
    return Intl.message(
      'Dark theme enabled',
      name: 'bfd4r53gfd',
      desc: '',
      args: [],
    );
  }

  /// `Light theme enabled`
  String get bgfb453 {
    return Intl.message(
      'Light theme enabled',
      name: 'bgfb453',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get bdb4w5gfd {
    return Intl.message('Verification', name: 'bdb4w5gfd', desc: '', args: []);
  }

  /// `Verify documents`
  String get bdfgt43refg {
    return Intl.message(
      'Verify documents',
      name: 'bdfgt43refg',
      desc: '',
      args: [],
    );
  }

  /// `Listings`
  String get bdfbfd43tgfd {
    return Intl.message('Listings', name: 'bdfbfd43tgfd', desc: '', args: []);
  }

  /// `Listing history`
  String get bdfbertgfvdre {
    return Intl.message(
      'Listing history',
      name: 'bdfbertgfvdre',
      desc: '',
      args: [],
    );
  }

  /// `Reviews`
  String get nfgn53tgdfg {
    return Intl.message('Reviews', name: 'nfgn53tgdfg', desc: '', args: []);
  }

  /// `View reviews`
  String get bgf43bgfd3 {
    return Intl.message('View reviews', name: 'bgf43bgfd3', desc: '', args: []);
  }

  /// `Support`
  String get bgfbgfeerfdfd {
    return Intl.message('Support', name: 'bgfbgfeerfdfd', desc: '', args: []);
  }

  /// `Contact support`
  String get bgbgf34fdg {
    return Intl.message(
      'Contact support',
      name: 'bgbgf34fdg',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get bgfbgf34gvfd {
    return Intl.message('Settings', name: 'bgfbgf34gvfd', desc: '', args: []);
  }

  /// `Account management`
  String get nfngret4 {
    return Intl.message(
      'Account management',
      name: 'nfngret4',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get ngfngfn44 {
    return Intl.message('Log out', name: 'ngfngfn44', desc: '', args: []);
  }

  /// `Are you sure you want to log out?`
  String get vxer3 {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'vxer3',
      desc: '',
      args: [],
    );
  }

  /// `Yes, log out`
  String get bg33a {
    return Intl.message('Yes, log out', name: 'bg33a', desc: '', args: []);
  }

  /// `No, cancel`
  String get bnbv3h {
    return Intl.message('No, cancel', name: 'bnbv3h', desc: '', args: []);
  }

  /// `Log out`
  String get bgd32 {
    return Intl.message('Log out', name: 'bgd32', desc: '', args: []);
  }

  /// `Logging out`
  String get bgfnyuj3 {
    return Intl.message('Logging out', name: 'bgfnyuj3', desc: '', args: []);
  }

  /// `User`
  String get hghfg4bhn {
    return Intl.message('User', name: 'hghfg4bhn', desc: '', args: []);
  }

  /// `Received`
  String get hbfgh3 {
    return Intl.message('Received', name: 'hbfgh3', desc: '', args: []);
  }

  /// `Given`
  String get gert3tger {
    return Intl.message('Given', name: 'gert3tger', desc: '', args: []);
  }

  /// `No reviews given`
  String get bvfdgb43 {
    return Intl.message(
      'No reviews given',
      name: 'bvfdgb43',
      desc: '',
      args: [],
    );
  }

  /// `No reviews given`
  String get bfdtw4ew4 {
    return Intl.message(
      'No reviews given',
      name: 'bfdtw4ew4',
      desc: '',
      args: [],
    );
  }

  /// `History is empty`
  String get gbdyh5g {
    return Intl.message(
      'History is empty',
      name: 'gbdyh5g',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get bfdgbt5 {
    return Intl.message('History', name: 'bfdgbt5', desc: '', args: []);
  }

  /// `Show all`
  String get bgnhju46 {
    return Intl.message('Show all', name: 'bgnhju46', desc: '', args: []);
  }

  /// `Active`
  String get mjghmjtr446 {
    return Intl.message('Active', name: 'mjghmjtr446', desc: '', args: []);
  }

  /// `Completed`
  String get ljkl73 {
    return Intl.message('Completed', name: 'ljkl73', desc: '', args: []);
  }

  /// `Cancelled`
  String get bdgbfgrtr4 {
    return Intl.message('Cancelled', name: 'bdgbfgrtr4', desc: '', args: []);
  }

  /// `Active`
  String get vbdgbfre2 {
    return Intl.message('Active', name: 'vbdgbfre2', desc: '', args: []);
  }

  /// `Date not specified`
  String get vfd223bdgbf {
    return Intl.message(
      'Date not specified',
      name: 'vfd223bdgbf',
      desc: '',
      args: [],
    );
  }

  /// `Date not specified`
  String get vbdgbfvbdgbf {
    return Intl.message(
      'Date not specified',
      name: 'vbdgbfvbdgbf',
      desc: '',
      args: [],
    );
  }

  /// `Select language`
  String get bgfbgfbg33344343 {
    return Intl.message(
      'Select language',
      name: 'bgfbgfbg33344343',
      desc: '',
      args: [],
    );
  }

  /// `Azerbaijani`
  String get azrbaycan {
    return Intl.message('Azerbaijani', name: 'azrbaycan', desc: '', args: []);
  }

  /// `Russian`
  String get rudssian {
    return Intl.message('Russian', name: 'rudssian', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Turkish`
  String get turkish {
    return Intl.message('Turkish', name: 'turkish', desc: '', args: []);
  }

  /// `Edit profile`
  String get vfgbhyujkerg3 {
    return Intl.message(
      'Edit profile',
      name: 'vfgbhyujkerg3',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get bd3435fvd {
    return Intl.message('Verification', name: 'bd3435fvd', desc: '', args: []);
  }

  /// `You are verified!`
  String get vfdfv22434 {
    return Intl.message(
      'You are verified!',
      name: 'vfdfv22434',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been successfully verified.\nYou now have the status `
  String get vfdvfdvfvfdewr44 {
    return Intl.message(
      'Your account has been successfully verified.\nYou now have the status ',
      name: 'vfdvfdvfvfdewr44',
      desc: '',
      args: [],
    );
  }

  /// `Documents approved`
  String get vfdvfdr3r34 {
    return Intl.message(
      'Documents approved',
      name: 'vfdvfdr3r34',
      desc: '',
      args: [],
    );
  }

  /// `All checks passed`
  String get vfvfd443r43 {
    return Intl.message(
      'All checks passed',
      name: 'vfvfd443r43',
      desc: '',
      args: [],
    );
  }

  /// `Verification completed`
  String get gttbr42435t345 {
    return Intl.message(
      'Verification completed',
      name: 'gttbr42435t345',
      desc: '',
      args: [],
    );
  }

  /// `Account verified`
  String get bdfdw432534vfd {
    return Intl.message(
      'Account verified',
      name: 'bdfdw432534vfd',
      desc: '',
      args: [],
    );
  }

  /// `You can use all platform features`
  String get dfbdf424fdv {
    return Intl.message(
      'You can use all platform features',
      name: 'dfbdf424fdv',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get vfdgfdvfd42343 {
    return Intl.message(
      'Verification',
      name: 'vfdgfdvfd42343',
      desc: '',
      args: [],
    );
  }

  /// `Application under review`
  String get vdfvfd42422 {
    return Intl.message(
      'Application under review',
      name: 'vdfvfd42422',
      desc: '',
      args: [],
    );
  }

  /// `Your verification application has been successfully submitted.\nWe will review your documents within 1-3 business days.`
  String get n13vdf43 {
    return Intl.message(
      'Your verification application has been successfully submitted.\nWe will review your documents within 1-3 business days.',
      name: 'n13vdf43',
      desc: '',
      args: [],
    );
  }

  /// `Documents submitted`
  String get vfdvfd22343 {
    return Intl.message(
      'Documents submitted',
      name: 'vfdvfd22343',
      desc: '',
      args: [],
    );
  }

  /// `Passport and selfie received`
  String get vfd233424 {
    return Intl.message(
      'Passport and selfie received',
      name: 'vfd233424',
      desc: '',
      args: [],
    );
  }

  /// `Under review`
  String get juty4545 {
    return Intl.message('Under review', name: 'juty4545', desc: '', args: []);
  }

  /// `Awaiting results`
  String get hy4345 {
    return Intl.message('Awaiting results', name: 'hy4345', desc: '', args: []);
  }

  /// `We will notify you of the verification results`
  String get gtrgtr34343 {
    return Intl.message(
      'We will notify you of the verification results',
      name: 'gtrgtr34343',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get gregrere4334 {
    return Intl.message(
      'Verification',
      name: 'gregrere4334',
      desc: '',
      args: [],
    );
  }

  /// `Account verification`
  String get gre43fbd4t3 {
    return Intl.message(
      'Account verification',
      name: 'gre43fbd4t3',
      desc: '',
      args: [],
    );
  }

  /// `Verify your identity to increase\ntrust`
  String get ngre24532vfds {
    return Intl.message(
      'Verify your identity to increase\ntrust',
      name: 'ngre24532vfds',
      desc: '',
      args: [],
    );
  }

  /// `Verification status`
  String get gdfgdf4343gre {
    return Intl.message(
      'Verification status',
      name: 'gdfgdf4343gre',
      desc: '',
      args: [],
    );
  }

  /// `Upload documents for verification`
  String get get42fvfdvs {
    return Intl.message(
      'Upload documents for verification',
      name: 'get42fvfdvs',
      desc: '',
      args: [],
    );
  }

  /// `Main document`
  String get vdfvbfd34 {
    return Intl.message('Main document', name: 'vdfvbfd34', desc: '', args: []);
  }

  /// `Passport`
  String get vfd43vfd {
    return Intl.message('Passport', name: 'vfd43vfd', desc: '', args: []);
  }

  /// `Uploaded`
  String get gdf43gf {
    return Intl.message('Uploaded', name: 'gdf43gf', desc: '', args: []);
  }

  /// `Not uploaded`
  String get fbdbdf3434 {
    return Intl.message('Not uploaded', name: 'fbdbdf3434', desc: '', args: []);
  }

  /// `Upload passport`
  String get bdf234rffd {
    return Intl.message(
      'Upload passport',
      name: 'bdf234rffd',
      desc: '',
      args: [],
    );
  }

  /// `Selfie with passport`
  String get gfdfd3434 {
    return Intl.message(
      'Selfie with passport',
      name: 'gfdfd3434',
      desc: '',
      args: [],
    );
  }

  /// `Identity verification`
  String get bfxvdg34 {
    return Intl.message(
      'Identity verification',
      name: 'bfxvdg34',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded`
  String get hrgrs434 {
    return Intl.message('Uploaded', name: 'hrgrs434', desc: '', args: []);
  }

  /// `Not uploaded`
  String get yghtrdf4343 {
    return Intl.message(
      'Not uploaded',
      name: 'yghtrdf4343',
      desc: '',
      args: [],
    );
  }

  /// `Upload selfie with passport`
  String get fdggg35tr34g {
    return Intl.message(
      'Upload selfie with passport',
      name: 'fdggg35tr34g',
      desc: '',
      args: [],
    );
  }

  /// `Important:`
  String get gbdgb3434 {
    return Intl.message('Important:', name: 'gbdgb3434', desc: '', args: []);
  }

  /// `Document verification takes 1-3 business days. After approval, you will receive the status `
  String get grgdfgdfg34t343t {
    return Intl.message(
      'Document verification takes 1-3 business days. After approval, you will receive the status ',
      name: 'grgdfgdfg34t343t',
      desc: '',
      args: [],
    );
  }

  /// `Submit for review`
  String get bfdbffd24343vfd {
    return Intl.message(
      'Submit for review',
      name: 'bfdbffd24343vfd',
      desc: '',
      args: [],
    );
  }

  /// `Please upload both documents`
  String get bgfbgd3ttgtebdsdf {
    return Intl.message(
      'Please upload both documents',
      name: 'bgfbgd3ttgtebdsdf',
      desc: '',
      args: [],
    );
  }

  /// `Documents successfully submitted for review`
  String get yhtjkuyil43 {
    return Intl.message(
      'Documents successfully submitted for review',
      name: 'yhtjkuyil43',
      desc: '',
      args: [],
    );
  }

  /// `Error:`
  String get bgdfgre345gtt4evwf {
    return Intl.message(
      'Error:',
      name: 'bgdfgre345gtt4evwf',
      desc: '',
      args: [],
    );
  }

  /// `Sent!`
  String get bvetgh423rfc {
    return Intl.message('Sent!', name: 'bvetgh423rfc', desc: '', args: []);
  }

  /// `We will contact you shortly`
  String get bnmkuy43545g3 {
    return Intl.message(
      'We will contact you shortly',
      name: 'bnmkuy43545g3',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Support`
  String get get3434gvrevef {
    return Intl.message('Support', name: 'get3434gvrevef', desc: '', args: []);
  }

  /// `How can we help?`
  String get bgrf4tb4dgfb {
    return Intl.message(
      'How can we help?',
      name: 'bgrf4tb4dgfb',
      desc: '',
      args: [],
    );
  }

  /// `Describe your problem and we will\nrespond as soon as possible`
  String get rtbrtb4t4t4tb4n {
    return Intl.message(
      'Describe your problem and we will\nrespond as soon as possible',
      name: 'rtbrtb4t4t4tb4n',
      desc: '',
      args: [],
    );
  }

  /// `Problem description`
  String get nrtn33ss {
    return Intl.message(
      'Problem description',
      name: 'nrtn33ss',
      desc: '',
      args: [],
    );
  }

  /// `Tell us more about your problem...`
  String get bbddgbtgbbvb {
    return Intl.message(
      'Tell us more about your problem...',
      name: 'bbddgbtgbbvb',
      desc: '',
      args: [],
    );
  }

  /// `Please describe your problem`
  String get nntteev5eg {
    return Intl.message(
      'Please describe your problem',
      name: 'nntteev5eg',
      desc: '',
      args: [],
    );
  }

  /// `Description must contain at least 10 characters`
  String get bbddert42t54gdg {
    return Intl.message(
      'Description must contain at least 10 characters',
      name: 'bbddert42t54gdg',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 10 characters`
  String get gbrg533gds24rtegv {
    return Intl.message(
      'Minimum 10 characters',
      name: 'gbrg533gds24rtegv',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get bed2245fvfsgd {
    return Intl.message('Send', name: 'bed2245fvfsgd', desc: '', args: []);
  }

  /// `Response time`
  String get dfg34fgdwrrew {
    return Intl.message(
      'Response time',
      name: 'dfg34fgdwrrew',
      desc: '',
      args: [],
    );
  }

  /// `We usually respond within 24 hours`
  String get gfdlek54jn3 {
    return Intl.message(
      'We usually respond within 24 hours',
      name: 'gfdlek54jn3',
      desc: '',
      args: [],
    );
  }

  /// `Listing history`
  String get bd3g345h57h4b {
    return Intl.message(
      'Listing history',
      name: 'bd3g345h57h4b',
      desc: '',
      args: [],
    );
  }

  /// `No listings`
  String get gbterg534g45v4 {
    return Intl.message(
      'No listings',
      name: 'gbterg534g45v4',
      desc: '',
      args: [],
    );
  }

  /// `Your listing history will appear here`
  String get ger345g3 {
    return Intl.message(
      'Your listing history will appear here',
      name: 'ger345g3',
      desc: '',
      args: [],
    );
  }

  /// `Privacy and notifications`
  String get gret4h5h53g2b {
    return Intl.message(
      'Privacy and notifications',
      name: 'gret4h5h53g2b',
      desc: '',
      args: [],
    );
  }

  /// `Manage information visibility`
  String get vfsvf33fr {
    return Intl.message(
      'Manage information visibility',
      name: 'vfsvf33fr',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get vsf3r4gh57j6hnbd {
    return Intl.message(
      'Privacy',
      name: 'vsf3r4gh57j6hnbd',
      desc: '',
      args: [],
    );
  }

  /// `Show phone`
  String get myiuk7564hd {
    return Intl.message('Show phone', name: 'myiuk7564hd', desc: '', args: []);
  }

  /// `Show email`
  String get emailnhrtybe {
    return Intl.message('Show email', name: 'emailnhrtybe', desc: '', args: []);
  }

  /// `Show activity time`
  String get bgfbgt4ry46hj57jhg {
    return Intl.message(
      'Show activity time',
      name: 'bgfbgt4ry46hj57jhg',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get jyntytrk5j34r {
    return Intl.message(
      'Notifications',
      name: 'jyntytrk5j34r',
      desc: '',
      args: [],
    );
  }

  /// `New messages`
  String get trbgtvrger56fd {
    return Intl.message(
      'New messages',
      name: 'trbgtvrger56fd',
      desc: '',
      args: [],
    );
  }

  /// `New reviews`
  String get ger4tr3345 {
    return Intl.message('New reviews', name: 'ger4tr3345', desc: '', args: []);
  }

  /// `Marketing notifications`
  String get bfvdeb3gg34 {
    return Intl.message(
      'Marketing notifications',
      name: 'bfvdeb3gg34',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get gbd423g54bd {
    return Intl.message(
      'Save changes',
      name: 'gbd423g54bd',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get greg5g4g4g3 {
    return Intl.message('Saved', name: 'greg5g4g4g3', desc: '', args: []);
  }

  /// `Saved`
  String get gregre3rg {
    return Intl.message('Saved', name: 'gregre3rg', desc: '', args: []);
  }

  /// `Saved`
  String get nyh5jj53ge {
    return Intl.message('Saved', name: 'nyh5jj53ge', desc: '', args: []);
  }

  /// `Phone`
  String get vsf3grevsf43 {
    return Intl.message('Phone', name: 'vsf3grevsf43', desc: '', args: []);
  }

  /// `Save changes`
  String get grvge3g5 {
    return Intl.message('Save changes', name: 'grvge3g5', desc: '', args: []);
  }

  /// `About`
  String get vrevre43 {
    return Intl.message('About', name: 'vrevre43', desc: '', args: []);
  }

  /// `Location`
  String get bebfdb34g3vs {
    return Intl.message('Location', name: 'bebfdb34g3vs', desc: '', args: []);
  }

  /// `Full name`
  String get vrebveg34g3sd {
    return Intl.message('Full name', name: 'vrebveg34g3sd', desc: '', args: []);
  }

  /// `Tap to change photo`
  String get bvfdb4btevsf {
    return Intl.message(
      'Tap to change photo',
      name: 'bvfdb4btevsf',
      desc: '',
      args: [],
    );
  }

  /// `Error loading languages:`
  String get vdfvfd4rg5ger {
    return Intl.message(
      'Error loading languages:',
      name: 'vdfvfd4rg5ger',
      desc: '',
      args: [],
    );
  }

  /// `Error loading package types:`
  String get vfdvd54gves {
    return Intl.message(
      'Error loading package types:',
      name: 'vfdvd54gves',
      desc: '',
      args: [],
    );
  }

  /// `Invalid time format:`
  String get vfdv3rgfre42 {
    return Intl.message(
      'Invalid time format:',
      name: 'vfdv3rgfre42',
      desc: '',
      args: [],
    );
  }

  /// `Error:`
  String get vdf3fg3rvs {
    return Intl.message('Error:', name: 'vdf3fg3rvs', desc: '', args: []);
  }

  /// `Invalid time format:`
  String get vfd3fggvrgds {
    return Intl.message(
      'Invalid time format:',
      name: 'vfd3fggvrgds',
      desc: '',
      args: [],
    );
  }

  /// `Error:`
  String get fvdvefr34vfsvd {
    return Intl.message('Error:', name: 'fvdvefr34vfsvd', desc: '', args: []);
  }

  /// `Select at least one language`
  String get vfd3rvewr3r {
    return Intl.message(
      'Select at least one language',
      name: 'vfd3rvewr3r',
      desc: '',
      args: [],
    );
  }

  /// `Select at least one specialization`
  String get yhthrgtr35hg4gd {
    return Intl.message(
      'Select at least one specialization',
      name: 'yhthrgtr35hg4gd',
      desc: '',
      args: [],
    );
  }

  /// `Experience data saved`
  String get bgfb4tr3getbger {
    return Intl.message(
      'Experience data saved',
      name: 'bgfb4tr3getbger',
      desc: '',
      args: [],
    );
  }

  /// `Work experience`
  String get bryh4tb4thb4yhhe {
    return Intl.message(
      'Work experience',
      name: 'bryh4tb4thb4yhhe',
      desc: '',
      args: [],
    );
  }

  /// `Maximum weight (kg)`
  String get brbt444b3tgsdgetr {
    return Intl.message(
      'Maximum weight (kg)',
      name: 'brbt444b3tgsdgetr',
      desc: '',
      args: [],
    );
  }

  /// `Insurance ($)`
  String get brbtr54t43gfdg {
    return Intl.message(
      'Insurance (\$)',
      name: 'brbtr54t43gfdg',
      desc: '',
      args: [],
    );
  }

  /// `Price range ($/kg)`
  String get bgdbtb4brgd {
    return Intl.message(
      'Price range (\$/kg)',
      name: 'bgdbtb4brgd',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get bgfbgf534tg534g {
    return Intl.message('From', name: 'bgfbgf534tg534g', desc: '', args: []);
  }

  /// `To`
  String get bry5yn4ny4bde {
    return Intl.message('To', name: 'bry5yn4ny4bde', desc: '', args: []);
  }

  /// `Communication languages`
  String get nybhtgr54terfw3 {
    return Intl.message(
      'Communication languages',
      name: 'nybhtgr54terfw3',
      desc: '',
      args: [],
    );
  }

  /// `Working hours`
  String get nujnhry4hrt {
    return Intl.message(
      'Working hours',
      name: 'nujnhry4hrt',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get btrb4tdb4tbr {
    return Intl.message('From', name: 'btrb4tdb4tbr', desc: '', args: []);
  }

  /// `To`
  String get greg54eh3rwgs {
    return Intl.message('To', name: 'greg54eh3rwgs', desc: '', args: []);
  }

  /// `Specialization`
  String get greg3greg43grgre {
    return Intl.message(
      'Specialization',
      name: 'greg3greg43grgre',
      desc: '',
      args: [],
    );
  }

  /// `Package types unavailable on server`
  String get trh35hteh354heh {
    return Intl.message(
      'Package types unavailable on server',
      name: 'trh35hteh354heh',
      desc: '',
      args: [],
    );
  }

  /// `Save changes`
  String get htrh4hedh4th4 {
    return Intl.message(
      'Save changes',
      name: 'htrh4hedh4th4',
      desc: '',
      args: [],
    );
  }

  /// `Selected experience:`
  String get bgdretr35grdf {
    return Intl.message(
      'Selected experience:',
      name: 'bgdretr35grdf',
      desc: '',
      args: [],
    );
  }

  /// `Selected experience:`
  String get vfdbvg3grgr34g {
    return Intl.message(
      'Selected experience:',
      name: 'vfdbvg3grgr34g',
      desc: '',
      args: [],
    );
  }

  /// `year`
  String get fregt56hgte {
    return Intl.message('year', name: 'fregt56hgte', desc: '', args: []);
  }

  /// `years`
  String get myijtyhg34ewfrv {
    return Intl.message('years', name: 'myijtyhg34ewfrv', desc: '', args: []);
  }

  /// `Insurance (`
  String get vevrtbgvt5ybtvew {
    return Intl.message(
      'Insurance (',
      name: 'vevrtbgvt5ybtvew',
      desc: '',
      args: [],
    );
  }

  /// `Password successfully changed`
  String get vfegt4g3rvsfcfd {
    return Intl.message(
      'Password successfully changed',
      name: 'vfegt4g3rvsfcfd',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get brttt4htg3rfwd {
    return Intl.message(
      'Change password',
      name: 'brttt4htg3rfwd',
      desc: '',
      args: [],
    );
  }

  /// `Enter current and new password`
  String get brtb5h6h453grbegr {
    return Intl.message(
      'Enter current and new password',
      name: 'brtb5h6h453grbegr',
      desc: '',
      args: [],
    );
  }

  /// `Current password`
  String get htrh64h5tger {
    return Intl.message(
      'Current password',
      name: 'htrh64h5tger',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get htrh56h5656 {
    return Intl.message(
      'New password',
      name: 'htrh56h5656',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 6 characters`
  String get bgrtyhnyn5jh4g3 {
    return Intl.message(
      'Minimum 6 characters',
      name: 'bgrtyhnyn5jh4g3',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password`
  String get jyrtj57jhrttyh4te {
    return Intl.message(
      'Confirm new password',
      name: 'jyrtj57jhrttyh4te',
      desc: '',
      args: [],
    );
  }

  /// `Repeat new password`
  String get jytuj56j56jj45 {
    return Intl.message(
      'Repeat new password',
      name: 'jytuj56j56jj45',
      desc: '',
      args: [],
    );
  }

  /// `Save new password`
  String get jt676676756jhr {
    return Intl.message(
      'Save new password',
      name: 'jt676676756jhr',
      desc: '',
      args: [],
    );
  }

  /// `No favorites`
  String get bgrfn5ynjh4tbegrvfvsdcx {
    return Intl.message(
      'No favorites',
      name: 'bgrfn5ynjh4tbegrvfvsdcx',
      desc: '',
      args: [],
    );
  }

  /// `Select city`
  String get bgrhtrgrfr445 {
    return Intl.message(
      'Select city',
      name: 'bgrhtrgrfr445',
      desc: '',
      args: [],
    );
  }

  /// `Search city...`
  String get hyrh5h4tgerwfs {
    return Intl.message(
      'Search city...',
      name: 'hyrh5h4tgerwfs',
      desc: '',
      args: [],
    );
  }

  /// `Start typing city name`
  String get juu76j5yh4rtge {
    return Intl.message(
      'Start typing city name',
      name: 'juu76j5yh4rtge',
      desc: '',
      args: [],
    );
  }

  /// `Cities not found`
  String get tyju65y4htge3rwfs {
    return Intl.message(
      'Cities not found',
      name: 'tyju65y4htge3rwfs',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get loginrbvgefrds {
    return Intl.message('Login', name: 'loginrbvgefrds', desc: '', args: []);
  }

  /// `Select city`
  String get tnhyj5brgbdfg {
    return Intl.message(
      'Select city',
      name: 'tnhyj5brgbdfg',
      desc: '',
      args: [],
    );
  }

  /// `Search city...`
  String get nu6j5yhtge65h4tgre {
    return Intl.message(
      'Search city...',
      name: 'nu6j5yhtge65h4tgre',
      desc: '',
      args: [],
    );
  }

  /// `Cities not found`
  String get nthybgtefr4terfd {
    return Intl.message(
      'Cities not found',
      name: 'nthybgtefr4terfd',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a message`
  String get by5htg4refg4tr3few {
    return Intl.message(
      'Please enter a message',
      name: 'by5htg4refg4tr3few',
      desc: '',
      args: [],
    );
  }

  /// `Message sent!`
  String get ybrfsg4t34gtgrvfedvfd {
    return Intl.message(
      'Message sent!',
      name: 'ybrfsg4t34gtgrvfedvfd',
      desc: '',
      args: [],
    );
  }

  /// `You are communicating directly with the user`
  String get rth435gtre {
    return Intl.message(
      'You are communicating directly with the user',
      name: 'rth435gtre',
      desc: '',
      args: [],
    );
  }

  /// `. The communication takes place directly between users and the site is not responsible for the content of the correspondence.`
  String get brtevrfg45rfs {
    return Intl.message(
      '. The communication takes place directly between users and the site is not responsible for the content of the correspondence.',
      name: 'brtevrfg45rfs',
      desc: '',
      args: [],
    );
  }

  /// `Write a message`
  String get hrt4h5hte43h454 {
    return Intl.message(
      'Write a message',
      name: 'hrt4h5hte43h454',
      desc: '',
      args: [],
    );
  }

  /// `Enter your message...`
  String get rthh4ger34f34 {
    return Intl.message(
      'Enter your message...',
      name: 'rthh4ger34f34',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get brg353gffvw34fr3 {
    return Intl.message('Send', name: 'brg353gffvw34fr3', desc: '', args: []);
  }

  /// `Nothing found`
  String get vetg3rwce3f4 {
    return Intl.message(
      'Nothing found',
      name: 'vetg3rwce3f4',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get searchbtrrevfdsc {
    return Intl.message('Search', name: 'searchbtrrevfdsc', desc: '', args: []);
  }

  /// `Notifications`
  String get gtregrfwd3rfewd35frwed {
    return Intl.message(
      'Notifications',
      name: 'gtregrfwd3rfewd35frwed',
      desc: '',
      args: [],
    );
  }

  /// `No notifications`
  String get vfev3r42e {
    return Intl.message(
      'No notifications',
      name: 'vfev3r42e',
      desc: '',
      args: [],
    );
  }

  /// `You have no new notifications yet`
  String get fvedrwgt4rwfeqg453wrfs {
    return Intl.message(
      'You have no new notifications yet',
      name: 'fvedrwgt4rwfeqg453wrfs',
      desc: '',
      args: [],
    );
  }

  /// `Loading error`
  String get vbfedrgf4wvt4g3rwfsdv {
    return Intl.message(
      'Loading error',
      name: 'vbfedrgf4wvt4g3rwfsdv',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get vefgbrg35grwf45g3r {
    return Intl.message(
      'Try again',
      name: 'vefgbrg35grwf45g3r',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get vfdevr3er3g3 {
    return Intl.message('Just now', name: 'vfdevr3er3g3', desc: '', args: []);
  }

  /// `min ago`
  String get gegereg34543tvfe {
    return Intl.message(
      'min ago',
      name: 'gegereg34543tvfe',
      desc: '',
      args: [],
    );
  }

  /// `h ago`
  String get vefdbt4evgrr35rw3r5ewfe {
    return Intl.message(
      'h ago',
      name: 'vefdbt4evgrr35rw3r5ewfe',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday`
  String get btegrew35g4frsf4r3 {
    return Intl.message(
      'Yesterday',
      name: 'btegrew35g4frsf4r3',
      desc: '',
      args: [],
    );
  }

  /// `d ago`
  String get ebvfrgevf24fewrvgr3 {
    return Intl.message(
      'd ago',
      name: 'ebvfrgevf24fewrvgr3',
      desc: '',
      args: [],
    );
  }

  /// `Leave a review`
  String get betg35rw355g3ref {
    return Intl.message(
      'Leave a review',
      name: 'betg35rw355g3ref',
      desc: '',
      args: [],
    );
  }

  /// `Your opinion is very important to us`
  String get betg465g3rwegt4 {
    return Intl.message(
      'Your opinion is very important to us',
      name: 'betg465g3rwegt4',
      desc: '',
      args: [],
    );
  }

  /// `Write your comment...`
  String get terg35t42r35t4rwefdsa {
    return Intl.message(
      'Write your comment...',
      name: 'terg35t42r35t4rwefdsa',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get h4g53t4fregt453rfwegg43ref {
    return Intl.message(
      'Submit',
      name: 'h4g53t4fregt453rfwegg43ref',
      desc: '',
      args: [],
    );
  }

  /// `Please select a rating`
  String get ujik87j6hy5gt4rerfw54 {
    return Intl.message(
      'Please select a rating',
      name: 'ujik87j6hy5gt4rerfw54',
      desc: '',
      args: [],
    );
  }

  /// `Error: missing data to submit review`
  String get cdswwcf4f3fgrwsdc {
    return Intl.message(
      'Error: missing data to submit review',
      name: 'cdswwcf4f3fgrwsdc',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your review!`
  String get fewef243fewf3efwas {
    return Intl.message(
      'Thank you for your review!',
      name: 'fewef243fewf3efwas',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get gergt65h43t42335 {
    return Intl.message('Close', name: 'gergt65h43t42335', desc: '', args: []);
  }

  /// `Just now`
  String get nytrh564y4y5gteg5tegr {
    return Intl.message(
      'Just now',
      name: 'nytrh564y4y5gteg5tegr',
      desc: '',
      args: [],
    );
  }

  /// `min ago`
  String get tehh6545ety4heg {
    return Intl.message('min ago', name: 'tehh6545ety4heg', desc: '', args: []);
  }

  /// `h ago`
  String get dbgre34vdvfs {
    return Intl.message('h ago', name: 'dbgre34vdvfs', desc: '', args: []);
  }

  /// `Yesterday`
  String get bterhb46h35g4wre {
    return Intl.message(
      'Yesterday',
      name: 'bterhb46h35g4wre',
      desc: '',
      args: [],
    );
  }

  /// `d ago`
  String get tbh453g4wresdv {
    return Intl.message('d ago', name: 'tbh453g4wresdv', desc: '', args: []);
  }

  /// `Contact information`
  String get bteg4r5344wfvsfdg34wf {
    return Intl.message(
      'Contact information',
      name: 'bteg4r5344wfvsfdg34wf',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get tbergwf35grwfsvfg43 {
    return Intl.message(
      'Phone',
      name: 'tbergwf35grwfsvfg43',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get emailg34rfvfs {
    return Intl.message('Email', name: 'emailg34rfvfs', desc: '', args: []);
  }

  /// `On platform`
  String get btegr4tfwrg3frwv {
    return Intl.message(
      'On platform',
      name: 'btegr4tfwrg3frwv',
      desc: '',
      args: [],
    );
  }

  /// `days`
  String get etghrwf3fr3 {
    return Intl.message('days', name: 'etghrwf3fr3', desc: '', args: []);
  }

  /// `Last seen`
  String get btergwfe5g34rfecerv {
    return Intl.message(
      'Last seen',
      name: 'btergwfe5g34rfecerv',
      desc: '',
      args: [],
    );
  }

  /// `Professional information`
  String get bterv4gg353r5r35 {
    return Intl.message(
      'Professional information',
      name: 'bterv4gg353r5r35',
      desc: '',
      args: [],
    );
  }

  /// `Work experience`
  String get bteettgr3gt4g3t4tg3 {
    return Intl.message(
      'Work experience',
      name: 'bteettgr3gt4g3t4tg3',
      desc: '',
      args: [],
    );
  }

  /// `years`
  String get tebh4gterw4htgerwf {
    return Intl.message(
      'years',
      name: 'tebh4gterw4htgerwf',
      desc: '',
      args: [],
    );
  }

  /// `Maximum weight`
  String get evr4g653twgrv43gr {
    return Intl.message(
      'Maximum weight',
      name: 'evr4g653twgrv43gr',
      desc: '',
      args: [],
    );
  }

  /// `kg`
  String get ethgr46htgbevgte {
    return Intl.message('kg', name: 'ethgr46htgbevgte', desc: '', args: []);
  }

  /// `Insurance`
  String get brtg3rtvebt4rgvbfd {
    return Intl.message(
      'Insurance',
      name: 'brtg3rtvebt4rgvbfd',
      desc: '',
      args: [],
    );
  }

  /// `Price range ($/kg)`
  String get vervrefg3gr45t3t4fwr34 {
    return Intl.message(
      'Price range (\$/kg)',
      name: 'vervrefg3gr45t3t4fwr34',
      desc: '',
      args: [],
    );
  }

  /// `Working hours`
  String get beg53gt342feg35g2fw {
    return Intl.message(
      'Working hours',
      name: 'beg53gt342feg35g2fw',
      desc: '',
      args: [],
    );
  }

  /// `Response time`
  String get btrg3243g5vfed34ft {
    return Intl.message(
      'Response time',
      name: 'btrg3243g5vfed34ft',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get btegr435tt24fwg34wf {
    return Intl.message('min', name: 'btegr435tt24fwg34wf', desc: '', args: []);
  }

  /// `On-time deliveries`
  String get tegr4rt3542frg3r {
    return Intl.message(
      'On-time deliveries',
      name: 'tegr4rt3542frg3r',
      desc: '',
      args: [],
    );
  }

  /// `Communication languages`
  String get ki7ju6h5ytg4erf53fw {
    return Intl.message(
      'Communication languages',
      name: 'ki7ju6h5ytg4erf53fw',
      desc: '',
      args: [],
    );
  }

  /// `No active offers`
  String get ynbreg4t3gfwr3gf {
    return Intl.message(
      'No active offers',
      name: 'ynbreg4t3gfwr3gf',
      desc: '',
      args: [],
    );
  }

  /// `Verified`
  String get hgterfvb4btgv {
    return Intl.message('Verified', name: 'hgterfvb4btgv', desc: '', args: []);
  }

  /// `reviews)`
  String get y5rbtvfs4l53 {
    return Intl.message('reviews)', name: 'y5rbtvfs4l53', desc: '', args: []);
  }

  /// `Deliveries`
  String get tbgverfsdclk345frwcs {
    return Intl.message(
      'Deliveries',
      name: 'tbgverfsdclk345frwcs',
      desc: '',
      args: [],
    );
  }

  /// `Successful`
  String get mftdr4587vfg {
    return Intl.message('Successful', name: 'mftdr4587vfg', desc: '', args: []);
  }

  /// `minutes`
  String get hrtegrg43gvb4hger {
    return Intl.message(
      'minutes',
      name: 'hrtegrg43gvb4hger',
      desc: '',
      args: [],
    );
  }

  /// `Response`
  String get brh45hg43g4tgve {
    return Intl.message(
      'Response',
      name: 'brh45hg43g4tgve',
      desc: '',
      args: [],
    );
  }

  /// `Max weight`
  String get brthgteb4h5g4t35g {
    return Intl.message(
      'Max weight',
      name: 'brthgteb4h5g4t35g',
      desc: '',
      args: [],
    );
  }

  /// `kg`
  String get hyrhh6g453grth4ge {
    return Intl.message('kg', name: 'hyrhh6g453grth4ge', desc: '', args: []);
  }

  /// `Insurance`
  String get nrny5nrnrny5n5y454 {
    return Intl.message(
      'Insurance',
      name: 'nrny5nrnrny5n5y454',
      desc: '',
      args: [],
    );
  }

  /// `On time`
  String get ntnhnhry454 {
    return Intl.message('On time', name: 'ntnhnhry454', desc: '', args: []);
  }

  /// `Write`
  String get nrhnnryhtnyr464 {
    return Intl.message('Write', name: 'nrhnnryhtnyr464', desc: '', args: []);
  }

  /// `Rate courier`
  String get ntnyyh4664bnrgn {
    return Intl.message(
      'Rate courier',
      name: 'ntnyyh4664bnrgn',
      desc: '',
      args: [],
    );
  }

  /// `Write your comment...`
  String get nhthnnhthnty554y54y {
    return Intl.message(
      'Write your comment...',
      name: 'nhthnnhthnty554y54y',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get nhtnhtnyth4465645 {
    return Intl.message(
      'Submit',
      name: 'nhtnhtnyth4465645',
      desc: '',
      args: [],
    );
  }

  /// `Please select a rating`
  String get rynryyrynrh444646 {
    return Intl.message(
      'Please select a rating',
      name: 'rynryyrynrh444646',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your review!`
  String get gergergre335345 {
    return Intl.message(
      'Thank you for your review!',
      name: 'gergergre335345',
      desc: '',
      args: [],
    );
  }

  /// `Error submitting review:`
  String get berbtebteg353434 {
    return Intl.message(
      'Error submitting review:',
      name: 'berbtebteg353434',
      desc: '',
      args: [],
    );
  }

  /// `No reviews`
  String get bgrfw3542rfsd {
    return Intl.message(
      'No reviews',
      name: 'bgrfw3542rfsd',
      desc: '',
      args: [],
    );
  }

  /// `Ukrainian`
  String get ukrainskiy {
    return Intl.message('Ukrainian', name: 'ukrainskiy', desc: '', args: []);
  }

  /// `All categories`
  String get vfdefrwgerg {
    return Intl.message(
      'All categories',
      name: 'vfdefrwgerg',
      desc: '',
      args: [],
    );
  }

  /// `Error loading offer types:`
  String get egreergreger {
    return Intl.message(
      'Error loading offer types:',
      name: 'egreergreger',
      desc: '',
      args: [],
    );
  }

  /// `Error loading cities:`
  String get vfevevreveve {
    return Intl.message(
      'Error loading cities:',
      name: 'vfevevreveve',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get gtrh53ygr43g {
    return Intl.message('From', name: 'gtrh53ygr43g', desc: '', args: []);
  }

  /// `Departure city`
  String get htrh5hetsgft42 {
    return Intl.message(
      'Departure city',
      name: 'htrh5hetsgft42',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get htrhey34tgesft {
    return Intl.message('To', name: 'htrhey34tgesft', desc: '', args: []);
  }

  /// `Destination city`
  String get ryh53gr45h3 {
    return Intl.message(
      'Destination city',
      name: 'ryh53gr45h3',
      desc: '',
      args: [],
    );
  }

  /// `Date from`
  String get br45gre24 {
    return Intl.message('Date from', name: 'br45gre24', desc: '', args: []);
  }

  /// `dd.mm.yyyy`
  String get grereg3gr3g3r3gr {
    return Intl.message(
      'dd.mm.yyyy',
      name: 'grereg3gr3g3r3gr',
      desc: '',
      args: [],
    );
  }

  /// `Date to`
  String get vfedrgev3r2g4 {
    return Intl.message('Date to', name: 'vfedrgev3r2g4', desc: '', args: []);
  }

  /// `Search`
  String get reg23rdwerf32w {
    return Intl.message('Search', name: 'reg23rdwerf32w', desc: '', args: []);
  }

  /// `Jan`
  String get frg4543gr3gwgr3 {
    return Intl.message('Jan', name: 'frg4543gr3gwgr3', desc: '', args: []);
  }

  /// `Feb`
  String get f434f3vgterf43 {
    return Intl.message('Feb', name: 'f434f3vgterf43', desc: '', args: []);
  }

  /// `Mar`
  String get f3f43fr34g345g54h {
    return Intl.message('Mar', name: 'f3f43fr34g345g54h', desc: '', args: []);
  }

  /// `Apr`
  String get d2edf3f34 {
    return Intl.message('Apr', name: 'd2edf3f34', desc: '', args: []);
  }

  /// `May`
  String get ff3rfr34f3erf3r {
    return Intl.message('May', name: 'ff3rfr34f3erf3r', desc: '', args: []);
  }

  /// `Jun`
  String get f3rfr3vf3ref3d {
    return Intl.message('Jun', name: 'f3rfr3vf3ref3d', desc: '', args: []);
  }

  /// `Jul`
  String get f34f34f3r4fr3 {
    return Intl.message('Jul', name: 'f34f34f3r4fr3', desc: '', args: []);
  }

  /// `Aug`
  String get f3f3r5gf34fr34 {
    return Intl.message('Aug', name: 'f3f3r5gf34fr34', desc: '', args: []);
  }

  /// `Sep`
  String get f3rf3r4fder3 {
    return Intl.message('Sep', name: 'f3rf3r4fder3', desc: '', args: []);
  }

  /// `Oct`
  String get frrf33frf34fr3 {
    return Intl.message('Oct', name: 'frrf33frf34fr3', desc: '', args: []);
  }

  /// `Nov`
  String get frefr3rf2343fr4 {
    return Intl.message('Nov', name: 'frefr3rf2343fr4', desc: '', args: []);
  }

  /// `Dec`
  String get gregerrg33gr {
    return Intl.message('Dec', name: 'gregerrg33gr', desc: '', args: []);
  }

  /// `Error:`
  String get veferv3e4ver {
    return Intl.message('Error:', name: 'veferv3e4ver', desc: '', args: []);
  }

  /// `User`
  String get vfewrerewec {
    return Intl.message('User', name: 'vfewrerewec', desc: '', args: []);
  }

  /// `Error sending message:`
  String get vreevrrvrrvrevre {
    return Intl.message(
      'Error sending message:',
      name: 'vreevrrvrrvrevre',
      desc: '',
      args: [],
    );
  }

  /// `Flight date:`
  String get bbrgtrewrg3v {
    return Intl.message(
      'Flight date:',
      name: 'bbrgtrewrg3v',
      desc: '',
      args: [],
    );
  }

  /// `Delivery:`
  String get btegw4er4tgwr45g {
    return Intl.message(
      'Delivery:',
      name: 'btegw4er4tgwr45g',
      desc: '',
      args: [],
    );
  }

  /// `Purchase date:`
  String get ger4w53g3tgsg {
    return Intl.message(
      'Purchase date:',
      name: 'ger4w53g3tgsg',
      desc: '',
      args: [],
    );
  }

  /// `Date:`
  String get te3g35grfgsg {
    return Intl.message('Date:', name: 'te3g35grfgsg', desc: '', args: []);
  }

  /// `User`
  String get gte34rte5rg5er {
    return Intl.message('User', name: 'gte34rte5rg5er', desc: '', args: []);
  }

  /// `Verified`
  String get ge35e5g3gerg3 {
    return Intl.message('Verified', name: 'ge35e5g3gerg3', desc: '', args: []);
  }

  /// `Route:`
  String get getgrw35g3egeg3eg {
    return Intl.message(
      'Route:',
      name: 'getgrw35g3egeg3eg',
      desc: '',
      args: [],
    );
  }

  /// `Time:`
  String get gerg3g3ge {
    return Intl.message('Time:', name: 'gerg3g3ge', desc: '', args: []);
  }

  /// `Weight:`
  String get gerg3g53grg {
    return Intl.message('Weight:', name: 'gerg3g53grg', desc: '', args: []);
  }

  /// `Price:`
  String get rggre5egre {
    return Intl.message('Price:', name: 'rggre5egre', desc: '', args: []);
  }

  /// `Details`
  String get etg5g43gdg {
    return Intl.message('Details', name: 'etg5g43gdg', desc: '', args: []);
  }

  /// `Write`
  String get grt4g4gdeg354 {
    return Intl.message('Write', name: 'grt4g4gdeg354', desc: '', args: []);
  }

  /// `Hide`
  String get gdreg53ge {
    return Intl.message('Hide', name: 'gdreg53ge', desc: '', args: []);
  }

  /// `Show`
  String get grg34g54gdgdg {
    return Intl.message('Show', name: 'grg34g54gdgdg', desc: '', args: []);
  }

  /// `vfedvfd`
  String get vfedvfd {
    return Intl.message('vfedvfd', name: 'vfedvfd', desc: '', args: []);
  }

  /// `online`
  String get fdbdfbweg4g323g {
    return Intl.message('online', name: 'fdbdfbweg4g323g', desc: '', args: []);
  }

  /// `offline`
  String get bfdgbebteb443 {
    return Intl.message('offline', name: 'bfdgbebteb443', desc: '', args: []);
  }

  /// `minutes ago`
  String get bfdebr3b3b33 {
    return Intl.message(
      'minutes ago',
      name: 'bfdebr3b3b33',
      desc: '',
      args: [],
    );
  }

  /// `hours ago`
  String get bfdeberb3brtbfds {
    return Intl.message(
      'hours ago',
      name: 'bfdeberb3brtbfds',
      desc: '',
      args: [],
    );
  }

  /// `days ago`
  String get bebe233btsdvs {
    return Intl.message('days ago', name: 'bebe233btsdvs', desc: '', args: []);
  }

  /// `offline`
  String get bef43g4g343fbsd {
    return Intl.message('offline', name: 'bef43g4g343fbsd', desc: '', args: []);
  }

  /// `Yesterday`
  String get bfvdg34g43g34 {
    return Intl.message('Yesterday', name: 'bfvdg34g43g34', desc: '', args: []);
  }

  /// `Photo`
  String get bfdbfbrewgq34 {
    return Intl.message('Photo', name: 'bfdbfbrewgq34', desc: '', args: []);
  }

  /// `File`
  String get bfdb3brwqgevds432 {
    return Intl.message('File', name: 'bfdb3brwqgevds432', desc: '', args: []);
  }

  /// `Hide`
  String get fgsdgsgdfs {
    return Intl.message('Hide', name: 'fgsdgsgdfs', desc: '', args: []);
  }

  /// `Show more`
  String get bgfdbssdbd {
    return Intl.message('Show more', name: 'bgfdbssdbd', desc: '', args: []);
  }

  /// `Error`
  String get bfdbsdbadfb {
    return Intl.message('Error', name: 'bfdbsdbadfb', desc: '', args: []);
  }

  /// `Success!`
  String get bfdbdffbdsbf {
    return Intl.message('Success!', name: 'bfdbdffbdsbf', desc: '', args: []);
  }

  /// `Loading cities...`
  String get vfegrbfdthgbr5j45ehrw {
    return Intl.message(
      'Loading cities...',
      name: 'vfegrbfdthgbr5j45ehrw',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load cities. Please try again later.`
  String get nkmlregt4lk {
    return Intl.message(
      'Failed to load cities. Please try again later.',
      name: 'nkmlregt4lk',
      desc: '',
      args: [],
    );
  }

  /// `Listing history`
  String get listingHistory {
    return Intl.message(
      'Listing history',
      name: 'listingHistory',
      desc: '',
      args: [],
    );
  }

  /// `Enter the flight number`
  String get enterTheFlightNumber {
    return Intl.message(
      'Enter the flight number',
      name: 'enterTheFlightNumber',
      desc: '',
      args: [],
    );
  }

  /// `Flight number`
  String get flightNumber {
    return Intl.message(
      'Flight number',
      name: 'flightNumber',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `I accept`
  String get betb4b3retb3r {
    return Intl.message('I accept', name: 'betb4b3retb3r', desc: '', args: []);
  }

  /// `View privacy policy`
  String get privacyPolicyvfev {
    return Intl.message(
      'View privacy policy',
      name: 'privacyPolicyvfev',
      desc: '',
      args: [],
    );
  }

  /// `FAQ`
  String get faq {
    return Intl.message('FAQ', name: 'faq', desc: '', args: []);
  }

  /// `View FAQ`
  String get viewFaq {
    return Intl.message('View FAQ', name: 'viewFaq', desc: '', args: []);
  }

  /// `Who are you looking for?`
  String get bgfbgfbgf {
    return Intl.message(
      'Who are you looking for?',
      name: 'bgfbgfbgf',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get bgfbgfb3 {
    return Intl.message('All', name: 'bgfbgfb3', desc: '', args: []);
  }

  /// `Listing type`
  String get hth453gwsf {
    return Intl.message('Listing type', name: 'hth453gwsf', desc: '', args: []);
  }

  /// `Create listing`
  String get bvfv2r {
    return Intl.message('Create listing', name: 'bvfv2r', desc: '', args: []);
  }

  /// `Create a listing to find a courier, sender or buyer`
  String get mjjhmjjmj5 {
    return Intl.message(
      'Create a listing to find a courier, sender or buyer',
      name: 'mjjhmjjmj5',
      desc: '',
      args: [],
    );
  }

  /// `Approximate weight (kg)`
  String get mjjhm6 {
    return Intl.message(
      'Approximate weight (kg)',
      name: 'mjjhm6',
      desc: '',
      args: [],
    );
  }

  /// `min`
  String get vre3gg43gv3r3v3rv {
    return Intl.message('min', name: 'vre3gg43gv3r3v3rv', desc: '', args: []);
  }

  /// `h`
  String get trh34tgvrt4h3g4rwev {
    return Intl.message('h', name: 'trh34tgvrt4h3g4rwev', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'az'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'uk'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
