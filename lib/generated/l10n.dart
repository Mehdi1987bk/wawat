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
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
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
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
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

  /// `Şəxsi kabinetə giriş`
  String get LoginQiris {
    return Intl.message(
      'Şəxsi kabinetə giriş',
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

  /// `E-mail addresinizi daxil edin`
  String get emailAddresiniziDaxilEdin {
    return Intl.message(
      'E-mail addresinizi daxil edin',
      name: 'emailAddresiniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Şifrənizi daxil edin`
  String get ifrniziDaxilEdin {
    return Intl.message(
      'Şifrənizi daxil edin',
      name: 'ifrniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Şifrəmi unutdum`
  String get ifrmiUnutdum {
    return Intl.message(
      'Şifrəmi unutdum',
      name: 'ifrmiUnutdum',
      desc: '',
      args: [],
    );
  }

  /// `İrəli`
  String get rli {
    return Intl.message(
      'İrəli',
      name: 'rli',
      desc: '',
      args: [],
    );
  }

  /// `E-mail adres`
  String get emailAdres {
    return Intl.message(
      'E-mail adres',
      name: 'emailAdres',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Qeydiyyatdan keçin`
  String get qeydiyyatdanKein {
    return Intl.message(
      'Qeydiyyatdan keçin',
      name: 'qeydiyyatdanKein',
      desc: '',
      args: [],
    );
  }

  /// `Şifrə`
  String get ifr {
    return Intl.message(
      'Şifrə',
      name: 'ifr',
      desc: '',
      args: [],
    );
  }

  /// `Şifrəmi unutmusam`
  String get ifrmiUnutmusam {
    return Intl.message(
      'Şifrəmi unutmusam',
      name: 'ifrmiUnutmusam',
      desc: '',
      args: [],
    );
  }

  /// `Salam`
  String get salam {
    return Intl.message(
      'Salam',
      name: 'salam',
      desc: '',
      args: [],
    );
  }

  /// `Bu gün sizə xoş alış-verişlər arzu edirik`
  String get buGnSizXoAlverilrArzuEdirik {
    return Intl.message(
      'Bu gün sizə xoş alış-verişlər arzu edirik',
      name: 'buGnSizXoAlverilrArzuEdirik',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun kodu`
  String get mhsulunKodu {
    return Intl.message(
      'Məhsulun kodu',
      name: 'mhsulunKodu',
      desc: '',
      args: [],
    );
  }

  /// `Status:`
  String get status {
    return Intl.message(
      'Status:',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `SC status: `
  String get scStatus {
    return Intl.message(
      'SC status: ',
      name: 'scStatus',
      desc: '',
      args: [],
    );
  }

  /// `Qiymət: `
  String get qiymt {
    return Intl.message(
      'Qiymət: ',
      name: 'qiymt',
      desc: '',
      args: [],
    );
  }

  /// `Kargo çəkisi: `
  String get kargoKisi {
    return Intl.message(
      'Kargo çəkisi: ',
      name: 'kargoKisi',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun linki`
  String get mhsulunLinki {
    return Intl.message(
      'Məhsulun linki',
      name: 'mhsulunLinki',
      desc: '',
      args: [],
    );
  }

  /// `Sifariş ver`
  String get sifariVer {
    return Intl.message(
      'Sifariş ver',
      name: 'sifariVer',
      desc: '',
      args: [],
    );
  }

  /// `Faktura`
  String get fakturaLavEt {
    return Intl.message(
      'Faktura',
      name: 'fakturaLavEt',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Endirin`
  String get endirin {
    return Intl.message(
      'Endirin',
      name: 'endirin',
      desc: '',
      args: [],
    );
  }

  /// `Bağlamalarım`
  String get balamalarm {
    return Intl.message(
      'Bağlamalarım',
      name: 'balamalarm',
      desc: '',
      args: [],
    );
  }

  /// `Bütün bağlamalarım`
  String get btnBalamalarm {
    return Intl.message(
      'Bütün bağlamalarım',
      name: 'btnBalamalarm',
      desc: '',
      args: [],
    );
  }

  /// `Mağaza: `
  String get maaza {
    return Intl.message(
      'Mağaza: ',
      name: 'maaza',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun tipi: `
  String get mhsulunTipi {
    return Intl.message(
      'Məhsulun tipi: ',
      name: 'mhsulunTipi',
      desc: '',
      args: [],
    );
  }

  /// `Kargo qiyməti: `
  String get kargoQiymti {
    return Intl.message(
      'Kargo qiyməti: ',
      name: 'kargoQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Qeyd`
  String get qeyd {
    return Intl.message(
      'Qeyd',
      name: 'qeyd',
      desc: '',
      args: [],
    );
  }

  /// `Ödəniş edin`
  String get dniEdin {
    return Intl.message(
      'Ödəniş edin',
      name: 'dniEdin',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `əlavə et`
  String get lavEt {
    return Intl.message(
      'əlavə et',
      name: 'lavEt',
      desc: '',
      args: [],
    );
  }

  /// `Kod`
  String get kod {
    return Intl.message(
      'Kod',
      name: 'kod',
      desc: '',
      args: [],
    );
  }

  /// `Faktura kodunu əlavə edin`
  String get fakturaKodunuLavEdin {
    return Intl.message(
      'Faktura kodunu əlavə edin',
      name: 'fakturaKodunuLavEdin',
      desc: '',
      args: [],
    );
  }

  /// `Düzəliş`
  String get dzli {
    return Intl.message(
      'Düzəliş',
      name: 'dzli',
      desc: '',
      args: [],
    );
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

  /// `Məhsulun qiyməti (TL)`
  String get mhsulunQiymtiTl {
    return Intl.message(
      'Məhsulun qiyməti (TL)',
      name: 'mhsulunQiymtiTl',
      desc: '',
      args: [],
    );
  }

  /// `Qiyməti`
  String get qiymti {
    return Intl.message(
      'Qiyməti',
      name: 'qiymti',
      desc: '',
      args: [],
    );
  }

  /// `Faktura`
  String get faktura {
    return Intl.message(
      'Faktura',
      name: 'faktura',
      desc: '',
      args: [],
    );
  }

  /// `Ətraflı`
  String get trafl {
    return Intl.message(
      'Ətraflı',
      name: 'trafl',
      desc: '',
      args: [],
    );
  }

  /// `Faktura qiyməti`
  String get fakturaQiymti {
    return Intl.message(
      'Faktura qiyməti',
      name: 'fakturaQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Kargo takip NO.`
  String get kargoTakipNo {
    return Intl.message(
      'Kargo takip NO.',
      name: 'kargoTakipNo',
      desc: '',
      args: [],
    );
  }

  /// `Çəki`
  String get ki {
    return Intl.message(
      'Çəki',
      name: 'ki',
      desc: '',
      args: [],
    );
  }

  /// `Çatdırılma`
  String get atdrlma {
    return Intl.message(
      'Çatdırılma',
      name: 'atdrlma',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun sayı`
  String get mhsulunSay {
    return Intl.message(
      'Məhsulun sayı',
      name: 'mhsulunSay',
      desc: '',
      args: [],
    );
  }

  /// `Əlavə xidmətlər`
  String get lavXidmtlr {
    return Intl.message(
      'Əlavə xidmətlər',
      name: 'lavXidmtlr',
      desc: '',
      args: [],
    );
  }

  /// `Kateqoriya`
  String get kateqoriya {
    return Intl.message(
      'Kateqoriya',
      name: 'kateqoriya',
      desc: '',
      args: [],
    );
  }

  /// `Ödəmə`
  String get dm {
    return Intl.message(
      'Ödəmə',
      name: 'dm',
      desc: '',
      args: [],
    );
  }

  /// `SC status`
  String get scStatuss {
    return Intl.message(
      'SC status',
      name: 'scStatuss',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get statuss {
    return Intl.message(
      'Status',
      name: 'statuss',
      desc: '',
      args: [],
    );
  }

  /// `Əməliyyatlar`
  String get mliyyatlar {
    return Intl.message(
      'Əməliyyatlar',
      name: 'mliyyatlar',
      desc: '',
      args: [],
    );
  }

  /// `Faktura əlavə edin`
  String get fakturaLavEdin {
    return Intl.message(
      'Faktura əlavə edin',
      name: 'fakturaLavEdin',
      desc: '',
      args: [],
    );
  }

  /// `Yadda saxla`
  String get yaddaSaxla {
    return Intl.message(
      'Yadda saxla',
      name: 'yaddaSaxla',
      desc: '',
      args: [],
    );
  }

  /// `Bağlamalar`
  String get balamalar {
    return Intl.message(
      'Bağlamalar',
      name: 'balamalar',
      desc: '',
      args: [],
    );
  }

  /// `Sifarişlər`
  String get sifarilr {
    return Intl.message(
      'Sifarişlər',
      name: 'sifarilr',
      desc: '',
      args: [],
    );
  }

  /// `Kuryer sifariş et`
  String get kuryerSifariEt {
    return Intl.message(
      'Kuryer sifariş et',
      name: 'kuryerSifariEt',
      desc: '',
      args: [],
    );
  }

  /// `Xidmətlərimi`
  String get xidmtlrimi {
    return Intl.message(
      'Xidmətlərimi',
      name: 'xidmtlrimi',
      desc: '',
      args: [],
    );
  }

  /// `Giriş et`
  String get giriEt {
    return Intl.message(
      'Giriş et',
      name: 'giriEt',
      desc: '',
      args: [],
    );
  }

  /// `DIgər bölmələr`
  String get digrBlmlr {
    return Intl.message(
      'DIgər bölmələr',
      name: 'digrBlmlr',
      desc: '',
      args: [],
    );
  }

  /// `Balansınız`
  String get balansnz {
    return Intl.message(
      'Balansınız',
      name: 'balansnz',
      desc: '',
      args: [],
    );
  }

  /// `AZN balansı`
  String get aznBalans {
    return Intl.message(
      'AZN balansı',
      name: 'aznBalans',
      desc: '',
      args: [],
    );
  }

  /// `250.0`
  String get aznnnn {
    return Intl.message(
      '250.0',
      name: 'aznnnn',
      desc: '',
      args: [],
    );
  }

  /// `TL balansı`
  String get tlBalans {
    return Intl.message(
      'TL balansı',
      name: 'tlBalans',
      desc: '',
      args: [],
    );
  }

  /// `Şəxsi kabinet`
  String get xsiKabinet {
    return Intl.message(
      'Şəxsi kabinet',
      name: 'xsiKabinet',
      desc: '',
      args: [],
    );
  }

  /// `© 2021 Kango | Bütün Hüquqlar Qorunur`
  String get oluxBtnHquqlarQorunur {
    return Intl.message(
      '© 2021 Kango | Bütün Hüquqlar Qorunur',
      name: 'oluxBtnHquqlarQorunur',
      desc: '',
      args: [],
    );
  }

  /// `Şəxsi məlumatlarım`
  String get xsiMlumatlarm {
    return Intl.message(
      'Şəxsi məlumatlarım',
      name: 'xsiMlumatlarm',
      desc: '',
      args: [],
    );
  }

  /// `Xarici ünvanlarım`
  String get xariciNvanlarm {
    return Intl.message(
      'Xarici ünvanlarım',
      name: 'xariciNvanlarm',
      desc: '',
      args: [],
    );
  }

  /// `Şifrəni dəyiş`
  String get ifrniDyi {
    return Intl.message(
      'Şifrəni dəyiş',
      name: 'ifrniDyi',
      desc: '',
      args: [],
    );
  }

  /// `Çıxış et`
  String get xEt {
    return Intl.message(
      'Çıxış et',
      name: 'xEt',
      desc: '',
      args: [],
    );
  }

  /// `Kuryer sifarişi`
  String get kuryerSifarii {
    return Intl.message(
      'Kuryer sifarişi',
      name: 'kuryerSifarii',
      desc: '',
      args: [],
    );
  }

  /// `Onlayn daşıma haqqı ödənişi`
  String get onlaynDamaHaqqDnii {
    return Intl.message(
      'Onlayn daşıma haqqı ödənişi',
      name: 'onlaynDamaHaqqDnii',
      desc: '',
      args: [],
    );
  }

  /// `Tariflər`
  String get tariflr {
    return Intl.message(
      'Tariflər',
      name: 'tariflr',
      desc: '',
      args: [],
    );
  }

  /// `Xəbərlər`
  String get xbrlr {
    return Intl.message(
      'Xəbərlər',
      name: 'xbrlr',
      desc: '',
      args: [],
    );
  }

  /// `Kango filialları`
  String get kangoFiliallar {
    return Intl.message(
      'Kango filialları',
      name: 'kangoFiliallar',
      desc: '',
      args: [],
    );
  }

  /// `Əlaqə`
  String get laq {
    return Intl.message(
      'Əlaqə',
      name: 'laq',
      desc: '',
      args: [],
    );
  }

  /// `tarixçəsi`
  String get tarixsi {
    return Intl.message(
      'tarixçəsi',
      name: 'tarixsi',
      desc: '',
      args: [],
    );
  }

  /// `Kuryer tarifləri`
  String get kuryerTariflri {
    return Intl.message(
      'Kuryer tarifləri',
      name: 'kuryerTariflri',
      desc: '',
      args: [],
    );
  }

  /// `Sürətli poçt daşıma xidməti`
  String get srtliPotDamaXidmti {
    return Intl.message(
      'Sürətli poçt daşıma xidməti',
      name: 'srtliPotDamaXidmti',
      desc: '',
      args: [],
    );
  }

  /// `Bakı şəhər daxili`
  String get bakHrDaxili {
    return Intl.message(
      'Bakı şəhər daxili',
      name: 'bakHrDaxili',
      desc: '',
      args: [],
    );
  }

  /// `Bakı kəndləri`
  String get bakKndlri {
    return Intl.message(
      'Bakı kəndləri',
      name: 'bakKndlri',
      desc: '',
      args: [],
    );
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

  /// `Qeyd: Kuryer ödəşini nəğd şəkildə bağlamanızı çatdıran kuryerə ödəyəcəksiniz`
  String get qeydKuryerDiniNdKildBalamanzAtdranKuryerDycksiniz {
    return Intl.message(
      'Qeyd: Kuryer ödəşini nəğd şəkildə bağlamanızı çatdıran kuryerə ödəyəcəksiniz',
      name: 'qeydKuryerDiniNdKildBalamanzAtdranKuryerDycksiniz',
      desc: '',
      args: [],
    );
  }

  /// `Kuryer sifarişi sadəcə Nərimanov filialı üçün keçərlidir`
  String get kuryerSifariiSadcNrimanovFilialNKerlidir {
    return Intl.message(
      'Kuryer sifarişi sadəcə Nərimanov filialı üçün keçərlidir',
      name: 'kuryerSifariiSadcNrimanovFilialNKerlidir',
      desc: '',
      args: [],
    );
  }

  /// `Ünvanınızı qeyd edin`
  String get nvannzQeydEdin {
    return Intl.message(
      'Ünvanınızı qeyd edin',
      name: 'nvannzQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Adınız`
  String get adnz {
    return Intl.message(
      'Adınız',
      name: 'adnz',
      desc: '',
      args: [],
    );
  }

  /// `Adınızı daxil edin`
  String get adnzDaxilEdin {
    return Intl.message(
      'Adınızı daxil edin',
      name: 'adnzDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Soyadınız`
  String get soyadnz {
    return Intl.message(
      'Soyadınız',
      name: 'soyadnz',
      desc: '',
      args: [],
    );
  }

  /// `Soyadınızı daxil edin`
  String get soyadnzDaxilEdin {
    return Intl.message(
      'Soyadınızı daxil edin',
      name: 'soyadnzDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Doğum tarixiniz`
  String get doumTarixiniz {
    return Intl.message(
      'Doğum tarixiniz',
      name: 'doumTarixiniz',
      desc: '',
      args: [],
    );
  }

  /// `Cinsiniz`
  String get cinsiniz {
    return Intl.message(
      'Cinsiniz',
      name: 'cinsiniz',
      desc: '',
      args: [],
    );
  }

  /// `Email adresiniz`
  String get emailAdresiniz {
    return Intl.message(
      'Email adresiniz',
      name: 'emailAdresiniz',
      desc: '',
      args: [],
    );
  }

  /// `Email adresinizi daxil edin`
  String get emailAdresiniziDaxilEdin {
    return Intl.message(
      'Email adresinizi daxil edin',
      name: 'emailAdresiniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Doğum tarixinizi qeyd edin`
  String get doumTarixiniziQeydEdin {
    return Intl.message(
      'Doğum tarixinizi qeyd edin',
      name: 'doumTarixiniziQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Kişi`
  String get kii {
    return Intl.message(
      'Kişi',
      name: 'kii',
      desc: '',
      args: [],
    );
  }

  /// `Qadın`
  String get qadn {
    return Intl.message(
      'Qadın',
      name: 'qadn',
      desc: '',
      args: [],
    );
  }

  /// `Faktura əlavə et`
  String get fakturaLavEtcsa {
    return Intl.message(
      'Faktura əlavə et',
      name: 'fakturaLavEtcsa',
      desc: '',
      args: [],
    );
  }

  /// `Kargo nömrəsi`
  String get kargoNmrsi {
    return Intl.message(
      'Kargo nömrəsi',
      name: 'kargoNmrsi',
      desc: '',
      args: [],
    );
  }

  /// `Təsdiq et`
  String get tsdiqEt {
    return Intl.message(
      'Təsdiq et',
      name: 'tsdiqEt',
      desc: '',
      args: [],
    );
  }

  /// `Təsdiqlə və sifariş et`
  String get tsdiqlVSifariEt {
    return Intl.message(
      'Təsdiqlə və sifariş et',
      name: 'tsdiqlVSifariEt',
      desc: '',
      args: [],
    );
  }

  /// `Ana səhifə`
  String get anaShif {
    return Intl.message(
      'Ana səhifə',
      name: 'anaShif',
      desc: '',
      args: [],
    );
  }

  /// `Tariflərimiz -`
  String get tariflrimiz {
    return Intl.message(
      'Tariflərimiz -',
      name: 'tariflrimiz',
      desc: '',
      args: [],
    );
  }

  /// `Türkiyədən çatdırılma`
  String get trkiydnAtdrlma {
    return Intl.message(
      'Türkiyədən çatdırılma',
      name: 'trkiydnAtdrlma',
      desc: '',
      args: [],
    );
  }

  /// `Bakı və Sumqayıt şəhərləri üzrə`
  String get bakVSumqaytHrlriZr {
    return Intl.message(
      'Bakı və Sumqayıt şəhərləri üzrə',
      name: 'bakVSumqaytHrlriZr',
      desc: '',
      args: [],
    );
  }

  /// `Gəncə, Mingəçevir və Lənkəran şəhərləri üzrə`
  String get gncMingevirVLnkranHrlriZr {
    return Intl.message(
      'Gəncə, Mingəçevir və Lənkəran şəhərləri üzrə',
      name: 'gncMingevirVLnkranHrlriZr',
      desc: '',
      args: [],
    );
  }

  /// `Standart çatdırılma və maye məhsulları üzrə`
  String get standartAtdrlmaVMayeMhsullarZr {
    return Intl.message(
      'Standart çatdırılma və maye məhsulları üzrə',
      name: 'standartAtdrlmaVMayeMhsullarZr',
      desc: '',
      args: [],
    );
  }

  /// `HƏCMSƏL məhsullar üzrə`
  String get hcmslMhsullarZr {
    return Intl.message(
      'HƏCMSƏL məhsullar üzrə',
      name: 'hcmslMhsullarZr',
      desc: '',
      args: [],
    );
  }

  /// `Üç tərəfinin (en, uzunluğ, hündürlük) cəmi 1 metrdən çox olan bağlamalar həcmsəl çəki kimi hesablanır. Həcmsəl çəki = En x Uzunluğ x Hündürlük / 6000. Hazırda həcimsəl çəki hesablanmır.`
  String get trfininEnUzunluHndrlkCmi1MetrdnOxOlanBalamalar {
    return Intl.message(
      'Üç tərəfinin (en, uzunluğ, hündürlük) cəmi 1 metrdən çox olan bağlamalar həcmsəl çəki kimi hesablanır. Həcmsəl çəki = En x Uzunluğ x Hündürlük / 6000. Hazırda həcimsəl çəki hesablanmır.',
      name: 'trfininEnUzunluHndrlkCmi1MetrdnOxOlanBalamalar',
      desc: '',
      args: [],
    );
  }

  /// `0 qr - 100 qr`
  String get Qr100Qrc {
    return Intl.message(
      '0 qr - 100 qr',
      name: 'Qr100Qrc',
      desc: '',
      args: [],
    );
  }

  /// `101 qr - 250 qr`
  String get Qr250Qr {
    return Intl.message(
      '101 qr - 250 qr',
      name: 'Qr250Qr',
      desc: '',
      args: [],
    );
  }

  /// `251 qr - 500 qr`
  String get Qr500Qr {
    return Intl.message(
      '251 qr - 500 qr',
      name: 'Qr500Qr',
      desc: '',
      args: [],
    );
  }

  /// `501 qr - 1 kq`
  String get Qr1Kq {
    return Intl.message(
      '501 qr - 1 kq',
      name: 'Qr1Kq',
      desc: '',
      args: [],
    );
  }

  /// `1 kq üzərində`
  String get KqZrind {
    return Intl.message(
      '1 kq üzərində',
      name: 'KqZrind',
      desc: '',
      args: [],
    );
  }

  /// `Təkrar şifrəniz`
  String get tkrarIfrniz {
    return Intl.message(
      'Təkrar şifrəniz',
      name: 'tkrarIfrniz',
      desc: '',
      args: [],
    );
  }

  /// `Təyin etdiyiniz giriş şifrəsini təkrar daxil edin`
  String get tyinEtdiyinizGiriIfrsiniTkrarDaxilEdin {
    return Intl.message(
      'Təyin etdiyiniz giriş şifrəsini təkrar daxil edin',
      name: 'tyinEtdiyinizGiriIfrsiniTkrarDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Şifrəniz`
  String get ifrniz {
    return Intl.message(
      'Şifrəniz',
      name: 'ifrniz',
      desc: '',
      args: [],
    );
  }

  /// `Giriş şifrənizi təyin edin`
  String get giriIfrniziTyinEdin {
    return Intl.message(
      'Giriş şifrənizi təyin edin',
      name: 'giriIfrniziTyinEdin',
      desc: '',
      args: [],
    );
  }

  /// `Mobil nömrəniz`
  String get mobilNmrniz {
    return Intl.message(
      'Mobil nömrəniz',
      name: 'mobilNmrniz',
      desc: '',
      args: [],
    );
  }

  /// `Cins`
  String get cins {
    return Intl.message(
      'Cins',
      name: 'cins',
      desc: '',
      args: [],
    );
  }

  /// `Mağaza`
  String get maazae {
    return Intl.message(
      'Mağaza',
      name: 'maazae',
      desc: '',
      args: [],
    );
  }

  /// `kq`
  String get kq {
    return Intl.message(
      'kq',
      name: 'kq',
      desc: '',
      args: [],
    );
  }

  /// `Mağaza`
  String get maazavd {
    return Intl.message(
      'Mağaza',
      name: 'maazavd',
      desc: '',
      args: [],
    );
  }

  /// `tl`
  String get tl {
    return Intl.message(
      'tl',
      name: 'tl',
      desc: '',
      args: [],
    );
  }

  /// `Bağlama:`
  String get balama {
    return Intl.message(
      'Bağlama:',
      name: 'balama',
      desc: '',
      args: [],
    );
  }

  /// `Ad, Soyad:`
  String get adSoyad {
    return Intl.message(
      'Ad, Soyad:',
      name: 'adSoyad',
      desc: '',
      args: [],
    );
  }

  /// `Ünvan:`
  String get nvan {
    return Intl.message(
      'Ünvan:',
      name: 'nvan',
      desc: '',
      args: [],
    );
  }

  /// `Geri`
  String get geri {
    return Intl.message(
      'Geri',
      name: 'geri',
      desc: '',
      args: [],
    );
  }

  /// `Şəxsiyyət vəsiqəsinin seriya nömrəsi`
  String get xsiyytVsiqsininSeriyaNmrsi {
    return Intl.message(
      'Şəxsiyyət vəsiqəsinin seriya nömrəsi',
      name: 'xsiyytVsiqsininSeriyaNmrsi',
      desc: '',
      args: [],
    );
  }

  /// `Şəxsiyyət vəsiqəsinin FİN kodu`
  String get xsiyytVsiqsininFnKodu {
    return Intl.message(
      'Şəxsiyyət vəsiqəsinin FİN kodu',
      name: 'xsiyytVsiqsininFnKodu',
      desc: '',
      args: [],
    );
  }

  /// `Filial seçin`
  String get filialSein {
    return Intl.message(
      'Filial seçin',
      name: 'filialSein',
      desc: '',
      args: [],
    );
  }

  /// `Ş.V. -nin seriya nömrəsi`
  String get vNinSeriyaNmrsi {
    return Intl.message(
      'Ş.V. -nin seriya nömrəsi',
      name: 'vNinSeriyaNmrsi',
      desc: '',
      args: [],
    );
  }

  /// `Ünvanınızı daxil edin`
  String get nvannzDaxilEdin {
    return Intl.message(
      'Ünvanınızı daxil edin',
      name: 'nvannzDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Daxil etdiyiniz e-mail ünvana növbəti addım haqqında məktub göndərildi!`
  String get daxilEtdiyini {
    return Intl.message(
      'Daxil etdiyiniz e-mail ünvana növbəti addım haqqında məktub göndərildi!',
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

  /// `Telefon nömrələrimiz`
  String get telefonNmrlrimiz {
    return Intl.message(
      'Telefon nömrələrimiz',
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

  /// `Ünvan`
  String get nvand {
    return Intl.message(
      'Ünvan',
      name: 'nvand',
      desc: '',
      args: [],
    );
  }

  /// `Bakı şəhəri, Nərimanov rayonu, Ağa Neymatulla b 44/2 (Metropark t.m yanı)`
  String get bakHriNrimanovRayonuAaNeymatullaB442MetroparkTm {
    return Intl.message(
      'Bakı şəhəri, Nərimanov rayonu, Ağa Neymatulla b 44/2 (Metropark t.m yanı)',
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

  /// `Bildirişlərim`
  String get bildirilrim {
    return Intl.message(
      'Bildirişlərim',
      name: 'bildirilrim',
      desc: '',
      args: [],
    );
  }

  /// `Balans keçmişi`
  String get balansKemii {
    return Intl.message(
      'Balans keçmişi',
      name: 'balansKemii',
      desc: '',
      args: [],
    );
  }

  /// `Balans tarixçəsi`
  String get balansTarixsi {
    return Intl.message(
      'Balans tarixçəsi',
      name: 'balansTarixsi',
      desc: '',
      args: [],
    );
  }

  /// `Balans artımı`
  String get balansArtm {
    return Intl.message(
      'Balans artımı',
      name: 'balansArtm',
      desc: '',
      args: [],
    );
  }

  /// `Bağla`
  String get bala {
    return Intl.message(
      'Bağla',
      name: 'bala',
      desc: '',
      args: [],
    );
  }

  /// `Balans artırın`
  String get balansArtrn {
    return Intl.message(
      'Balans artırın',
      name: 'balansArtrn',
      desc: '',
      args: [],
    );
  }

  /// `İstədiyiniz məbləği daxil edin`
  String get stdiyinizMbliDaxilEdin {
    return Intl.message(
      'İstədiyiniz məbləği daxil edin',
      name: 'stdiyinizMbliDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `TL balansınızdan çıxıldı`
  String get tlBalansnzdanXld {
    return Intl.message(
      'TL balansınızdan çıxıldı',
      name: 'tlBalansnzdanXld',
      desc: '',
      args: [],
    );
  }

  /// `TL balansınıza əlavə olundu`
  String get tlBalansnzaLavOlundu {
    return Intl.message(
      'TL balansınıza əlavə olundu',
      name: 'tlBalansnzaLavOlundu',
      desc: '',
      args: [],
    );
  }

  /// `Azn balansınıza əlavə olundu`
  String get aznBalansnzaLavOlundu {
    return Intl.message(
      'Azn balansınıza əlavə olundu',
      name: 'aznBalansnzaLavOlundu',
      desc: '',
      args: [],
    );
  }

  /// `Azn balansınızdan çıxıldı`
  String get aznBalansnzdanXld {
    return Intl.message(
      'Azn balansınızdan çıxıldı',
      name: 'aznBalansnzdanXld',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun qiyməti`
  String get mhsulunQiymti {
    return Intl.message(
      'Məhsulun qiyməti',
      name: 'mhsulunQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Toplam məbləğ`
  String get toplamMbl {
    return Intl.message(
      'Toplam məbləğ',
      name: 'toplamMbl',
      desc: '',
      args: [],
    );
  }

  /// `Paket birlesmesi`
  String get paketBirlesmesi {
    return Intl.message(
      'Paket birlesmesi',
      name: 'paketBirlesmesi',
      desc: '',
      args: [],
    );
  }

  /// `Kargo dəyəri`
  String get kargoDyri {
    return Intl.message(
      'Kargo dəyəri',
      name: 'kargoDyri',
      desc: '',
      args: [],
    );
  }

  /// `Sifarişiniz yeniləndi və yaddaşa verildi`
  String get sifariinizYenilndiVYaddaaVerildi {
    return Intl.message(
      'Sifarişiniz yeniləndi və yaddaşa verildi',
      name: 'sifariinizYenilndiVYaddaaVerildi',
      desc: '',
      args: [],
    );
  }

  /// `Dəyişikliklər qeydə alındı`
  String get dyiikliklrQeydAlnd {
    return Intl.message(
      'Dəyişikliklər qeydə alındı',
      name: 'dyiikliklrQeydAlnd',
      desc: '',
      args: [],
    );
  }

  /// `Məhsul`
  String get mhsul {
    return Intl.message(
      'Məhsul',
      name: 'mhsul',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun ölçüsü`
  String get mhsulunLs {
    return Intl.message(
      'Məhsulun ölçüsü',
      name: 'mhsulunLs',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun ölçüsünü qeyd edin`
  String get mhsulunLsnQeydEdin {
    return Intl.message(
      'Məhsulun ölçüsünü qeyd edin',
      name: 'mhsulunLsnQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun linkini qeyd edin`
  String get mhsulunLinkiniQeydEdin {
    return Intl.message(
      'Məhsulun linkini qeyd edin',
      name: 'mhsulunLinkiniQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Yeni məhsul`
  String get yeniMhsul {
    return Intl.message(
      'Yeni məhsul',
      name: 'yeniMhsul',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun sayını qeyd edin`
  String get mhsulunSaynQeydEdin {
    return Intl.message(
      'Məhsulun sayını qeyd edin',
      name: 'mhsulunSaynQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun qiyməti qeyd edin`
  String get mhsulunQiymtiQeydEdin {
    return Intl.message(
      'Məhsulun qiyməti qeyd edin',
      name: 'mhsulunQiymtiQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun digər detalları`
  String get mhsulunDigrDetallar {
    return Intl.message(
      'Məhsulun digər detalları',
      name: 'mhsulunDigrDetallar',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun digər detallarını qeyd edin`
  String get mhsulunDigrDetallarnQeydEdin {
    return Intl.message(
      'Məhsulun digər detallarını qeyd edin',
      name: 'mhsulunDigrDetallarnQeydEdin',
      desc: '',
      args: [],
    );
  }

  /// `Sifariş et`
  String get sifariEt {
    return Intl.message(
      'Sifariş et',
      name: 'sifariEt',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun qiymətini qeyd edərkən Türkiyə daxili kargonu da üzərinə gəlib qiymət xanasına yazmalısınız. Əks halda sifrişiniz alınarkən balansınızdan çıxılacaqdır.`
  String get mhsulunQiymtiniQeydEdrknTrkiyDaxiliKargonuDaZrinGlib {
    return Intl.message(
      'Məhsulun qiymətini qeyd edərkən Türkiyə daxili kargonu da üzərinə gəlib qiymət xanasına yazmalısınız. Əks halda sifrişiniz alınarkən balansınızdan çıxılacaqdır.',
      name: 'mhsulunQiymtiniQeydEdrknTrkiyDaxiliKargonuDaZrinGlib',
      desc: '',
      args: [],
    );
  }

  /// `Geriyə`
  String get geriy {
    return Intl.message(
      'Geriyə',
      name: 'geriy',
      desc: '',
      args: [],
    );
  }

  /// `Toplam qiymət`
  String get toplamQiymt {
    return Intl.message(
      'Toplam qiymət',
      name: 'toplamQiymt',
      desc: '',
      args: [],
    );
  }

  /// `Ümumi məhsul qiyməti`
  String get mumiMhsulQiymti {
    return Intl.message(
      'Ümumi məhsul qiyməti',
      name: 'mumiMhsulQiymti',
      desc: '',
      args: [],
    );
  }

  /// `Ümumi xidmət haqqı (3%)`
  String get mumiXidmtHaqq5 {
    return Intl.message(
      'Ümumi xidmət haqqı (3%)',
      name: 'mumiXidmtHaqq5',
      desc: '',
      args: [],
    );
  }

  /// `Ümumi məhsul sayı`
  String get mumiMhsulSay {
    return Intl.message(
      'Ümumi məhsul sayı',
      name: 'mumiMhsulSay',
      desc: '',
      args: [],
    );
  }

  /// `Təcili sifariş`
  String get tciliSifari {
    return Intl.message(
      'Təcili sifariş',
      name: 'tciliSifari',
      desc: '',
      args: [],
    );
  }

  /// `* Əlavə xidmətlərin ödənişini sifarişin təhvili zamanı edilir.`
  String get lavXidmtlrinDniiniSifariinThviliZamanEdilir {
    return Intl.message(
      '* Əlavə xidmətlərin ödənişini sifarişin təhvili zamanı edilir.',
      name: 'lavXidmtlrinDniiniSifariinThviliZamanEdilir',
      desc: '',
      args: [],
    );
  }

  /// `Seçilmiş xidmətlər`
  String get seilmiXidmtlr {
    return Intl.message(
      'Seçilmiş xidmətlər',
      name: 'seilmiXidmtlr',
      desc: '',
      args: [],
    );
  }

  /// `+1`
  String get one {
    return Intl.message(
      '+1',
      name: 'one',
      desc: '',
      args: [],
    );
  }

  /// `* Sifarişin məbləği kargonuz Türkiyə ofisinə çatdıqda bəlli olacaqdır.`
  String get sifariinMbliKargonuzTrkiyOfisinAtdqdaBlliOlacaqdr {
    return Intl.message(
      '* Sifarişin məbləği kargonuz Türkiyə ofisinə çatdıqda bəlli olacaqdır.',
      name: 'sifariinMbliKargonuzTrkiyOfisinAtdqdaBlliOlacaqdr',
      desc: '',
      args: [],
    );
  }

  /// `* Zəhmət olmasa məsafəli satış sözləşməsini qəbul edin.`
  String get zhmtOlmasaMsafliSatSzlmsiniQbulEdin {
    return Intl.message(
      '* Zəhmət olmasa məsafəli satış sözləşməsini qəbul edin.',
      name: 'zhmtOlmasaMsafliSatSzlmsiniQbulEdin',
      desc: '',
      args: [],
    );
  }

  /// `Məsafəli satış sözləşməsini qəbul edirəm.`
  String get msafliSatSzlmsiniQbulEdirm {
    return Intl.message(
      'Məsafəli satış sözləşməsini qəbul edirəm.',
      name: 'msafliSatSzlmsiniQbulEdirm',
      desc: '',
      args: [],
    );
  }

  /// `Səbətə əlavə et`
  String get sbtLavEt {
    return Intl.message(
      'Səbətə əlavə et',
      name: 'sbtLavEt',
      desc: '',
      args: [],
    );
  }

  /// `Ödəniş et`
  String get dniEt {
    return Intl.message(
      'Ödəniş et',
      name: 'dniEt',
      desc: '',
      args: [],
    );
  }

  /// `Səbətim`
  String get sbtim {
    return Intl.message(
      'Səbətim',
      name: 'sbtim',
      desc: '',
      args: [],
    );
  }

  /// `Say`
  String get say {
    return Intl.message(
      'Say',
      name: 'say',
      desc: '',
      args: [],
    );
  }

  /// `Ölçü:`
  String get l {
    return Intl.message(
      'Ölçü:',
      name: 'l',
      desc: '',
      args: [],
    );
  }

  /// `Şəxsi məlumatlar`
  String get xsiMlumatlar {
    return Intl.message(
      'Şəxsi məlumatlar',
      name: 'xsiMlumatlar',
      desc: '',
      args: [],
    );
  }

  /// `Ad`
  String get ad {
    return Intl.message(
      'Ad',
      name: 'ad',
      desc: '',
      args: [],
    );
  }

  /// `Soyad`
  String get soyad {
    return Intl.message(
      'Soyad',
      name: 'soyad',
      desc: '',
      args: [],
    );
  }

  /// `Filial`
  String get filial {
    return Intl.message(
      'Filial',
      name: 'filial',
      desc: '',
      args: [],
    );
  }

  /// `Filiallarımız`
  String get filiallarmz {
    return Intl.message(
      'Filiallarımız',
      name: 'filiallarmz',
      desc: '',
      args: [],
    );
  }

  /// `Kango Tel:`
  String get kangoTel {
    return Intl.message(
      'Kango Tel:',
      name: 'kangoTel',
      desc: '',
      args: [],
    );
  }

  /// `Sizin paketiniz yoxdur`
  String get sizinPaxdur {
    return Intl.message(
      'Sizin paketiniz yoxdur',
      name: 'sizinPaxdur',
      desc: '',
      args: [],
    );
  }

  /// `Paket elave olundu`
  String get paketElaveOlundu {
    return Intl.message(
      'Paket elave olundu',
      name: 'paketElaveOlundu',
      desc: '',
      args: [],
    );
  }

  /// `Paket əlavə edilmişdir`
  String get paketLavEdilmidir {
    return Intl.message(
      'Paket əlavə edilmişdir',
      name: 'paketLavEdilmidir',
      desc: '',
      args: [],
    );
  }

  /// `Ümumi qiymət:`
  String get mumiQiymt {
    return Intl.message(
      'Ümumi qiymət:',
      name: 'mumiQiymt',
      desc: '',
      args: [],
    );
  }

  /// `Bakı ofisində bağlamalarınız yoxdur`
  String get bakOfisindBalamalarnzYoxdur {
    return Intl.message(
      'Bakı ofisində bağlamalarınız yoxdur',
      name: 'bakOfisindBalamalarnzYoxdur',
      desc: '',
      args: [],
    );
  }

  /// `Məhsulun çəkisi:`
  String get mhsulunKisi {
    return Intl.message(
      'Məhsulun çəkisi:',
      name: 'mhsulunKisi',
      desc: '',
      args: [],
    );
  }

  /// `Əlavə xidmət:`
  String get lavXidmt {
    return Intl.message(
      'Əlavə xidmət:',
      name: 'lavXidmt',
      desc: '',
      args: [],
    );
  }

  /// `Bu məhsulu simək istədiyinizə əminsiniz?`
  String get buMhsuluSimkIstdiyinizMinsiniz {
    return Intl.message(
      'Bu məhsulu simək istədiyinizə əminsiniz?',
      name: 'buMhsuluSimkIstdiyinizMinsiniz',
      desc: '',
      args: [],
    );
  }

  /// `Beli`
  String get beli {
    return Intl.message(
      'Beli',
      name: 'beli',
      desc: '',
      args: [],
    );
  }

  /// `Heir`
  String get heir {
    return Intl.message(
      'Heir',
      name: 'heir',
      desc: '',
      args: [],
    );
  }

  /// `Onlayn daşıma`
  String get onlaynDama {
    return Intl.message(
      'Onlayn daşıma',
      name: 'onlaynDama',
      desc: '',
      args: [],
    );
  }

  /// `Ünvan Baş ofis`
  String get nvanBaOfis {
    return Intl.message(
      'Ünvan Baş ofis',
      name: 'nvanBaOfis',
      desc: '',
      args: [],
    );
  }

  /// `Xidmətlərimiz`
  String get xidmetlerimiz {
    return Intl.message(
      'Xidmətlərimiz',
      name: 'xidmetlerimiz',
      desc: '',
      args: [],
    );
  }

  /// `Sifarişlərim`
  String get sifarilrim {
    return Intl.message(
      'Sifarişlərim',
      name: 'sifarilrim',
      desc: '',
      args: [],
    );
  }

  /// `Vergi numarası`
  String get vergiNumaras {
    return Intl.message(
      'Vergi numarası',
      name: 'vergiNumaras',
      desc: '',
      args: [],
    );
  }

  /// `Mobil telefon`
  String get mobilTelefon {
    return Intl.message(
      'Mobil telefon',
      name: 'mobilTelefon',
      desc: '',
      args: [],
    );
  }

  /// `Ülke`
  String get lke {
    return Intl.message(
      'Ülke',
      name: 'lke',
      desc: '',
      args: [],
    );
  }

  /// `Semt`
  String get semt {
    return Intl.message(
      'Semt',
      name: 'semt',
      desc: '',
      args: [],
    );
  }

  /// `Adres başlığı`
  String get adresBal {
    return Intl.message(
      'Adres başlığı',
      name: 'adresBal',
      desc: '',
      args: [],
    );
  }

  /// `İlçe`
  String get le {
    return Intl.message(
      'İlçe',
      name: 'le',
      desc: '',
      args: [],
    );
  }

  /// `ZIP/Post kodu`
  String get zippostKodu {
    return Intl.message(
      'ZIP/Post kodu',
      name: 'zippostKodu',
      desc: '',
      args: [],
    );
  }

  /// `Türkiyə ünvanım`
  String get trkiyNvanm {
    return Intl.message(
      'Türkiyə ünvanım',
      name: 'trkiyNvanm',
      desc: '',
      args: [],
    );
  }

  /// `İl - şehir`
  String get lEhir {
    return Intl.message(
      'İl - şehir',
      name: 'lEhir',
      desc: '',
      args: [],
    );
  }

  /// `Imtina edilib`
  String get imtinaEdilib {
    return Intl.message(
      'Imtina edilib',
      name: 'imtinaEdilib',
      desc: '',
      args: [],
    );
  }

  /// `Yaradilib`
  String get yaradilib {
    return Intl.message(
      'Yaradilib',
      name: 'yaradilib',
      desc: '',
      args: [],
    );
  }

  /// `Odenis edilib`
  String get odenisEdilib {
    return Intl.message(
      'Odenis edilib',
      name: 'odenisEdilib',
      desc: '',
      args: [],
    );
  }

  /// `Turkiye ofisindedir`
  String get turkiyeOfisindedir {
    return Intl.message(
      'Turkiye ofisindedir',
      name: 'turkiyeOfisindedir',
      desc: '',
      args: [],
    );
  }

  /// `Alinib`
  String get alinib {
    return Intl.message(
      'Alinib',
      name: 'alinib',
      desc: '',
      args: [],
    );
  }

  /// `Kargodadir`
  String get kargodadir {
    return Intl.message(
      'Kargodadir',
      name: 'kargodadir',
      desc: '',
      args: [],
    );
  }

  /// `Baki ofisindedir`
  String get bakiOfisindedir {
    return Intl.message(
      'Baki ofisindedir',
      name: 'bakiOfisindedir',
      desc: '',
      args: [],
    );
  }

  /// `Tehvil verilib`
  String get tehvilVerilib {
    return Intl.message(
      'Tehvil verilib',
      name: 'tehvilVerilib',
      desc: '',
      args: [],
    );
  }

  /// `Dasinma haqqi odenilib`
  String get dasinmaHaqqiOdenilib {
    return Intl.message(
      'Dasinma haqqi odenilib',
      name: 'dasinmaHaqqiOdenilib',
      desc: '',
      args: [],
    );
  }

  /// `Problemli baglama`
  String get problemliBaglama {
    return Intl.message(
      'Problemli baglama',
      name: 'problemliBaglama',
      desc: '',
      args: [],
    );
  }

  /// `Silmək istədiyinizdən əminsinizmi?`
  String get silmkIstdiyinizMinsiniz {
    return Intl.message(
      'Silmək istədiyinizdən əminsinizmi?',
      name: 'silmkIstdiyinizMinsiniz',
      desc: '',
      args: [],
    );
  }

  /// `Rədd etmək`
  String get rddEtmk {
    return Intl.message(
      'Rədd etmək',
      name: 'rddEtmk',
      desc: '',
      args: [],
    );
  }

  /// `Tesdiq edirem`
  String get tesdiqEdirem {
    return Intl.message(
      'Tesdiq edirem',
      name: 'tesdiqEdirem',
      desc: '',
      args: [],
    );
  }

  /// `Kopyalandı`
  String get kopyaland {
    return Intl.message(
      'Kopyalandı',
      name: 'kopyaland',
      desc: '',
      args: [],
    );
  }

  /// `Filiallar`
  String get filiallar {
    return Intl.message(
      'Filiallar',
      name: 'filiallar',
      desc: '',
      args: [],
    );
  }

  /// `Ümumi məhsul dəyəri`
  String get mumiMhsulDyri {
    return Intl.message(
      'Ümumi məhsul dəyəri',
      name: 'mumiMhsulDyri',
      desc: '',
      args: [],
    );
  }

  /// `Kanqo ailəsinə xoş gəlmisiniz`
  String get kanqoAilsinXoGlmisiniz {
    return Intl.message(
      'Kanqo ailəsinə xoş gəlmisiniz',
      name: 'kanqoAilsinXoGlmisiniz',
      desc: '',
      args: [],
    );
  }

  /// `Şəxsiyyət vəsiqəsinin FİN kodu daxil edin`
  String get xsiyytVsiqsininFnKoduDaxilEdin {
    return Intl.message(
      'Şəxsiyyət vəsiqəsinin FİN kodu daxil edin',
      name: 'xsiyytVsiqsininFnKoduDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Şifrəniz (minimum 6 simvol olmalıdır)`
  String get ifrnizMinimum6SimvolOlmaldr {
    return Intl.message(
      'Şifrəniz (minimum 6 simvol olmalıdır)',
      name: 'ifrnizMinimum6SimvolOlmaldr',
      desc: '',
      args: [],
    );
  }

  /// `Sizin sifarişiniz yoxdur`
  String get sizinSifariinizYoxdur {
    return Intl.message(
      'Sizin sifarişiniz yoxdur',
      name: 'sizinSifariinizYoxdur',
      desc: '',
      args: [],
    );
  }

  /// `Sizin bağlamaniz yoxdur`
  String get sizinBalamanizYoxdur {
    return Intl.message(
      'Sizin bağlamaniz yoxdur',
      name: 'sizinBalamanizYoxdur',
      desc: '',
      args: [],
    );
  }

  /// `Asan sifariş`
  String get srtliSifari {
    return Intl.message(
      'Asan sifariş',
      name: 'srtliSifari',
      desc: '',
      args: [],
    );
  }

  /// `Parol uyğunsuzluğu`
  String get parolUyunsuzluu {
    return Intl.message(
      'Parol uyğunsuzluğu',
      name: 'parolUyunsuzluu',
      desc: '',
      args: [],
    );
  }

  /// `Parol səhvdir`
  String get parolShvdir {
    return Intl.message(
      'Parol səhvdir',
      name: 'parolShvdir',
      desc: '',
      args: [],
    );
  }

  /// `Seçilməyib`
  String get seilmyib {
    return Intl.message(
      'Seçilməyib',
      name: 'seilmyib',
      desc: '',
      args: [],
    );
  }

  /// `Nömrəni göstər`
  String get nmrniGstr {
    return Intl.message(
      'Nömrəni göstər',
      name: 'nmrniGstr',
      desc: '',
      args: [],
    );
  }

  /// `Nömrənizi daxil edin`
  String get nmrniziDaxilEdin {
    return Intl.message(
      'Nömrənizi daxil edin',
      name: 'nmrniziDaxilEdin',
      desc: '',
      args: [],
    );
  }

  /// `Bu nömrə sizin üçün ayrıldı`
  String get buNmrSizinNAyrld {
    return Intl.message(
      'Bu nömrə sizin üçün ayrıldı',
      name: 'buNmrSizinNAyrld',
      desc: '',
      args: [],
    );
  }

  /// `Diqqət! Tətbiq versiyası yenilənmişdir. Davam edə bilmək üçün tətbiqi yeniləməlisiniz.`
  String get diqqtTtbiqVersiyasYenilnmidirDavamEdBilmkNTtbiqiYenilmlisiniz {
    return Intl.message(
      'Diqqət! Tətbiq versiyası yenilənmişdir. Davam edə bilmək üçün tətbiqi yeniləməlisiniz.',
      name: 'diqqtTtbiqVersiyasYenilnmidirDavamEdBilmkNTtbiqiYenilmlisiniz',
      desc: '',
      args: [],
    );
  }

  /// `Davam etmək`
  String get davamEtmk {
    return Intl.message(
      'Davam etmək',
      name: 'davamEtmk',
      desc: '',
      args: [],
    );
  }

  /// `Tətbiqi yeniləyinmək`
  String get ttbiqiYenilyinmk {
    return Intl.message(
      'Tətbiqi yeniləyinmək',
      name: 'ttbiqiYenilyinmk',
      desc: '',
      args: [],
    );
  }

  /// `Mahalle`
  String get mahalle {
    return Intl.message(
      'Mahalle',
      name: 'mahalle',
      desc: '',
      args: [],
    );
  }

  /// `Profili silmək`
  String get profiliSilmk {
    return Intl.message(
      'Profili silmək',
      name: 'profiliSilmk',
      desc: '',
      args: [],
    );
  }

  /// `Hörmətli müştəri, bildirmək istəyirik ki siz hesabi silmekle hesabınıza bağlı olan bütün bağlamalardan imtina etmiş olursunuz. Ve bunu təsdiq etmiş sayılırsınız.`
  String get hrmtliMtriBildirmkIstyirikKiSizHesabiSilmekleHesabnzaBal {
    return Intl.message(
      'Hörmətli müştəri, bildirmək istəyirik ki siz hesabi silmekle hesabınıza bağlı olan bütün bağlamalardan imtina etmiş olursunuz. Ve bunu təsdiq etmiş sayılırsınız.',
      name: 'hrmtliMtriBildirmkIstyirikKiSizHesabiSilmekleHesabnzaBal',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
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
