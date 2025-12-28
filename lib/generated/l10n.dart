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
    return Intl.message('İrəli', name: 'rli', desc: '', args: []);
  }

  /// `E-mail adres`
  String get emailAdres {
    return Intl.message('E-mail adres', name: 'emailAdres', desc: '', args: []);
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
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
    return Intl.message('Şifrə', name: 'ifr', desc: '', args: []);
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
    return Intl.message('Salam', name: 'salam', desc: '', args: []);
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
    return Intl.message('Status:', name: 'status', desc: '', args: []);
  }

  /// `SC status: `
  String get scStatus {
    return Intl.message('SC status: ', name: 'scStatus', desc: '', args: []);
  }

  /// `Qiymət: `
  String get qiymt {
    return Intl.message('Qiymət: ', name: 'qiymt', desc: '', args: []);
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
    return Intl.message('Sifariş ver', name: 'sifariVer', desc: '', args: []);
  }

  /// `Faktura`
  String get fakturaLavEt {
    return Intl.message('Faktura', name: 'fakturaLavEt', desc: '', args: []);
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

  /// `Endirin`
  String get endirin {
    return Intl.message('Endirin', name: 'endirin', desc: '', args: []);
  }

  /// `Bağlamalarım`
  String get balamalarm {
    return Intl.message('Bağlamalarım', name: 'balamalarm', desc: '', args: []);
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
    return Intl.message('Mağaza: ', name: 'maaza', desc: '', args: []);
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
    return Intl.message('Qeyd', name: 'qeyd', desc: '', args: []);
  }

  /// `Ödəniş edin`
  String get dniEdin {
    return Intl.message('Ödəniş edin', name: 'dniEdin', desc: '', args: []);
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

  /// `əlavə et`
  String get lavEt {
    return Intl.message('əlavə et', name: 'lavEt', desc: '', args: []);
  }

  /// `Kod`
  String get kod {
    return Intl.message('Kod', name: 'kod', desc: '', args: []);
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
    return Intl.message('Düzəliş', name: 'dzli', desc: '', args: []);
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
    return Intl.message('Qiyməti', name: 'qiymti', desc: '', args: []);
  }

  /// `Faktura`
  String get faktura {
    return Intl.message('Faktura', name: 'faktura', desc: '', args: []);
  }

  /// `Ətraflı`
  String get trafl {
    return Intl.message('Ətraflı', name: 'trafl', desc: '', args: []);
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
    return Intl.message('Çəki', name: 'ki', desc: '', args: []);
  }

  /// `Çatdırılma`
  String get atdrlma {
    return Intl.message('Çatdırılma', name: 'atdrlma', desc: '', args: []);
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
    return Intl.message('Kateqoriya', name: 'kateqoriya', desc: '', args: []);
  }

  /// `Ödəmə`
  String get dm {
    return Intl.message('Ödəmə', name: 'dm', desc: '', args: []);
  }

  /// `SC status`
  String get scStatuss {
    return Intl.message('SC status', name: 'scStatuss', desc: '', args: []);
  }

  /// `Status`
  String get statuss {
    return Intl.message('Status', name: 'statuss', desc: '', args: []);
  }

  /// `Əməliyyatlar`
  String get mliyyatlar {
    return Intl.message('Əməliyyatlar', name: 'mliyyatlar', desc: '', args: []);
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
    return Intl.message('Yadda saxla', name: 'yaddaSaxla', desc: '', args: []);
  }

  /// `Bağlamalar`
  String get balamalar {
    return Intl.message('Bağlamalar', name: 'balamalar', desc: '', args: []);
  }

  /// `Sifarişlər`
  String get sifarilr {
    return Intl.message('Sifarişlər', name: 'sifarilr', desc: '', args: []);
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
    return Intl.message('Xidmətlərimi', name: 'xidmtlrimi', desc: '', args: []);
  }

  /// `Giriş et`
  String get giriEt {
    return Intl.message('Giriş et', name: 'giriEt', desc: '', args: []);
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
    return Intl.message('Balansınız', name: 'balansnz', desc: '', args: []);
  }

  /// `AZN balansı`
  String get aznBalans {
    return Intl.message('AZN balansı', name: 'aznBalans', desc: '', args: []);
  }

  /// `250.0`
  String get aznnnn {
    return Intl.message('250.0', name: 'aznnnn', desc: '', args: []);
  }

  /// `TL balansı`
  String get tlBalans {
    return Intl.message('TL balansı', name: 'tlBalans', desc: '', args: []);
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
    return Intl.message('Şifrəni dəyiş', name: 'ifrniDyi', desc: '', args: []);
  }

  /// `Çıxış et`
  String get xEt {
    return Intl.message('Çıxış et', name: 'xEt', desc: '', args: []);
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
    return Intl.message('Tariflər', name: 'tariflr', desc: '', args: []);
  }

  /// `Xəbərlər`
  String get xbrlr {
    return Intl.message('Xəbərlər', name: 'xbrlr', desc: '', args: []);
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
    return Intl.message('Əlaqə', name: 'laq', desc: '', args: []);
  }

  /// `tarixçəsi`
  String get tarixsi {
    return Intl.message('tarixçəsi', name: 'tarixsi', desc: '', args: []);
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
    return Intl.message('Bakı kəndləri', name: 'bakKndlri', desc: '', args: []);
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
    return Intl.message('Adınız', name: 'adnz', desc: '', args: []);
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
    return Intl.message('Soyadınız', name: 'soyadnz', desc: '', args: []);
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
    return Intl.message('Cinsiniz', name: 'cinsiniz', desc: '', args: []);
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
    return Intl.message('Kişi', name: 'kii', desc: '', args: []);
  }

  /// `Qadın`
  String get qadn {
    return Intl.message('Qadın', name: 'qadn', desc: '', args: []);
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
    return Intl.message('Təsdiq et', name: 'tsdiqEt', desc: '', args: []);
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
    return Intl.message('Ana səhifə', name: 'anaShif', desc: '', args: []);
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
    return Intl.message('0 qr - 100 qr', name: 'Qr100Qrc', desc: '', args: []);
  }

  /// `101 qr - 250 qr`
  String get Qr250Qr {
    return Intl.message('101 qr - 250 qr', name: 'Qr250Qr', desc: '', args: []);
  }

  /// `251 qr - 500 qr`
  String get Qr500Qr {
    return Intl.message('251 qr - 500 qr', name: 'Qr500Qr', desc: '', args: []);
  }

  /// `501 qr - 1 kq`
  String get Qr1Kq {
    return Intl.message('501 qr - 1 kq', name: 'Qr1Kq', desc: '', args: []);
  }

  /// `1 kq üzərində`
  String get KqZrind {
    return Intl.message('1 kq üzərində', name: 'KqZrind', desc: '', args: []);
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
    return Intl.message('Şifrəniz', name: 'ifrniz', desc: '', args: []);
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
    return Intl.message('Cins', name: 'cins', desc: '', args: []);
  }

  /// `Mağaza`
  String get maazae {
    return Intl.message('Mağaza', name: 'maazae', desc: '', args: []);
  }

  /// `kq`
  String get kq {
    return Intl.message('kq', name: 'kq', desc: '', args: []);
  }

  /// `Mağaza`
  String get maazavd {
    return Intl.message('Mağaza', name: 'maazavd', desc: '', args: []);
  }

  /// `tl`
  String get tl {
    return Intl.message('tl', name: 'tl', desc: '', args: []);
  }

  /// `Bağlama:`
  String get balama {
    return Intl.message('Bağlama:', name: 'balama', desc: '', args: []);
  }

  /// `Ad, Soyad:`
  String get adSoyad {
    return Intl.message('Ad, Soyad:', name: 'adSoyad', desc: '', args: []);
  }

  /// `Ünvan:`
  String get nvan {
    return Intl.message('Ünvan:', name: 'nvan', desc: '', args: []);
  }

  /// `Geri`
  String get geri {
    return Intl.message('Geri', name: 'geri', desc: '', args: []);
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
    return Intl.message('Filial seçin', name: 'filialSein', desc: '', args: []);
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
    return Intl.message('Ünvan', name: 'nvand', desc: '', args: []);
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
    return Intl.message('Bağla', name: 'bala', desc: '', args: []);
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
    return Intl.message('Toplam məbləğ', name: 'toplamMbl', desc: '', args: []);
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
    return Intl.message('Kargo dəyəri', name: 'kargoDyri', desc: '', args: []);
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
    return Intl.message('Məhsul', name: 'mhsul', desc: '', args: []);
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
    return Intl.message('Yeni məhsul', name: 'yeniMhsul', desc: '', args: []);
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
    return Intl.message('Sifariş et', name: 'sifariEt', desc: '', args: []);
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
    return Intl.message('Geriyə', name: 'geriy', desc: '', args: []);
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
    return Intl.message('+1', name: 'one', desc: '', args: []);
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
    return Intl.message('Ödəniş et', name: 'dniEt', desc: '', args: []);
  }

  /// `Səbətim`
  String get sbtim {
    return Intl.message('Səbətim', name: 'sbtim', desc: '', args: []);
  }

  /// `Say`
  String get say {
    return Intl.message('Say', name: 'say', desc: '', args: []);
  }

  /// `Ölçü:`
  String get l {
    return Intl.message('Ölçü:', name: 'l', desc: '', args: []);
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
    return Intl.message('Ad', name: 'ad', desc: '', args: []);
  }

  /// `Soyad`
  String get soyad {
    return Intl.message('Soyad', name: 'soyad', desc: '', args: []);
  }

  /// `Filial`
  String get filial {
    return Intl.message('Filial', name: 'filial', desc: '', args: []);
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
    return Intl.message('Kango Tel:', name: 'kangoTel', desc: '', args: []);
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
    return Intl.message('Ümumi qiymət:', name: 'mumiQiymt', desc: '', args: []);
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
    return Intl.message('Əlavə xidmət:', name: 'lavXidmt', desc: '', args: []);
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
    return Intl.message('Beli', name: 'beli', desc: '', args: []);
  }

  /// `Heir`
  String get heir {
    return Intl.message('Heir', name: 'heir', desc: '', args: []);
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
    return Intl.message('Sifarişlərim', name: 'sifarilrim', desc: '', args: []);
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
    return Intl.message('Ülke', name: 'lke', desc: '', args: []);
  }

  /// `Semt`
  String get semt {
    return Intl.message('Semt', name: 'semt', desc: '', args: []);
  }

  /// `Adres başlığı`
  String get adresBal {
    return Intl.message('Adres başlığı', name: 'adresBal', desc: '', args: []);
  }

  /// `İlçe`
  String get le {
    return Intl.message('İlçe', name: 'le', desc: '', args: []);
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
    return Intl.message('İl - şehir', name: 'lEhir', desc: '', args: []);
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
    return Intl.message('Yaradilib', name: 'yaradilib', desc: '', args: []);
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
    return Intl.message('Alinib', name: 'alinib', desc: '', args: []);
  }

  /// `Kargodadir`
  String get kargodadir {
    return Intl.message('Kargodadir', name: 'kargodadir', desc: '', args: []);
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
    return Intl.message('Rədd etmək', name: 'rddEtmk', desc: '', args: []);
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
    return Intl.message('Kopyalandı', name: 'kopyaland', desc: '', args: []);
  }

  /// `Filiallar`
  String get filiallar {
    return Intl.message('Filiallar', name: 'filiallar', desc: '', args: []);
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
    return Intl.message('Seçilməyib', name: 'seilmyib', desc: '', args: []);
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
    return Intl.message('Davam etmək', name: 'davamEtmk', desc: '', args: []);
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
    return Intl.message('Mahalle', name: 'mahalle', desc: '', args: []);
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

  /// `Language`
  String get languandff {
    return Intl.message('Language', name: 'languandff', desc: '', args: []);
  }

  /// `🟢 Проверен`
  String get fvdgd {
    return Intl.message('🟢 Проверен', name: 'fvdgd', desc: '', args: []);
  }

  /// `курьер`
  String get frefd {
    return Intl.message('курьер', name: 'frefd', desc: '', args: []);
  }

  /// `отправитель`
  String get fvvdf {
    return Intl.message('отправитель', name: 'fvvdf', desc: '', args: []);
  }

  /// `покупатель`
  String get fvgbfdb {
    return Intl.message('покупатель', name: 'fvgbfdb', desc: '', args: []);
  }

  /// `Продолжить`
  String get vfdvd {
    return Intl.message('Продолжить', name: 'vfdvd', desc: '', args: []);
  }

  /// `Ищи тех, кто летит — и передавай посылки надёжно и быстро`
  String get vvvvvf {
    return Intl.message(
      'Ищи тех, кто летит — и передавай посылки надёжно и быстро',
      name: 'vvvvvf',
      desc: '',
      args: [],
    );
  }

  /// `Быстрая и безопасная доставка посылок по всему миру`
  String get r43 {
    return Intl.message(
      'Быстрая и безопасная доставка посылок по всему миру',
      name: 'r43',
      desc: '',
      args: [],
    );
  }

  /// `Требуется регистрация`
  String get t54 {
    return Intl.message(
      'Требуется регистрация',
      name: 't54',
      desc: '',
      args: [],
    );
  }

  /// `Для доступа к этой функции необходимо зарегистрироваться или войти в аккаунт`
  String get rft43 {
    return Intl.message(
      'Для доступа к этой функции необходимо зарегистрироваться или войти в аккаунт',
      name: 'rft43',
      desc: '',
      args: [],
    );
  }

  /// `Зарегистрироваться`
  String get ffr4 {
    return Intl.message('Зарегистрироваться', name: 'ffr4', desc: '', args: []);
  }

  /// `Войти`
  String get fr43 {
    return Intl.message('Войти', name: 'fr43', desc: '', args: []);
  }

  /// `Отмена`
  String get fre45 {
    return Intl.message('Отмена', name: 'fre45', desc: '', args: []);
  }

  /// `Введите email`
  String get email {
    return Intl.message('Введите email', name: 'email', desc: '', args: []);
  }

  /// `Код отправлен на $email`
  String get emailfre {
    return Intl.message(
      'Код отправлен на \$email',
      name: 'emailfre',
      desc: '',
      args: [],
    );
  }

  /// `Введите 6-значный код`
  String get rfred2 {
    return Intl.message(
      'Введите 6-значный код',
      name: 'rfred2',
      desc: '',
      args: [],
    );
  }

  /// `Пароль минимум 6 символов`
  String get vfd4 {
    return Intl.message(
      'Пароль минимум 6 символов',
      name: 'vfd4',
      desc: '',
      args: [],
    );
  }

  /// `Пароли не совпадают`
  String get vfdv3 {
    return Intl.message(
      'Пароли не совпадают',
      name: 'vfdv3',
      desc: '',
      args: [],
    );
  }

  /// `Пароль успешно изменён!`
  String get rfewf43 {
    return Intl.message(
      'Пароль успешно изменён!',
      name: 'rfewf43',
      desc: '',
      args: [],
    );
  }

  /// `Код отправлен повторно`
  String get nhtf34 {
    return Intl.message(
      'Код отправлен повторно',
      name: 'nhtf34',
      desc: '',
      args: [],
    );
  }

  /// `Введите код`
  String get vfd3 {
    return Intl.message('Введите код', name: 'vfd3', desc: '', args: []);
  }

  /// `Забыли пароль?`
  String get vfd23 {
    return Intl.message('Забыли пароль?', name: 'vfd23', desc: '', args: []);
  }

  /// `Новый пароль`
  String get vfddfvd2 {
    return Intl.message('Новый пароль', name: 'vfddfvd2', desc: '', args: []);
  }

  /// `Введите email, на который зарегистрирован аккаунт`
  String get emailvfd {
    return Intl.message(
      'Введите email, на который зарегистрирован аккаунт',
      name: 'emailvfd',
      desc: '',
      args: [],
    );
  }

  /// `EMAIL`
  String get emailbngf {
    return Intl.message('EMAIL', name: 'emailbngf', desc: '', args: []);
  }

  /// `Отправка...`
  String get bgf3 {
    return Intl.message('Отправка...', name: 'bgf3', desc: '', args: []);
  }

  /// `Отправить код`
  String get mut3 {
    return Intl.message('Отправить код', name: 'mut3', desc: '', args: []);
  }

  /// `Код отправлен на`
  String get bvgf2 {
    return Intl.message('Код отправлен на', name: 'bvgf2', desc: '', args: []);
  }

  /// `Отправить повторно`
  String get bgf24 {
    return Intl.message(
      'Отправить повторно',
      name: 'bgf24',
      desc: '',
      args: [],
    );
  }

  /// `Проверка...`
  String get bgf2 {
    return Intl.message('Проверка...', name: 'bgf2', desc: '', args: []);
  }

  /// `Подтвердить`
  String get vfd245 {
    return Intl.message('Подтвердить', name: 'vfd245', desc: '', args: []);
  }

  /// `Придумайте новый пароль`
  String get uy3 {
    return Intl.message(
      'Придумайте новый пароль',
      name: 'uy3',
      desc: '',
      args: [],
    );
  }

  /// `НОВЫЙ ПАРОЛЬ`
  String get fvrdevfd54 {
    return Intl.message('НОВЫЙ ПАРОЛЬ', name: 'fvrdevfd54', desc: '', args: []);
  }

  /// `Минимум 6 символов`
  String get my65 {
    return Intl.message('Минимум 6 символов', name: 'my65', desc: '', args: []);
  }

  /// `ПОДТВЕРДИТЕ ПАРОЛЬ`
  String get uj334 {
    return Intl.message(
      'ПОДТВЕРДИТЕ ПАРОЛЬ',
      name: 'uj334',
      desc: '',
      args: [],
    );
  }

  /// `Повторите пароль`
  String get ujt3 {
    return Intl.message('Повторите пароль', name: 'ujt3', desc: '', args: []);
  }

  /// `Сохранение...`
  String get nbhty3 {
    return Intl.message('Сохранение...', name: 'nbhty3', desc: '', args: []);
  }

  /// `Сохранить пароль`
  String get ukj3 {
    return Intl.message('Сохранить пароль', name: 'ukj3', desc: '', args: []);
  }

  /// `Вход`
  String get umt645 {
    return Intl.message('Вход', name: 'umt645', desc: '', args: []);
  }

  /// `EMAIL`
  String get emailbgf {
    return Intl.message('EMAIL', name: 'emailbgf', desc: '', args: []);
  }

  /// `ПАРОЛЬ`
  String get nty35 {
    return Intl.message('ПАРОЛЬ', name: 'nty35', desc: '', args: []);
  }

  /// `Минимум 6 символов`
  String get nfngfngf645 {
    return Intl.message(
      'Минимум 6 символов',
      name: 'nfngfngf645',
      desc: '',
      args: [],
    );
  }

  /// `Забыли пароль?`
  String get kiyt3 {
    return Intl.message('Забыли пароль?', name: 'kiyt3', desc: '', args: []);
  }

  /// `Вход...`
  String get ykuj3 {
    return Intl.message('Вход...', name: 'ykuj3', desc: '', args: []);
  }

  /// `Войти`
  String get iykuj34 {
    return Intl.message('Войти', name: 'iykuj34', desc: '', args: []);
  }

  /// `Нет аккаунта? Зарегистрироваться`
  String get myt3 {
    return Intl.message(
      'Нет аккаунта? Зарегистрироваться',
      name: 'myt3',
      desc: '',
      args: [],
    );
  }

  /// `Регистрация`
  String get nyt7 {
    return Intl.message('Регистрация', name: 'nyt7', desc: '', args: []);
  }

  /// `Присоединяйтесь к нам`
  String get nty3 {
    return Intl.message(
      'Присоединяйтесь к нам',
      name: 'nty3',
      desc: '',
      args: [],
    );
  }

  /// `ПОЛНОЕ ИМЯ`
  String get btr3 {
    return Intl.message('ПОЛНОЕ ИМЯ', name: 'btr3', desc: '', args: []);
  }

  /// `Введите ваше имя`
  String get nbgf3 {
    return Intl.message('Введите ваше имя', name: 'nbgf3', desc: '', args: []);
  }

  /// `ТЕЛЕФОН`
  String get bgf34 {
    return Intl.message('ТЕЛЕФОН', name: 'bgf34', desc: '', args: []);
  }

  /// `ПАРОЛЬ`
  String get bgf35 {
    return Intl.message('ПАРОЛЬ', name: 'bgf35', desc: '', args: []);
  }

  /// `Минимум 6 символов`
  String get bgfbvgfd3 {
    return Intl.message(
      'Минимум 6 символов',
      name: 'bgfbvgfd3',
      desc: '',
      args: [],
    );
  }

  /// `ПОДТВЕРДИТЕ ПАРОЛЬ`
  String get bg334 {
    return Intl.message(
      'ПОДТВЕРДИТЕ ПАРОЛЬ',
      name: 'bg334',
      desc: '',
      args: [],
    );
  }

  /// `Повторите пароль`
  String get vbrgf2 {
    return Intl.message('Повторите пароль', name: 'vbrgf2', desc: '', args: []);
  }

  /// `Регистрация...`
  String get bgfd3 {
    return Intl.message('Регистрация...', name: 'bgfd3', desc: '', args: []);
  }

  /// `Создать аккаунт`
  String get bgd2 {
    return Intl.message('Создать аккаунт', name: 'bgd2', desc: '', args: []);
  }

  /// `Уже есть аккаунт?`
  String get muj56 {
    return Intl.message('Уже есть аккаунт?', name: 'muj56', desc: '', args: []);
  }

  /// `Войти`
  String get ujt4 {
    return Intl.message('Войти', name: 'ujt4', desc: '', args: []);
  }

  /// `Выберите страну`
  String get nbtynt7 {
    return Intl.message('Выберите страну', name: 'nbtynt7', desc: '', args: []);
  }

  /// `Поиск страны...`
  String get mjh5y {
    return Intl.message('Поиск страны...', name: 'mjh5y', desc: '', args: []);
  }

  /// `Выбор`
  String get nhgngn5 {
    return Intl.message('Выбор', name: 'nhgngn5', desc: '', args: []);
  }

  /// `Языки загружаются. Попробуйте позже.`
  String get vfd34 {
    return Intl.message(
      'Языки загружаются. Попробуйте позже.',
      name: 'vfd34',
      desc: '',
      args: [],
    );
  }

  /// `Языки не загружены. Попробуйте позже.`
  String get bgdfbgfd3 {
    return Intl.message(
      'Языки не загружены. Попробуйте позже.',
      name: 'bgdfbgfd3',
      desc: '',
      args: [],
    );
  }

  /// `Выберите языки`
  String get bgvfd3 {
    return Intl.message('Выберите языки', name: 'bgvfd3', desc: '', args: []);
  }

  /// `Языки не найдены`
  String get bdg3 {
    return Intl.message('Языки не найдены', name: 'bdg3', desc: '', args: []);
  }

  /// `Неизвестный язык`
  String get nhtg5 {
    return Intl.message('Неизвестный язык', name: 'nhtg5', desc: '', args: []);
  }

  /// `Код:`
  String get bmy5 {
    return Intl.message('Код:', name: 'bmy5', desc: '', args: []);
  }

  /// `Применить`
  String get bnht {
    return Intl.message('Применить', name: 'bnht', desc: '', args: []);
  }

  /// `Загрузка...`
  String get bgfbgfb4 {
    return Intl.message('Загрузка...', name: 'bgfbgfb4', desc: '', args: []);
  }

  /// `Выбор`
  String get gbfbgfbfg4 {
    return Intl.message('Выбор', name: 'gbfbgfbfg4', desc: '', args: []);
  }

  /// `Типы упаковки загружаются. Попробуйте позже.`
  String get t53grvfe5 {
    return Intl.message(
      'Типы упаковки загружаются. Попробуйте позже.',
      name: 't53grvfe5',
      desc: '',
      args: [],
    );
  }

  /// `Типы упаковки не загружены. Попробуйте позже.`
  String get bgfbgfbgf4 {
    return Intl.message(
      'Типы упаковки не загружены. Попробуйте позже.',
      name: 'bgfbgfbgf4',
      desc: '',
      args: [],
    );
  }

  /// `Выберите специализацию`
  String get bfgbgfb3 {
    return Intl.message(
      'Выберите специализацию',
      name: 'bfgbgfb3',
      desc: '',
      args: [],
    );
  }

  /// `Типы упаковки не найдены`
  String get bgbffgb3 {
    return Intl.message(
      'Типы упаковки не найдены',
      name: 'bgbffgb3',
      desc: '',
      args: [],
    );
  }

  /// `Применить`
  String get bgfbggfbfg3 {
    return Intl.message('Применить', name: 'bgfbggfbfg3', desc: '', args: []);
  }

  /// `Начните переписку`
  String get vgfbgf4 {
    return Intl.message(
      'Начните переписку',
      name: 'vgfbgf4',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите отправить`
  String get bgfbfgb4 {
    return Intl.message(
      'Вы уверены, что хотите отправить',
      name: 'bgfbfgb4',
      desc: '',
      args: [],
    );
  }

  /// `запрос на оценку ваших услуг?`
  String get bfgbgbgy6 {
    return Intl.message(
      'запрос на оценку ваших услуг?',
      name: 'bfgbgbgy6',
      desc: '',
      args: [],
    );
  }

  /// `Отмена`
  String get bgbgfgb43 {
    return Intl.message('Отмена', name: 'bgbgfgb43', desc: '', args: []);
  }

  /// `Запрос на отзыв отправлен!`
  String get bgfbfg3 {
    return Intl.message(
      'Запрос на отзыв отправлен!',
      name: 'bgfbfg3',
      desc: '',
      args: [],
    );
  }

  /// `Отправить`
  String get cdsdssde3 {
    return Intl.message('Отправить', name: 'cdsdssde3', desc: '', args: []);
  }

  /// `Входящие`
  String get vfdvfd3 {
    return Intl.message('Входящие', name: 'vfdvfd3', desc: '', args: []);
  }

  /// `Архив`
  String get vfdvfdvf3 {
    return Intl.message('Архив', name: 'vfdvfdvf3', desc: '', args: []);
  }

  /// `Нет чатов`
  String get vfgdvfd3 {
    return Intl.message('Нет чатов', name: 'vfgdvfd3', desc: '', args: []);
  }

  /// `Действия с чатом`
  String get vfdvfddvfdvf3 {
    return Intl.message(
      'Действия с чатом',
      name: 'vfdvfddvfdvf3',
      desc: '',
      args: [],
    );
  }

  /// `Открепить`
  String get htyyhttyh7 {
    return Intl.message('Открепить', name: 'htyyhttyh7', desc: '', args: []);
  }

  /// `Закрепить`
  String get juyjy7 {
    return Intl.message('Закрепить', name: 'juyjy7', desc: '', args: []);
  }

  /// `Разархивировать`
  String get yjyj67 {
    return Intl.message('Разархивировать', name: 'yjyj67', desc: '', args: []);
  }

  /// `Архивировать`
  String get mkuuj7 {
    return Intl.message('Архивировать', name: 'mkuuj7', desc: '', args: []);
  }

  /// `Разблокировать`
  String get jnyjyjyu8 {
    return Intl.message(
      'Разблокировать',
      name: 'jnyjyjyu8',
      desc: '',
      args: [],
    );
  }

  /// `Заблокировать`
  String get ynmjymjy8 {
    return Intl.message('Заблокировать', name: 'ynmjymjy8', desc: '', args: []);
  }

  /// `Удалить чат`
  String get mymuyy7 {
    return Intl.message('Удалить чат', name: 'mymuyy7', desc: '', args: []);
  }

  /// `Удалить чат?`
  String get mumju7 {
    return Intl.message('Удалить чат?', name: 'mumju7', desc: '', args: []);
  }

  /// `Вы уверены, что хотите удалить переписку с`
  String get njmuy5 {
    return Intl.message(
      'Вы уверены, что хотите удалить переписку с',
      name: 'njmuy5',
      desc: '',
      args: [],
    );
  }

  /// `Отмена`
  String get bhtgbht55 {
    return Intl.message('Отмена', name: 'bhtgbht55', desc: '', args: []);
  }

  /// `Удалить`
  String get nhtntt5 {
    return Intl.message('Удалить', name: 'nhtntt5', desc: '', args: []);
  }

  /// `Заблокировать пользователя?`
  String get bgfbfbg5 {
    return Intl.message(
      'Заблокировать пользователя?',
      name: 'bgfbfbg5',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите заблокировать`
  String get bghfbgb5 {
    return Intl.message(
      'Вы уверены, что хотите заблокировать',
      name: 'bghfbgb5',
      desc: '',
      args: [],
    );
  }

  /// `Отмена`
  String get bgtbgtbgbtg4 {
    return Intl.message('Отмена', name: 'bgtbgtbgbtg4', desc: '', args: []);
  }

  /// `Заблокировать`
  String get bghfgbg4 {
    return Intl.message('Заблокировать', name: 'bghfgbg4', desc: '', args: []);
  }

  /// `Разблокировать пользователя?`
  String get gbfgbfgfb34 {
    return Intl.message(
      'Разблокировать пользователя?',
      name: 'gbfgbfgfb34',
      desc: '',
      args: [],
    );
  }

  /// `Вы уверены, что хотите разблокировать`
  String get bgfbgffg4 {
    return Intl.message(
      'Вы уверены, что хотите разблокировать',
      name: 'bgfbgffg4',
      desc: '',
      args: [],
    );
  }

  /// `Отмена`
  String get bvgfbf4 {
    return Intl.message('Отмена', name: 'bvgfbf4', desc: '', args: []);
  }

  /// `Разблокировать`
  String get hythy4 {
    return Intl.message('Разблокировать', name: 'hythy4', desc: '', args: []);
  }

  /// `Сообщение...`
  String get yhtrhtrtrh4 {
    return Intl.message(
      'Сообщение...',
      name: 'yhtrhtrtrh4',
      desc: '',
      args: [],
    );
  }

  /// `Фото`
  String get bgfbgfbg4 {
    return Intl.message('Фото', name: 'bgfbgfbg4', desc: '', args: []);
  }

  /// `Файл`
  String get bgfbgfgf4 {
    return Intl.message('Файл', name: 'bgfbgfgf4', desc: '', args: []);
  }

  /// `Проверен`
  String get bgfbgf4 {
    return Intl.message('Проверен', name: 'bgfbgf4', desc: '', args: []);
  }

  /// `новых сообщения`
  String get bgbgffbgfg4 {
    return Intl.message(
      'новых сообщения',
      name: 'bgbgffbgfg4',
      desc: '',
      args: [],
    );
  }

  /// `Аккаунт`
  String get vfdvfdvfd {
    return Intl.message('Аккаунт', name: 'vfdvfdvfd', desc: '', args: []);
  }

  /// `Избранное`
  String get gbfbgfgb {
    return Intl.message('Избранное', name: 'gbfbgfgb', desc: '', args: []);
  }

  /// `Подать`
  String get nhnnh5 {
    return Intl.message('Подать', name: 'nhnnh5', desc: '', args: []);
  }

  /// `Чаты`
  String get mjhmhjmj5 {
    return Intl.message('Чаты', name: 'mjhmhjmj5', desc: '', args: []);
  }

  /// `Поиск`
  String get nhhfge4 {
    return Intl.message('Поиск', name: 'nhhfge4', desc: '', args: []);
  }

  /// `Ошибка загрузки типов предложений:`
  String get bgfdbf3 {
    return Intl.message(
      'Ошибка загрузки типов предложений:',
      name: 'bgfdbf3',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки городов:`
  String get bgvrgrbgr3 {
    return Intl.message(
      'Ошибка загрузки городов:',
      name: 'bgvrgrbgr3',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка загрузки типов упаковки:`
  String get vfdvfdvfdv3 {
    return Intl.message(
      'Ошибка загрузки типов упаковки:',
      name: 'vfdvfdvfdv3',
      desc: '',
      args: [],
    );
  }

  /// `Подать`
  String get bvfv2r {
    return Intl.message('Подать', name: 'bvfv2r', desc: '', args: []);
  }

  /// `Создайте объявление для поиска курьера или\nклиента`
  String get mjjhmjjmj5 {
    return Intl.message(
      'Создайте объявление для поиска курьера или\nклиента',
      name: 'mjjhmjjmj5',
      desc: '',
      args: [],
    );
  }

  /// `Создайте объявление для поиска курьера или\nклиента`
  String get bgfbgbgfbgf {
    return Intl.message(
      'Создайте объявление для поиска курьера или\nклиента',
      name: 'bgfbgbgfbgf',
      desc: '',
      args: [],
    );
  }

  /// `Тип предложения`
  String get bgfbgfbgf {
    return Intl.message(
      'Тип предложения',
      name: 'bgfbgfbgf',
      desc: '',
      args: [],
    );
  }

  /// `Тип посылки`
  String get nhgnhg4 {
    return Intl.message('Тип посылки', name: 'nhgnhg4', desc: '', args: []);
  }

  /// `Откуда`
  String get hythyt4 {
    return Intl.message('Откуда', name: 'hythyt4', desc: '', args: []);
  }

  /// `Город отправления`
  String get kiukiuku6 {
    return Intl.message(
      'Город отправления',
      name: 'kiukiuku6',
      desc: '',
      args: [],
    );
  }

  /// `Куда`
  String get kiuykiu67 {
    return Intl.message('Куда', name: 'kiuykiu67', desc: '', args: []);
  }

  /// `Город назначения`
  String get lkiuliuu6 {
    return Intl.message(
      'Город назначения',
      name: 'lkiuliuu6',
      desc: '',
      args: [],
    );
  }

  /// `Максимальный вес (кг)`
  String get mjjhm6 {
    return Intl.message(
      'Максимальный вес (кг)',
      name: 'mjjhm6',
      desc: '',
      args: [],
    );
  }

  /// `Цена за кг`
  String get bgfbgf34 {
    return Intl.message('Цена за кг', name: 'bgfbgf34', desc: '', args: []);
  }

  /// `Описание`
  String get vfdbg2r3 {
    return Intl.message('Описание', name: 'vfdbg2r3', desc: '', args: []);
  }

  /// `Расскажите о своих услугах доставки...`
  String get bdfbd2w {
    return Intl.message(
      'Расскажите о своих услугах доставки...',
      name: 'bdfbd2w',
      desc: '',
      args: [],
    );
  }

  /// `Опубликовать объявление`
  String get bgfbgf3 {
    return Intl.message(
      'Опубликовать объявление',
      name: 'bgfbgf3',
      desc: '',
      args: [],
    );
  }

  /// `Выберите тип`
  String get bgfbgfb3 {
    return Intl.message('Выберите тип', name: 'bgfbgfb3', desc: '', args: []);
  }

  /// `дд.мм.гггг`
  String get bgbgfg334 {
    return Intl.message('дд.мм.гггг', name: 'bgbgfg334', desc: '', args: []);
  }

  /// `Время вылета`
  String get bgfbgf3434 {
    return Intl.message('Время вылета', name: 'bgfbgf3434', desc: '', args: []);
  }

  /// `Дата доставки с`
  String get bgdfbg345 {
    return Intl.message(
      'Дата доставки с',
      name: 'bgdfbg345',
      desc: '',
      args: [],
    );
  }

  /// `дд.мм.гггг`
  String get bgfbgf4554 {
    return Intl.message('дд.мм.гггг', name: 'bgfbgf4554', desc: '', args: []);
  }

  /// `дд.мм.гггг`
  String get bgfdbgf345 {
    return Intl.message('дд.мм.гггг', name: 'bgfdbgf345', desc: '', args: []);
  }

  /// `Дата доставки до`
  String get bgfgbfbgf345 {
    return Intl.message(
      'Дата доставки до',
      name: 'bgfgbfbgf345',
      desc: '',
      args: [],
    );
  }

  /// `Дата покупки с`
  String get bgfb3 {
    return Intl.message('Дата покупки с', name: 'bgfb3', desc: '', args: []);
  }

  /// `дд.мм.гггг`
  String get bgfbggfbgf34 {
    return Intl.message('дд.мм.гггг', name: 'bgfbggfbgf34', desc: '', args: []);
  }

  /// `Дата покупки до`
  String get vfdv34 {
    return Intl.message('Дата покупки до', name: 'vfdv34', desc: '', args: []);
  }

  /// `чч:мм (24-часовой формат)`
  String get vfdvfddfv24 {
    return Intl.message(
      'чч:мм (24-часовой формат)',
      name: 'vfdvfddfv24',
      desc: '',
      args: [],
    );
  }

  /// `Объявление опубликовано!`
  String get vfdvfd24 {
    return Intl.message(
      'Объявление опубликовано!',
      name: 'vfdvfd24',
      desc: '',
      args: [],
    );
  }

  /// `Ошибка:`
  String get vfdvf423 {
    return Intl.message('Ошибка:', name: 'vfdvf423', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'az'),
      Locale.fromSubtags(languageCode: 'ru'),
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
