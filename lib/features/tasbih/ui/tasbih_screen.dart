
import 'dart:async';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ════════════════════════════════════════════════════════════════════════════
// CACHED TEXT STYLES — built once, reused everywhere (zero repeated allocations)
// ════════════════════════════════════════════════════════════════════════════
abstract final class _TS {
  static TextStyle amiriBold(double size, Color color) => GoogleFonts.amiri(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
  );

  static TextStyle amiri(
    double size,
    Color color, {
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.normal,
    double height = 1.0,
  }) => GoogleFonts.amiri(
    fontSize: size,
    color: color,
    fontStyle: style,
    fontWeight: weight,
    height: height,
  );

  static TextStyle amiriQuran(
    double size,
    Color color, {
    double height = 1.8,
  }) => GoogleFonts.amiriQuran(fontSize: size, color: color, height: height);

  static const TextStyle counter = TextStyle(
    fontWeight: FontWeight.w800,
    height: 1.0,
  );
  static const TextStyle transliteration = TextStyle(
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// DATA
// ════════════════════════════════════════════════════════════════════════════
const List<Map<String, dynamic>> kAllAdhkar = [
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text': 'سُبْحَانَ اللهِ',
    'transliteration': 'Subhana-llah',
    'meaning': 'Glory be to Allah, free from all imperfections',
    'meaningAr': 'سبحان الله وتنزيهه عن كل نقص',
    'count': 33,
    'sub': 'بعد كل صلاة مكتوبة',
    'subEn': 'After every obligatory prayer',
  },
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text': 'الْحَمْدُ لِلَّهِ',
    'transliteration': 'Alhamdulillah',
    'meaning': 'All praise is due to Allah for all His blessings',
    'meaningAr': 'الحمد لله على جميع نعمه',
    'count': 33,
    'sub': 'تملأ الميزان',
    'subEn': 'Fills the scales on the Day of Judgement',
  },
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text': 'اللهُ أَكْبَرُ',
    'transliteration': 'Allahu Akbar',
    'meaning': 'Allah is the Greatest, greater than all things',
    'meaningAr': 'الله أكبر من كل شيء',
    'count': 34,
    'sub': 'بعد كل صلاة مكتوبة',
    'subEn': 'After every obligatory prayer',
  },
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
    'transliteration': 'Subhana-llahi wa bihamdihi, Subhana-llahi al-Azim',
    'meaning': 'Glory and praise be to Allah, the Most Great',
    'meaningAr': 'سبحانه وبحمده، خفيفتان ثقيلتان في الميزان',
    'count': 33,
    'sub': 'خفيفتان على اللسان ثقيلتان في الميزان',
    'subEn': 'Light on the tongue, heavy on the scales',
  },
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text':
        'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'transliteration': 'La ilaha illa-llah wahdahu la sharika lah',
    'meaning':
        'There is no god but Allah alone, with no partner, to Him belongs dominion',
    'meaningAr': 'لا إله إلا الله وحده لا شريك له',
    'count': 10,
    'sub': 'كمن أعتق أربعة من ولد إسماعيل',
    'subEn': 'Like freeing four from the children of Ismail',
  },
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text': 'أَسْتَغْفِرُ اللهَ',
    'transliteration': 'Astaghfiru-llah',
    'meaning': 'I seek forgiveness from Allah',
    'meaningAr': 'أطلب المغفرة من الله',
    'count': 3,
    'sub': 'بعد الانتهاء من الصلاة',
    'subEn': 'After completing the prayer',
  },
  {
    'cat': 'بعد الصلاة',
    'catEn': 'After Prayer',
    'text': 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
    'transliteration': 'Astaghfiru-llaha al-Azeem wa atubu ilayh',
    'meaning': 'I seek forgiveness from Allah the Almighty and repent to Him',
    'meaningAr': 'أستغفر الله العظيم وأتوب إليه',
    'count': 100,
    'sub': 'من استغفر الله غُفر له',
    'subEn': 'Whoever seeks forgiveness, Allah will forgive him',
  },
  {
    'cat': 'الصلاة على النبي ﷺ',
    'catEn': 'Salawat',
    'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    'transliteration': 'Allahumma salli ala Muhammad',
    'meaning': 'O Allah, send blessings upon Muhammad',
    'meaningAr': 'اللهم صلِّ على النبي محمد',
    'count': 100,
    'sub': 'أدنى صلاة عليه ﷺ',
    'subEn': 'The minimum form of blessing upon him',
  },
  {
    'cat': 'الصلاة على النبي ﷺ',
    'catEn': 'Salawat',
    'text': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'transliteration': 'Allahumma salli wa sallim ala Nabiyyina Muhammad',
    'meaning': 'O Allah, send peace and blessings upon our Prophet Muhammad',
    'meaningAr': 'اللهم صلِّ وسلِّم على نبينا محمد',
    'count': 100,
    'sub': 'من صلّى عليّ عشراً صلى الله عليه مئة',
    'subEn': 'Whoever blesses me 10 times, Allah blesses him 100 times',
  },
  {
    'cat': 'الصلاة على النبي ﷺ',
    'catEn': 'Salawat',
    'text':
        'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ',
    'transliteration': 'Allahumma salli ala Muhammad wa ala ali Muhammad',
    'meaning':
        'O Allah, bless Muhammad and family of Muhammad as You blessed Ibrahim',
    'meaningAr': 'الصلاة الإبراهيمية الكاملة',
    'count': 33,
    'sub': 'الصلاة الإبراهيمية',
    'subEn': 'The Ibrahimi Salawat — complete form',
  },
  {
    'cat': 'التهليل والتكبير',
    'catEn': 'Tahleel & Takbeer',
    'text': 'لَا إِلَهَ إِلَّا اللهُ',
    'transliteration': 'Lailaha-Illallah',
    'meaning': 'There is no deity worthy of worship except Allah',
    'meaningAr': 'لا معبود بحق إلا الله',
    'count': 100,
    'sub': 'أفضل الذِكر',
    'subEn': 'The best of all remembrance',
  },
  {
    'cat': 'التهليل والتكبير',
    'catEn': 'Tahleel & Takbeer',
    'text':
        'اللهُ أَكْبَرُ كَبِيرًا وَالْحَمْدُ لِلَّهِ كَثِيرًا وَسُبْحَانَ اللهِ بُكْرَةً وَأَصِيلًا',
    'transliteration': 'Allahu akbar kabiran wal-hamdu lillahi kathiran',
    'meaning':
        'Allah is the Greatest, abundant praise to Allah, glory to Him morning and evening',
    'meaningAr': 'الله أكبر كبيرًا والحمد كثيرًا',
    'count': 33,
    'sub': 'من ذِكر اليوم والليلة',
    'subEn': 'From the remembrances of day and night',
  },
  {
    'cat': 'التهليل والتكبير',
    'catEn': 'Tahleel & Takbeer',
    'text':
        'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'transliteration':
        'La ilaha illa-llah wahdahu la sharika lah, lahu al-mulku',
    'meaning':
        'No god but Allah alone, sovereignty and praise belongs to Him, He gives life and causes death',
    'meaningAr': 'لا إله إلا الله وحده، يحيي ويميت',
    'count': 10,
    'sub': 'عشر مرات صباحًا ومساءً',
    'subEn': 'Ten times in the morning and evening',
  },
  {
    'cat': 'التسبيح',
    'catEn': 'Tasbih',
    'text': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
    'transliteration': 'Subhana-llahi wa bihamdihi',
    'meaning': 'Glory be to Allah and praise Him — sins forgiven',
    'meaningAr': 'من قالها مئة مرة غُفرت ذنوبه',
    'count': 100,
    'sub': 'من قالها مئة مرة غُفرت ذنوبه',
    'subEn': 'Whoever says it 100 times, their sins are forgiven',
  },
  {
    'cat': 'التسبيح',
    'catEn': 'Tasbih',
    'text': 'سُبْحَانَ اللهِ الْعَظِيمِ وَبِحَمْدِهِ',
    'transliteration': 'Subhana-llahi al-Azim wa bihamdihi',
    'meaning':
        'Glory be to Allah the Great and praise Him — a palm tree in Paradise',
    'meaningAr': 'غُرست له نخلة في الجنة',
    'count': 33,
    'sub': 'غُرست له نخلة في الجنة',
    'subEn': 'A palm tree is planted in Paradise for the one who says it',
  },
  {
    'cat': 'التسبيح',
    'catEn': 'Tasbih',
    'text':
        'سُبْحَانَ اللهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللهُ وَاللهُ أَكْبَرُ',
    'transliteration':
        'Subhan-Allah, Alhamdulillah, La ilaha illa-llah, Allahu Akbar',
    'meaning': 'The four most beloved words to Allah',
    'meaningAr': 'أحب الكلام إلى الله الأربعة',
    'count': 33,
    'sub': 'أحب الكلام إلى الله',
    'subEn': 'The most beloved words to Allah',
  },
  {
    'cat': 'التسبيح',
    'catEn': 'Tasbih',
    'text':
        'سُبْحَانَ اللهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    'transliteration':
        'Subhana-llahi wa bihamdihi adada khalqihi wa rida nafsihi',
    'meaning':
        'Glory be to Allah, as numerous as His creation, as much as His pleasure',
    'meaningAr': 'ثلاث مرات تعدل أكثر من كل ذِكر',
    'count': 3,
    'sub': 'ثلاث مرات تعدل أكثر من ذلك',
    'subEn': 'Three times equals more than all other remembrance',
  },
  {
    'cat': 'أذكار الصباح',
    'catEn': 'Morning Adhkar',
    'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
    'transliteration': 'Asbahna wa asbahal mulku lillah, wal-hamdu lillah',
    'meaning': 'We have entered morning and all sovereignty belongs to Allah',
    'meaningAr': 'نبدأ الصباح بذكر الله والحمد له',
    'count': 1,
    'sub': 'قل حين تصبح',
    'subEn': 'Say when you enter the morning',
  },
  {
    'cat': 'أذكار الصباح',
    'catEn': 'Morning Adhkar',
    'text':
        'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    'transliteration': 'Allahumma bika asbahna wa bika amsayna wa bika nahya',
    'meaning':
        'O Allah, by You we enter morning and evening, by You we live and die',
    'meaningAr': 'كل أمورنا بيد الله',
    'count': 1,
    'sub': 'قل حين تصبح',
    'subEn': 'Say when you enter the morning',
  },
  {
    'cat': 'أذكار الصباح',
    'catEn': 'Morning Adhkar',
    'text':
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ',
    'transliteration':
        'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana abduk',
    'meaning':
        'O Allah, You are my Lord, none has the right to be worshipped but You — Master Istighfar',
    'meaningAr': 'سيد الاستغفار — من قالها موقنًا دخل الجنة',
    'count': 1,
    'sub': 'سيد الاستغفار',
    'subEn': 'The Master of Istighfar — guaranteed Paradise',
  },
  {
    'cat': 'أذكار الصباح',
    'catEn': 'Morning Adhkar',
    'text': 'أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    'transliteration': 'Audhu billahi mina ash-Shaytani ar-Rajim',
    'meaning': 'I seek refuge in Allah from the accursed devil',
    'meaningAr': 'أستعيذ بالله من الشيطان الرجيم',
    'count': 3,
    'sub': 'حفظ من الشيطان',
    'subEn': 'Protection from the devil',
  },
  {
    'cat': 'أذكار الصباح',
    'catEn': 'Morning Adhkar',
    'text': 'بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ',
    'transliteration': 'Bismillahi ar-Rahmani ar-Rahim',
    'meaning': 'In the name of Allah, the Most Gracious, the Most Merciful',
    'meaningAr': 'افتتاح اليوم بسم الله',
    'count': 3,
    'sub': 'افتتاح اليوم بسم الله',
    'subEn': 'Begin your day with the name of Allah',
  },
  {
    'cat': 'أذكار المساء',
    'catEn': 'Evening Adhkar',
    'text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
    'transliteration': 'Amsayna wa amsal mulku lillah wal-hamdu lillah',
    'meaning': 'We have entered evening and all sovereignty belongs to Allah',
    'meaningAr': 'نبدأ المساء بذكر الله والحمد له',
    'count': 1,
    'sub': 'قل حين تمسي',
    'subEn': 'Say when you enter the evening',
  },
  {
    'cat': 'أذكار المساء',
    'catEn': 'Evening Adhkar',
    'text':
        'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
    'transliteration': 'Allahumma bika amsayna wa bika asbahna wa bika nahya',
    'meaning':
        'O Allah, by You we enter evening and morning, by You we live and die',
    'meaningAr': 'المساء كله بيد الله',
    'count': 1,
    'sub': 'قل حين تمسي',
    'subEn': 'Say when you enter the evening',
  },
  {
    'cat': 'أذكار المساء',
    'catEn': 'Evening Adhkar',
    'text':
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
    'transliteration': 'Allahumma afini fi badani, Allahumma afini fi sami',
    'meaning': 'O Allah, grant me health in my body, hearing, and sight',
    'meaningAr': 'طلب العافية في الجسد والحواس',
    'count': 3,
    'sub': 'ثلاث مرات',
    'subEn': 'Three times',
  },
  {
    'cat': 'أذكار النوم',
    'catEn': 'Sleep Adhkar',
    'text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    'transliteration': 'Bismika Allahumma amutu wa ahya',
    'meaning': 'In Your name, O Allah, I die and I live',
    'meaningAr': 'بسم الله ننام ونستيقظ',
    'count': 1,
    'sub': 'قل حين تأوي إلى فراشك',
    'subEn': 'Say when you lie down to sleep',
  },
  {
    'cat': 'أذكار النوم',
    'catEn': 'Sleep Adhkar',
    'text': 'سُبْحَانَ اللهِ',
    'transliteration': 'Subhana-llah',
    'meaning': 'Glory be to Allah — before sleep',
    'meaningAr': 'التسبيح قبل النوم',
    'count': 33,
    'sub': 'قبل النوم',
    'subEn': 'Before sleeping',
  },
  {
    'cat': 'أذكار النوم',
    'catEn': 'Sleep Adhkar',
    'text': 'الْحَمْدُ لِلَّهِ',
    'transliteration': 'Alhamdulillah',
    'meaning': 'All praise is due to Allah — before sleep',
    'meaningAr': 'الحمد قبل النوم',
    'count': 33,
    'sub': 'قبل النوم',
    'subEn': 'Before sleeping',
  },
  {
    'cat': 'أذكار النوم',
    'catEn': 'Sleep Adhkar',
    'text': 'اللهُ أَكْبَرُ',
    'transliteration': 'Allahu Akbar',
    'meaning': 'Allah is the Greatest — better than a servant',
    'meaningAr': 'خير لك من خادم',
    'count': 34,
    'sub': 'قبل النوم — خير لك من خادم',
    'subEn': 'Before sleep — better for you than a servant',
  },
  {
    'cat': 'أذكار النوم',
    'catEn': 'Sleep Adhkar',
    'text': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    'transliteration': 'Allahumma qini adhabaka yawma tab\'athu ibadak',
    'meaning':
        'O Allah, protect me from Your punishment on the day You resurrect Your servants',
    'meaningAr': 'ثلاث مرات قبل النوم',
    'count': 3,
    'sub': 'ثلاث مرات قبل النوم',
    'subEn': 'Three times before sleeping',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'catEn': 'Seeking Help',
    'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    'transliteration': 'La hawla wa la quwwata illa billah',
    'meaning': 'There is no power or strength except with Allah',
    'meaningAr': 'كنز من كنوز الجنة',
    'count': 100,
    'sub': 'كنز من كنوز الجنة',
    'subEn': 'A treasure from the treasures of Paradise',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'catEn': 'Seeking Help',
    'text': 'حَسْبُنَا اللهُ وَنِعْمَ الْوَكِيلُ',
    'transliteration': 'Hasbunallahu wa ni\'mal Wakil',
    'meaning': 'Allah is sufficient for us and the best disposer of affairs',
    'meaningAr': 'قالها إبراهيم عليه السلام في النار',
    'count': 100,
    'sub': 'قالها إبراهيم في النار',
    'subEn': 'Said by Ibrahim when cast into fire',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'catEn': 'Seeking Help',
    'text': 'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
    'transliteration': 'Hasbiyallahu la ilaha illa huwa, alayhi tawakkaltu',
    'meaning':
        'Allah is sufficient for me, there is no god but He, upon Him I rely',
    'meaningAr': 'سبع مرات صباحًا ومساءً',
    'count': 7,
    'sub': 'سبع مرات صباحًا ومساءً',
    'subEn': 'Seven times in the morning and evening',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'catEn': 'Seeking Help',
    'text': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    'transliteration': 'Ya Hayyu ya Qayyum, bi rahmatika astaghith',
    'meaning': 'O Living, O Self-Sustaining, by Your mercy I seek relief',
    'meaningAr': 'من أسماء الله الحسنى',
    'count': 40,
    'sub': 'من أسماء الله الحسنى',
    'subEn': 'From the Beautiful Names of Allah',
  },
  {
    'cat': 'الدعاء والتوسل',
    'catEn': 'Supplication',
    'text':
        'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ',
    'transliteration':
        'Rabbi ighfir li wa tub alayya innaka anta at-Tawwabul Ghafur',
    'meaning':
        'My Lord, forgive me and accept my repentance, You are the Oft-Returning, Most Forgiving',
    'meaningAr': 'كان النبي ﷺ يقولها مئة مرة في المجلس',
    'count': 100,
    'sub': 'كان النبي ﷺ يقولها في المجلس',
    'subEn': 'The Prophet ﷺ would say it 100 times in a sitting',
  },
  {
    'cat': 'الدعاء والتوسل',
    'catEn': 'Supplication',
    'text': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ دِقَّهُ وَجِلَّهُ',
    'transliteration': 'Allahumma ighfir li dhanbi kullahu diqqahu wa jillahu',
    'meaning': 'O Allah, forgive all my sins, the small and the great',
    'meaningAr': 'المغفرة الشاملة لكل الذنوب',
    'count': 33,
    'sub': 'المغفرة الشاملة',
    'subEn': 'Comprehensive forgiveness for all sins',
  },
  {
    'cat': 'الدعاء والتوسل',
    'catEn': 'Supplication',
    'text': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ',
    'transliteration': 'Allahumma inni as\'aluka al-afwa wal-afiyah',
    'meaning': 'O Allah, I ask You for pardon and well-being',
    'meaningAr': 'من أجمع الدعاء',
    'count': 33,
    'sub': 'من أجمع الدعاء',
    'subEn': 'One of the most comprehensive supplications',
  },
  {
    'cat': 'الدعاء والتوسل',
    'catEn': 'Supplication',
    'text':
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    'transliteration':
        'Rabbana atina fid-dunya hasanah wa fil-akhirati hasanah wa qina adhaban-nar',
    'meaning':
        'Our Lord, give us good in this world and good in the Hereafter, and protect us from the Fire',
    'meaningAr': 'أكثر الدعاء الذي كان يدعو به النبي ﷺ',
    'count': 10,
    'sub': 'أكثر الدعاء الذي كان يدعو به النبي ﷺ',
    'subEn': 'The most frequent supplication of the Prophet ﷺ',
  },
  {
    'cat': 'الدعاء والتوسل',
    'catEn': 'Supplication',
    'text':
        'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    'transliteration':
        'Subhanakallahumma wa bihamdika, ashhadu an la ilaha illa anta',
    'meaning':
        'Glory be to You O Allah and all praise, I bear witness none has the right to be worshipped but You',
    'meaningAr': 'كفارة المجلس',
    'count': 3,
    'sub': 'كفارة المجلس',
    'subEn': 'Expiation of the gathering',
  },
  {
    'cat': 'آيات وأدعية',
    'catEn': 'Quranic Duas',
    'text':
        'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    'transliteration':
        'Bismillahil-ladhi la yadurru ma\'a ismihi shay\'un fil-ardi wa la fis-sama',
    'meaning':
        'In the name of Allah, with whose name nothing on earth or in heaven can cause harm',
    'meaningAr': 'من قالها ثلاثاً لم يضره شيء',
    'count': 3,
    'sub': 'من قالها ثلاثاً لم يضره شيء',
    'subEn': 'Whoever says it 3 times, nothing will harm them',
  },
  {
    'cat': 'آيات وأدعية',
    'catEn': 'Quranic Duas',
    'text':
        'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    'transliteration': 'La ilaha illa anta subhanaka inni kuntu minaz-zalimin',
    'meaning':
        'The supplication of Prophet Yunus — No god but You, glory to You, I was among the wrongdoers',
    'meaningAr': 'دعاء يونس عليه السلام في بطن الحوت',
    'count': 40,
    'sub': 'دعاء يونس عليه السلام',
    'subEn': 'The supplication of Prophet Yunus from inside the whale',
  },
  {
    'cat': 'آيات وأدعية',
    'catEn': 'Quranic Duas',
    'text':
        'آيَةُ الْكُرْسِيِّ — اللهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    'transliteration':
        'Ayatul Kursi — Allahu la ilaha illa huwal-Hayyul-Qayyum',
    'meaning': 'The Throne Verse — the greatest verse in the Quran',
    'meaningAr': 'أعظم آية في كتاب الله',
    'count': 1,
    'sub': 'أعظم آية في كتاب الله',
    'subEn': 'The greatest verse in the Book of Allah',
  },
  {
    'cat': 'آيات وأدعية',
    'catEn': 'Quranic Duas',
    'text': 'قُلْ هُوَ اللهُ أَحَدٌ',
    'transliteration': 'Qul huwa-llahu ahad',
    'meaning': 'Say: He is Allah, the One — equals a third of the Quran',
    'meaningAr': 'تعدل ثلث القرآن الكريم',
    'count': 3,
    'sub': 'تعدل ثلث القرآن',
    'subEn': 'Equals one third of the Holy Quran',
  },
  {
    'cat': 'آيات وأدعية',
    'catEn': 'Quranic Duas',
    'text':
        'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
    'transliteration':
        'Rabbi audhu bika min hamazatish-shayatin wa audhu bika Rabbi an yahdurun',
    'meaning':
        'My Lord, I seek refuge with You from the evil whisperings of the devils',
    'meaningAr': 'الاستعاذة من همزات الشياطين',
    'count': 3,
    'sub': 'الاستعاذة من الشياطين',
    'subEn': 'Seeking refuge from the whisperings of devils',
  },
  {
    'cat': 'آيات وأدعية',
    'catEn': 'Quranic Duas',
    'text': 'رَبِّ زِدْنِي عِلْمًا',
    'transliteration': 'Rabbi zidni ilma',
    'meaning': 'My Lord, increase me in knowledge',
    'meaningAr': 'الدعاء بزيادة العلم',
    'count': 33,
    'sub': 'الدعاء بزيادة العلم',
    'subEn': 'Supplication to increase in knowledge',
  },
  {
    'cat': 'الشكر والثناء',
    'catEn': 'Gratitude',
    'text': 'اللَّهُمَّ لَكَ الْحَمْدُ كُلُّهُ وَلَكَ الشُّكْرُ كُلُّهُ',
    'transliteration': 'Allahumma lakal hamdu kulluhu wa lakas shukru kulluhu',
    'meaning': 'O Allah, all praise and all thanks belong to You alone',
    'meaningAr': 'شكر الله على نعمه',
    'count': 10,
    'sub': 'شكر الله على نعمه',
    'subEn': 'Thanking Allah for His countless blessings',
  },
  {
    'cat': 'الشكر والثناء',
    'catEn': 'Gratitude',
    'text': 'الْحَمْدُ لِلَّهِ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
    'transliteration': 'Alhamdulillahi hamdan kathiran tayyiban mubarakan fih',
    'meaning': 'All praise be to Allah, abundant, pure, and blessed praise',
    'meaningAr': 'ملء الموازين يوم القيامة',
    'count': 33,
    'sub': 'ملء الموازين',
    'subEn': 'Fills the scales on the Day of Judgement',
  },
  {
    'cat': 'الشكر والثناء',
    'catEn': 'Gratitude',
    'text':
        'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    'transliteration':
        'Allahumma a\'inni ala dhikrika wa shukrika wa husni ibadatik',
    'meaning':
        'O Allah, help me to remember You, thank You and worship You well',
    'meaningAr': 'وصية النبي ﷺ لمعاذ بن جبل',
    'count': 3,
    'sub': 'وصية النبي ﷺ لمعاذ',
    'subEn': 'The advice of the Prophet ﷺ to Muadh ibn Jabal',
  },
  {
    'cat': 'الرزق والبركة',
    'catEn': 'Provision & Blessing',
    'text':
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ رِزْقًا طَيِّبًا وَعِلْمًا نَافِعًا وَعَمَلًا مُتَقَبَّلًا',
    'transliteration':
        'Allahumma inni as\'aluka rizqan tayyiban wa ilman nafi\'an wa amalan mutaqabbala',
    'meaning':
        'O Allah, I ask You for pure provision, beneficial knowledge, and accepted deeds',
    'meaningAr': 'دعاء الرزق والعلم والعمل',
    'count': 3,
    'sub': 'دعاء الرزق والعلم',
    'subEn': 'Supplication for provision, knowledge and deeds',
  },
  {
    'cat': 'الرزق والبركة',
    'catEn': 'Provision & Blessing',
    'text': 'اللَّهُمَّ بَارِكْ لِي فِيمَا رَزَقْتَنِي وَقِنِي عَذَابَكَ',
    'transliteration': 'Allahumma barik li fima razaqtani wa qini adhabak',
    'meaning':
        'O Allah, bless me in what You have provided for me and protect me from Your punishment',
    'meaningAr': 'طلب البركة في الرزق',
    'count': 3,
    'sub': 'طلب البركة في الرزق',
    'subEn': 'Seeking blessings in provision',
  },
  {
    'cat': 'الرزق والبركة',
    'catEn': 'Provision & Blessing',
    'text': 'تَوَكَّلْتُ عَلَى اللهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    'transliteration':
        'Tawakkaltu alallah wa la hawla wa la quwwata illa billah',
    'meaning':
        'I put my trust in Allah, there is no power or might except with Allah',
    'meaningAr': 'التوكل الكامل على الله',
    'count': 7,
    'sub': 'التوكل على الله',
    'subEn': 'Complete reliance upon Allah',
  },
];

const List<Map<String, String>> kFinishTips = [
  {
    'text': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    'textEn': 'Indeed, Allah is with the patient',
    'source': 'سورة البقرة: ١٥٣',
    'sourceEn': 'Al-Baqarah: 153',
  },
  {
    'text': 'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
    'textEn': 'And be patient, your patience is only through Allah',
    'source': 'سورة النحل: ١٢٧',
    'sourceEn': 'An-Nahl: 127',
  },
  {
    'text': 'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ',
    'textEn':
        'Indeed, Allah loves those who repent and those who purify themselves',
    'source': 'سورة البقرة: ٢٢٢',
    'sourceEn': 'Al-Baqarah: 222',
  },
  {
    'text': 'وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ',
    'textEn': 'And Allah loves the doers of good',
    'source': 'سورة آل عمران: ١٣٤',
    'sourceEn': 'Ali Imran: 134',
  },
  {
    'text': 'إِنَّ اللَّهَ يُحِبُّ الْمُتَّقِينَ',
    'textEn': 'Indeed, Allah loves the righteous',
    'source': 'سورة التوبة: ٤',
    'sourceEn': 'At-Tawbah: 4',
  },
  {
    'text': 'وَمَا عِندَ اللَّهِ خَيْرٌ وَأَبْقَى',
    'textEn': 'And what is with Allah is better and more lasting',
    'source': 'سورة القصص: ٦٠',
    'sourceEn': 'Al-Qasas: 60',
  },
  {
    'text': 'وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ',
    'textEn': 'And My mercy encompasses all things',
    'source': 'سورة الأعراف: ١٥٦',
    'sourceEn': 'Al-A\'raf: 156',
  },
  {
    'text': 'إِنَّ اللَّهَ غَفُورٌ رَحِيمٌ',
    'textEn': 'Indeed, Allah is Forgiving and Merciful',
    'source': 'متكرر في القرآن',
    'sourceEn': 'Repeated throughout the Quran',
  },
  {
    'text': 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
    'textEn': 'And He is with you wherever you are',
    'source': 'سورة الحديد: ٤',
    'sourceEn': 'Al-Hadid: 4',
  },
  {
    'text': 'اللَّهُ لَطِيفٌ بِعِبَادِهِ',
    'textEn': 'Allah is Subtle with His servants',
    'source': 'سورة الشورى: ١٩',
    'sourceEn': 'Ash-Shura: 19',
  },
  {
    'text':
        'مَنْ لَزِمَ الِاسْتِغْفَارَ جَعَلَ اللَّهُ لَهُ مِنْ كُلِّ ضِيقٍ مَخْرَجًا',
    'textEn':
        'Whoever persists in seeking forgiveness, Allah will make a way out for him from every distress',
    'source': 'أبو داود',
    'sourceEn': 'Abu Dawud',
  },
  {
    'text': 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
    'textEn': 'Supplication is worship itself',
    'source': 'الترمذي',
    'sourceEn': 'At-Tirmidhi',
  },
  {
    'text': 'أَفْضَلُ الذِّكْرِ لَا إِلَهَ إِلَّا اللَّهُ',
    'textEn': 'The best remembrance is La ilaha illa-llah',
    'source': 'الترمذي',
    'sourceEn': 'At-Tirmidhi',
  },
  {
    'text': 'مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللَّهُ عَلَيْهِ بِهَا عَشْرًا',
    'textEn': 'Whoever sends one blessing upon me, Allah sends ten upon him',
    'source': 'مسلم',
    'sourceEn': 'Muslim',
  },
  {
    'text': 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ',
    'textEn': 'Fear Allah wherever you are',
    'source': 'الترمذي',
    'sourceEn': 'At-Tirmidhi',
  },
  {
    'text': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    'textEn': 'The best of you are those who learn the Quran and teach it',
    'source': 'البخاري',
    'sourceEn': 'Al-Bukhari',
  },
  {
    'text': 'رَبِّ زِدْنِي عِلْمًا',
    'textEn': 'My Lord, increase me in knowledge',
    'source': 'سورة طه: ١١٤',
    'sourceEn': 'Ta-Ha: 114',
  },
  {
    'text': 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
    'textEn':
        'Our Lord, accept from us. Indeed, You are the All-Hearing, All-Knowing',
    'source': 'سورة البقرة: ١٢٧',
    'sourceEn': 'Al-Baqarah: 127',
  },
  {
    'text':
        'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي وَعَافِنِي وَارْزُقْنِي',
    'textEn':
        'O Allah, forgive me, have mercy on me, guide me, give me health and provide for me',
    'source': 'مسلم',
    'sourceEn': 'Muslim',
  },
  {
    'text': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
    'textEn': 'O Allah, I seek refuge in You from anxiety and sorrow',
    'source': 'البخاري',
    'sourceEn': 'Al-Bukhari',
  },
  {
    'text': 'اللَّهُمَّ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
    'textEn': 'O Allah, make my heart firm upon Your religion',
    'source': 'الترمذي',
    'sourceEn': 'At-Tirmidhi',
  },
  {
    'text': 'اللَّهُمَّ ارْزُقْنِي حُسْنَ الْخَاتِمَةِ',
    'textEn': 'O Allah, grant me a good ending',
    'source': 'دعاء مأثور',
    'sourceEn': 'Narrated supplication',
  },
];

// ════════════════════════════════════════════════════════════════════════════
// BEAD THEME
// ════════════════════════════════════════════════════════════════════════════
class _BeadTheme {
  final String id, name, nameEn;
  final Color bead, beadDark, string;
  const _BeadTheme({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.bead,
    required this.beadDark,
    required this.string,
  });
}

const kBeadThemes = [
  _BeadTheme(
    id: 'jade',
    name: 'زمرد',
    nameEn: 'Jade',
    bead: Color(0xFF028544),
    beadDark: Color(0xFF015C2F),
    string: Color(0xFF028544),
  ),
  _BeadTheme(
    id: 'rose',
    name: 'وردي',
    nameEn: 'Rose',
    bead: Color(0xFFB5367A),
    beadDark: Color(0xFF7A1E50),
    string: Color(0xFFB5367A),
  ),
  _BeadTheme(
    id: 'amber',
    name: 'عنبر',
    nameEn: 'Amber',
    bead: Color(0xFFB8962E),
    beadDark: Color(0xFF7A620F),
    string: Color(0xFFB8962E),
  ),
  _BeadTheme(
    id: 'turquoise',
    name: 'فيروز',
    nameEn: 'Turquoise',
    bead: Color(0xFF0BA4A0),
    beadDark: Color(0xFF076E6B),
    string: Color(0xFF0BA4A0),
  ),
  _BeadTheme(
    id: 'ruby',
    name: 'ياقوت',
    nameEn: 'Ruby',
    bead: Color(0xFFB02020),
    beadDark: Color(0xFF7A0F0F),
    string: Color(0xFFB02020),
  ),
  _BeadTheme(
    id: 'pearl',
    name: 'لؤلؤ',
    nameEn: 'Pearl',
    bead: Color(0xFF8899BB),
    beadDark: Color(0xFF4A5A7A),
    string: Color(0xFF8899BB),
  ),
  _BeadTheme(
    id: 'wood',
    name: 'خشب',
    nameEn: 'Wood',
    bead: Color(0xFF8B5E3C),
    beadDark: Color(0xFF5A3D26),
    string: Color(0xFF8B5E3C),
  ),
  _BeadTheme(
    id: 'indigo',
    name: 'نيلي',
    nameEn: 'Indigo',
    bead: Color(0xFF3F51B5),
    beadDark: Color(0xFF273380),
    string: Color(0xFF3F51B5),
  ),
];

// ════════════════════════════════════════════════════════════════════════════
// SESSION + CFG
// ════════════════════════════════════════════════════════════════════════════
class _Session {
  final String dhikrText;
  final int count;
  final DateTime time;
  const _Session({
    required this.dhikrText,
    required this.count,
    required this.time,
  });
}

class _Cfg {
  final double side, width, height;
  _Cfg(BuildContext ctx)
    : side = MediaQuery.sizeOf(ctx).shortestSide,
      width = MediaQuery.sizeOf(ctx).width,
      height = MediaQuery.sizeOf(ctx).height;
  bool get isTablet => side >= 600;
  double get titleFont => (side * 0.058).clamp(18.0, 28.0);
  double get dhikrFont => (side * 0.046).clamp(15.0, 22.0);
  double get labelFont => (side * 0.033).clamp(11.0, 16.0);
  double get hPad => isTablet ? 28.0 : 18.0;
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════════════════
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});
  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  int? _selectedIdx;
  int _count = 0;
  bool _completed = false;
  int _beadIdx = 0;
  bool _silent = false;
  final List<_Session> _sessions = [];
  int _todayTotal = 0;

  late final AnimationController _tapCtrl, _completeCtrl, _bgCtrl, _tipCtrl;
  late final Animation<double> _tapAnim, _completeAnim, _bgAnim, _tipAnim;

  Map<String, dynamic> get _dhikr => kAllAdhkar[_selectedIdx ?? 0];
  int get _target => _dhikr['count'] as int;
  _BeadTheme get _bead => kBeadThemes[_beadIdx];
  bool get _isAr => context.locale.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _tapAnim = CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOutBack);
    _completeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _completeAnim = CurvedAnimation(
      parent: _completeCtrl,
      curve: Curves.elasticOut,
    );
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
    _tipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tipAnim = CurvedAnimation(parent: _tipCtrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    _completeCtrl.dispose();
    _bgCtrl.dispose();
    _tipCtrl.dispose();
    super.dispose();
  }

  void _haptic(HapticFeedbackType t) {
    if (_silent) return;
    switch (t) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.select:
        HapticFeedback.selectionClick();
    }
  }

  void _select(int i) {
    _haptic(HapticFeedbackType.select);
    _completeCtrl.reset();
    _tipCtrl.reset();
    setState(() {
      _selectedIdx = i;
      _count = 0;
      _completed = false;
    });
  }

  void _goBack() {
    _haptic(HapticFeedbackType.select);
    _completeCtrl.reset();
    _tipCtrl.reset();
    setState(() {
      _selectedIdx = null;
      _count = 0;
      _completed = false;
    });
  }

  void _onTap() {
    if (_completed) {
      _haptic(HapticFeedbackType.medium);
      _completeCtrl.reset();
      _tipCtrl.reset();
      _tapCtrl.forward(from: 0);
      setState(() {
        _count = 1;
        _completed = false;
      });
      return;
    }
    _haptic(HapticFeedbackType.light);
    _tapCtrl.forward(from: 0);
    setState(() {
      _count++;
    });
    if (_count >= _target) {
      _haptic(HapticFeedbackType.heavy);
      Future.delayed(
        const Duration(milliseconds: 180),
        () => _haptic(HapticFeedbackType.heavy),
      );
      _sessions.add(
        _Session(
          dhikrText: _dhikr['text'] as String,
          count: _count,
          time: DateTime.now(),
        ),
      );
      setState(() {
        _completed = true;
        _todayTotal += _count;
      });
      _completeCtrl.forward(from: 0);
      _tipCtrl.forward(from: 0);
    }
  }

  void _reset() {
    _haptic(HapticFeedbackType.select);
    _completeCtrl.reset();
    _tipCtrl.reset();
    setState(() {
      _count = 0;
      _completed = false;
    });
  }

  String _randomTip() {
    final t = kFinishTips[math.Random().nextInt(kFinishTips.length)];
    return _isAr
        ? '"${t['text']!}"\n— ${t['source']!}'
        : '"${t['textEn']!}"\n— ${t['sourceEn']!}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _Cfg(context);
    final primary = AppColors.getPrimary(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: _selectedIdx != null
              ? const Offset(1, 0)
              : const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: _selectedIdx == null
          ? _SelectionScreen(
              key: const ValueKey('sel'),
              isDark: isDark,
              cfg: cfg,
              primary: primary,
              isAr: _isAr,
              onSelect: _select,
              sessions: _sessions,
              todayTotal: _todayTotal,
            )
          : _CounterScreen(
              key: ValueKey('ctr_$_selectedIdx'),
              isDark: isDark,
              cfg: cfg,
              primary: primary,
              isAr: _isAr,
              dhikr: _dhikr,
              count: _count,
              completed: _completed,
              beadTheme: _bead,
              beadThemeIdx: _beadIdx,
              silentMode: _silent,
              sessions: _sessions,
              todayTotal: _todayTotal,
              tapAnim: _tapAnim,
              completeAnim: _completeAnim,
              bgAnim: _bgAnim,
              tipAnim: _tipAnim,
              randomTip: _randomTip,
              onTap: _onTap,
              onReset: _reset,
              onBack: _goBack,
              onBeadTheme: (i) => setState(() => _beadIdx = i),
              onSilentToggle: () => setState(() => _silent = !_silent),
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SELECTION SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _SelectionScreen extends StatefulWidget {
  final bool isDark, isAr;
  final _Cfg cfg;
  final Color primary;
  final void Function(int) onSelect;
  final List<_Session> sessions;
  final int todayTotal;
  const _SelectionScreen({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.onSelect,
    required this.sessions,
    required this.todayTotal,
  });
  @override
  State<_SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<_SelectionScreen>
    with AutomaticKeepAliveClientMixin {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  String _filter = '';
  String? _activeCat;
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  // Stable cat list — computed once at widget creation
  late final List<String> _cats = () {
    final seen = <String>{};
    return kAllAdhkar
        .map((d) => (widget.isAr ? d['cat'] : d['catEn']) as String)
        .where(seen.add)
        .toList();
  }();

  List<_CatGroup> _buildGroups() {
    final f = _filter;
    final map = <String, List<MapEntry<int, Map<String, dynamic>>>>{};
    for (final e in kAllAdhkar.asMap().entries) {
      final d = e.value;
      if (f.isNotEmpty) {
        final match =
            (d['text'] as String).contains(f) ||
            (d['transliteration'] as String).toLowerCase().contains(f) ||
            (d['cat'] as String).contains(f) ||
            (d['catEn'] as String).toLowerCase().contains(f);
        if (!match) continue;
      }
      if (_activeCat != null &&
          (widget.isAr ? d['cat'] : d['catEn']) != _activeCat) {
        continue;
      }
      final cat = widget.isAr ? d['cat'] as String : d['catEn'] as String;
      map.putIfAbsent(cat, () => []).add(e);
    }
    return map.entries.map((e) => _CatGroup(e.key, e.value)).toList();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _filter = v.toLowerCase());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cardBg = AppColors.cardBackground(context);
    final groups = _buildGroups(); // computed once per build

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                widget.cfg.hPad,
                20,
                widget.cfg.hPad,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isAr ? 'اختر الذِكر' : 'Select Tasbih',
                              style: _TS.amiriBold(
                                widget.cfg.titleFont * 1.15,
                                widget.isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isAr ? 'Choose your Tasbih' : 'اختر ذِكرك',
                              style: _TS.amiri(
                                widget.cfg.labelFont,
                                widget.primary.withValues(alpha: 0.65),
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.todayTotal > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: widget.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.todayTotal}',
                                style: TextStyle(
                                  color: widget.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.cfg.labelFont + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Search bar — FIXED: Container has NO color,
                  //    TextField owns the background via filled+fillColor.
                  //    This eliminates the double-layer visual glitch. ──
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.primary.withValues(alpha: 0.14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primary.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: TextField(
                        controller: _ctrl,
                        textDirection: TextDirection.rtl,
                        onChanged: _onSearch,
                        style: _TS.amiri(
                          widget.cfg.labelFont + 2,
                          widget.isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          // Single background owner — no Container color competing
                          filled: true,
                          fillColor: cardBg,
                          // Suppress all TextField border lines
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: widget.isAr
                              ? 'ابحث... Search...'
                              : 'Search... ابحث...',
                          hintStyle: _TS.amiri(
                            widget.cfg.labelFont + 1,
                            widget.isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: widget.primary.withValues(alpha: 0.55),
                            size: 20,
                          ),
                          suffixIcon: _filter.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _ctrl.clear();
                                    setState(() => _filter = '');
                                  },
                                  child: Icon(
                                    Icons.clear_rounded,
                                    color: widget.primary,
                                    size: 18,
                                  ),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category chips (ListView.builder — no unnecessary allocation)
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cats.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _CategoryChip(
                            label: widget.isAr ? 'الكل' : 'All',
                            isSelected: _activeCat == null,
                            primary: widget.primary,
                            isDark: widget.isDark,
                            onTap: () => setState(() => _activeCat = null),
                          );
                        }
                        final cat = _cats[i - 1];
                        return _CategoryChip(
                          label: cat,
                          isSelected: _activeCat == cat,
                          primary: widget.primary,
                          isDark: widget.isDark,
                          onTap: () => setState(
                            () => _activeCat = _activeCat == cat ? null : cat,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // List — ListView.builder renders only visible items (zero wasted frames)
            Expanded(
              child: groups.isEmpty
                  ? Center(
                      child: Text(
                        widget.isAr ? 'لا توجد نتائج' : 'No results found',
                        style: _TS.amiri(
                          widget.cfg.labelFont + 2,
                          widget.isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    )
                  : _GroupedList(
                      groups: groups,
                      primary: widget.primary,
                      isDark: widget.isDark,
                      cfg: widget.cfg,
                      cardBg: cardBg,
                      isAr: widget.isAr,
                      scrollCtrl: _scroll,
                      onSelect: widget.onSelect,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grouped list (single ListView.builder over flattened items) ──────────────
class _CatGroup {
  final String name;
  final List<MapEntry<int, Map<String, dynamic>>> entries;
  const _CatGroup(this.name, this.entries);
}

class _GroupedList extends StatelessWidget {
  final List<_CatGroup> groups;
  final Color primary, cardBg;
  final bool isDark, isAr;
  final _Cfg cfg;
  final ScrollController scrollCtrl;
  final void Function(int) onSelect;
  const _GroupedList({
    required this.groups,
    required this.primary,
    required this.isDark,
    required this.cfg,
    required this.cardBg,
    required this.isAr,
    required this.scrollCtrl,
    required this.onSelect,
  });

  List<Object> _flat() {
    final out = <Object>[];
    for (final g in groups) {
      out.add(g.name);
      out.addAll(g.entries);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final items = _flat();
    return ListView.builder(
      controller: scrollCtrl,
      padding: EdgeInsets.fromLTRB(cfg.hPad, 4, cfg.hPad, 36),
      itemCount: items.length + 1,
      itemBuilder: (_, i) {
        if (i == items.length) return const SizedBox(height: 20);
        final item = items[i];
        if (item is String) {
          final cnt = groups.firstWhere((g) => g.name == item).entries.length;
          return _CatHeader(
            name: item,
            count: cnt,
            primary: primary,
            labelFont: cfg.labelFont,
          );
        }
        final e = item as MapEntry<int, Map<String, dynamic>>;
        return RepaintBoundary(
          child: _DhikrSelectionCard(
            entry: e,
            primary: primary,
            isDark: isDark,
            cfg: cfg,
            cardBg: cardBg,
            isAr: isAr,
            onTap: () => onSelect(e.key),
          ),
        );
      },
    );
  }
}

// ─── Category header ──────────────────────────────────────────────────────────
class _CatHeader extends StatelessWidget {
  final String name;
  final int count;
  final Color primary;
  final double labelFont;
  const _CatHeader({
    required this.name,
    required this.count,
    required this.primary,
    required this.labelFont,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 12),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(name, style: _TS.amiriBold(labelFont + 3, primary)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: labelFont - 1,
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Category chip ────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected, isDark;
  final Color primary;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? primary : primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? primary : primary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontFamily: GoogleFonts.amiri().fontFamily,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textPrimaryDark : primary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}

// ─── Dhikr selection card ─────────────────────────────────────────────────────
class _DhikrSelectionCard extends StatelessWidget {
  final MapEntry<int, Map<String, dynamic>> entry;
  final Color primary, cardBg;
  final bool isDark, isAr;
  final _Cfg cfg;
  final VoidCallback onTap;
  const _DhikrSelectionCard({
    required this.entry,
    required this.primary,
    required this.isDark,
    required this.cfg,
    required this.cardBg,
    required this.isAr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final d = entry.value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.07 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: primary.withValues(alpha: isDark ? 0.13 : 0.08),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['text'] as String,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _TS.amiriQuran(
                          cfg.labelFont + 5,
                          isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        d['transliteration'] as String,
                        style: _TS.transliteration.copyWith(
                          fontSize: cfg.labelFont + 0.5,
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '"${isAr ? d['meaningAr'] : d['meaning']}"',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: _TS.amiri(
                          cfg.labelFont - 1,
                          isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          style: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Count badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.18 : 0.09),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primary.withValues(alpha: isDark ? 0.28 : 0.18),
                      ),
                    ),
                    child: Text(
                      'x${d['count']}',
                      style: TextStyle(
                        fontSize: cfg.labelFont + 1,
                        color: primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COUNTER SCREEN
// ════════════════════════════════════════════════════════════════════════════
class _CounterScreen extends StatelessWidget {
  final bool isDark, isAr, completed, silentMode;
  final _Cfg cfg;
  final Color primary;
  final Map<String, dynamic> dhikr;
  final int count, beadThemeIdx, todayTotal;
  final _BeadTheme beadTheme;
  final List<_Session> sessions;
  final Animation<double> tapAnim, completeAnim, bgAnim, tipAnim;
  final String Function() randomTip;
  final VoidCallback onTap, onReset, onBack, onSilentToggle;
  final void Function(int) onBeadTheme;

  const _CounterScreen({
    super.key,
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.dhikr,
    required this.count,
    required this.completed,
    required this.beadTheme,
    required this.beadThemeIdx,
    required this.silentMode,
    required this.sessions,
    required this.todayTotal,
    required this.tapAnim,
    required this.completeAnim,
    required this.bgAnim,
    required this.tipAnim,
    required this.randomTip,
    required this.onTap,
    required this.onReset,
    required this.onBack,
    required this.onBeadTheme,
    required this.onSilentToggle,
  });

  int get _target => dhikr['count'] as int;

  @override
  Widget build(BuildContext context) {
    final arabicText = dhikr['text'] as String;
    final sub = isAr ? dhikr['sub'] as String : dhikr['subEn'] as String;
    final title = dhikr['transliteration'] as String;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            _CounterHeader(
              isDark: isDark,
              cfg: cfg,
              primary: primary,
              title: title,
              silentMode: silentMode,
              sessionCount: sessions.length,
              onBack: onBack,
              onSilentToggle: onSilentToggle,
              onSessionLog: () => _sheet(
                context,
                _SessionLogSheet(
                  sessions: sessions,
                  isDark: isDark,
                  cfg: cfg,
                  primary: primary,
                  todayTotal: todayTotal,
                  isAr: isAr,
                ),
              ),
              onThemeSettings: () => _sheet(
                context,
                _BeadThemeSheet(
                  isDark: isDark,
                  cfg: cfg,
                  primary: primary,
                  selectedIdx: beadThemeIdx,
                  isAr: isAr,
                  onSelect: onBeadTheme,
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  // Tap area
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        children: [
                          // Background (isolated repaint layer)
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: AnimatedBuilder(
                                animation: bgAnim,
                                builder: (_, __) => CustomPaint(
                                  painter: _BgDecorPainter(
                                    isDark: isDark,
                                    primary: beadTheme.bead,
                                    progress: bgAnim.value,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Beads (isolated repaint layer)
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: AnimatedBuilder(
                                animation: Listenable.merge([
                                  tapAnim,
                                  completeAnim,
                                ]),
                                builder: (_, __) => CustomPaint(
                                  painter: _TasbihPainter(
                                    count: count,
                                    total: _target,
                                    tapProgress: tapAnim.value,
                                    completed: completed,
                                    completeProgress: completeAnim.value,
                                    isDark: isDark,
                                    beadTheme: beadTheme,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Tap hint
                          if (count == 0 && !completed)
                            Positioned(
                              bottom: cfg.height * 0.25,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: primary.withValues(alpha: 0.18),
                                    ),
                                  ),
                                  child: Text(
                                    isAr
                                        ? 'انقر في أي مكان للبدء'
                                        : 'Tap anywhere to begin',
                                    style: _TS.amiri(
                                      cfg.labelFont + 1,
                                      primary.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Bottom dhikr card
                          Positioned(
                            bottom: 14,
                            left: cfg.hPad,
                            right: cfg.hPad,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.backgroundCardDark.withValues(
                                        alpha: 0.93,
                                      )
                                    : AppColors.white.withValues(alpha: 0.93),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: primary.withValues(alpha: 0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, -3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    arabicText,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: _TS.amiriQuran(
                                      cfg.dhikrFont,
                                      isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                      height: 1.85,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sub,
                                    textAlign: TextAlign.center,
                                    style: _TS.amiri(
                                      cfg.labelFont,
                                      isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      style: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Counter + reset (outside tap GD)
                  if (!completed)
                    Positioned(
                      top: cfg.height * 0.04,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: tapAnim,
                        builder: (_, __) => Transform.scale(
                          scale: 1.0 + 0.055 * tapAnim.value,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: onReset,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primary.withValues(
                                          alpha: isDark ? 0.15 : 0.08,
                                        ),
                                        border: Border.all(
                                          color: primary.withValues(
                                            alpha: 0.25,
                                          ),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.replay_rounded,
                                        color: primary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    '$count',
                                    style: _TS.counter.copyWith(
                                      fontSize: (cfg.side * 0.20).clamp(
                                        60.0,
                                        100.0,
                                      ),
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '/ $_target',
                                style: TextStyle(
                                  fontSize: cfg.labelFont + 2,
                                  color: primary.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Today badge
                  if (todayTotal > 0)
                    Positioned(
                      top: 12,
                      left: 14,
                      child: _TodayBadge(
                        total: todayTotal,
                        primary: primary,
                        isDark: isDark,
                        isAr: isAr,
                      ),
                    ),

                  // Completion tip
                  if (completed)
                    Positioned(
                      top: 12,
                      left: cfg.hPad,
                      right: cfg.hPad,
                      child: AnimatedBuilder(
                        animation: tipAnim,
                        builder: (_, __) => Transform.scale(
                          scale: 0.7 + 0.3 * tipAnim.value,
                          child: Opacity(
                            opacity: tipAnim.value.clamp(0.0, 1.0),
                            child: _FinishTipCard(
                              tip: randomTip(),
                              primary: primary,
                              isDark: isDark,
                              cfg: cfg,
                              isAr: isAr,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sheet(BuildContext ctx, Widget w) => showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => w,
  );
}

// ─── Counter Header ───────────────────────────────────────────────────────────
class _CounterHeader extends StatelessWidget {
  final bool isDark, silentMode;
  final _Cfg cfg;
  final Color primary;
  final String title;
  final int sessionCount;
  final VoidCallback onBack, onSilentToggle, onSessionLog, onThemeSettings;
  const _CounterHeader({
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.title,
    required this.silentMode,
    required this.sessionCount,
    required this.onBack,
    required this.onSilentToggle,
    required this.onSessionLog,
    required this.onThemeSettings,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Row(
      children: [
        _CircleBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: onBack,
          primary: primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: cfg.titleFont * 0.8,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CircleBtn(
          icon: Icons.history_rounded,
          onTap: onSessionLog,
          primary: primary,
          badge: sessionCount > 0 ? '$sessionCount' : null,
        ),
        const SizedBox(width: 6),
        _CircleBtn(
          icon: Icons.palette_outlined,
          onTap: onThemeSettings,
          primary: primary,
        ),
      ],
    ),
  );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primary;
  final bool active;
  final String? badge;
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.primary,
    this.active = false,
    this.badge,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? primary.withValues(alpha: 0.18)
                : primary.withValues(alpha: 0.08),
            border: Border.all(
              color: primary.withValues(alpha: active ? 0.35 : 0.15),
            ),
          ),
          child: Icon(icon, color: primary, size: 18),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// ─── Shared small widgets ─────────────────────────────────────────────────────
class _TodayBadge extends StatelessWidget {
  final int total;
  final Color primary;
  final bool isDark, isAr;
  const _TodayBadge({
    required this.total,
    required this.primary,
    required this.isDark,
    required this.isAr,
  });
  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 12, color: primary),
          const SizedBox(width: 4),
          Text(
            '$total',
            style: TextStyle(
              fontSize: 11,
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishTipCard extends StatelessWidget {
  final String tip;
  final Color primary;
  final bool isDark, isAr;
  final _Cfg cfg;
  const _FinishTipCard({
    required this.tip,
    required this.primary,
    required this.isDark,
    required this.cfg,
    required this.isAr,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [primary, Color.lerp(primary, AppColors.success, 0.4)!],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: primary.withValues(alpha: 0.3),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isAr ? 'اكتمل التسبيح 🎉' : 'Tasbih Complete! 🎉',
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.white30, height: 16),
        Text(
          tip,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textAlign: TextAlign.center,
          style: _TS.amiri(
            cfg.labelFont,
            Colors.white.withValues(alpha: 0.92),
            height: 1.7,
          ),
        ),
      ],
    ),
  );
}

class _Handle extends StatelessWidget {
  final Color primary;
  const _Handle({required this.primary});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 4),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: primary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

// ─── Bottom sheets ────────────────────────────────────────────────────────────
class _BeadThemeSheet extends StatefulWidget {
  final bool isDark, isAr;
  final _Cfg cfg;
  final Color primary;
  final int selectedIdx;
  final void Function(int) onSelect;
  const _BeadThemeSheet({
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.selectedIdx,
    required this.onSelect,
  });
  @override
  State<_BeadThemeSheet> createState() => _BeadThemeSheetState();
}

class _BeadThemeSheetState extends State<_BeadThemeSheet> {
  late int _sel;
  @override
  void initState() {
    super.initState();
    _sel = widget.selectedIdx;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
    decoration: BoxDecoration(
      color: widget.isDark ? AppColors.backgroundCardDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: widget.primary.withValues(alpha: 0.15)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Handle(primary: widget.primary),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            widget.isAr ? 'خامة الخرز' : 'Bead Theme',
            style: _TS.amiriBold(widget.cfg.titleFont, widget.primary),
          ),
        ),
        Divider(height: 1, color: widget.primary.withValues(alpha: 0.12)),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kBeadThemes.asMap().entries.map((e) {
            final sel = e.key == _sel;
            return GestureDetector(
              onTap: () {
                setState(() => _sel = e.key);
                widget.onSelect(e.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? e.value.bead.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel
                        ? e.value.bead
                        : e.value.bead.withValues(alpha: 0.3),
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.value.bead,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      widget.isAr ? e.value.name : e.value.nameEn,
                      style: _TS.amiri(
                        widget.cfg.labelFont,
                        sel
                            ? e.value.bead
                            : (widget.isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary),
                        weight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class _SessionLogSheet extends StatelessWidget {
  final List<_Session> sessions;
  final bool isDark, isAr;
  final _Cfg cfg;
  final Color primary;
  final int todayTotal;
  const _SessionLogSheet({
    required this.sessions,
    required this.isDark,
    required this.isAr,
    required this.cfg,
    required this.primary,
    required this.todayTotal,
  });
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
    decoration: BoxDecoration(
      color: isDark ? AppColors.backgroundCardDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: primary.withValues(alpha: 0.15)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Handle(primary: primary),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                isAr ? 'سجل الجلسة' : 'Session Log',
                style: _TS.amiriBold(cfg.titleFont * 0.85, primary),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: primary, size: 16),
              const SizedBox(width: 8),
              Text(
                isAr
                    ? 'المجموع: $todayTotal تسبيحة'
                    : 'Total: $todayTotal tasbih',
                style: _TS.amiriBold(cfg.labelFont + 2, primary),
              ),
            ],
          ),
        ),
        sessions.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isAr
                      ? 'لا توجد جلسات بعد، ابدأ التسبيح!'
                      : 'No sessions yet, start your Tasbih!',
                  style: _TS.amiri(
                    cfg.labelFont + 1,
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              )
            : Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (_, i) {
                    final s = sessions[sessions.length - 1 - i];
                    final t =
                        '${s.time.hour.toString().padLeft(2, '0')}:${s.time.minute.toString().padLeft(2, '0')}';
                    return Column(
                      children: [
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: primary.withValues(alpha: 0.07),
                          ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: primary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            s.dhikrText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                            style: _TS.amiriQuran(
                              cfg.labelFont + 1,
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${s.count} ${isAr ? 'مرة' : 'times'}',
                            style: _TS.amiri(cfg.labelFont, primary),
                          ),
                          trailing: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ════════════════════════════════════════════════════════════════════════════
class _BgDecorPainter extends CustomPainter {
  final bool isDark;
  final Color primary;
  final double progress;
  const _BgDecorPainter({
    required this.isDark,
    required this.primary,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.04 : 0.05)
      ..style = PaintingStyle.fill;
    final f = 8.0 * progress;
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.20 + f), 40, p);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.15 - f), 26, p);
    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.74 - f * 0.5),
      18,
      p,
    );
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.60 + f * 0.7),
      30,
      p,
    );
    final lp = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.04 : 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (var i = -4; i < 8; i++) {
      final x = i * 60.0;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), lp);
    }
  }

  @override
  bool shouldRepaint(covariant _BgDecorPainter o) =>
      o.progress != progress || o.isDark != isDark || o.primary != primary;
}

class _TasbihPainter extends CustomPainter {
  final int count, total;
  final double tapProgress, completeProgress;
  final bool completed, isDark;
  final _BeadTheme beadTheme;

  const _TasbihPainter({
    required this.count,
    required this.total,
    required this.tapProgress,
    required this.completed,
    required this.completeProgress,
    required this.isDark,
    required this.beadTheme,
  });

  static const int _N = 33;
  static const _gold = Color(0xFFB8962E);
  static const _goldL = Color(0xFFDFBE5A);
  static const _goldD = Color(0xFF8A6A10);

  Offset _center(Size s) => Offset(s.width * 0.5, s.height * 0.62);
  double _rx(Size s) => s.width * 0.32;
  double _ry(Size s) => s.height * 0.26;
  Offset _pos(Size s, int i) {
    final c = _center(s);
    final a = -math.pi / 2 + (i / _N) * 2 * math.pi;
    return Offset(c.dx + _rx(s) * math.cos(a), c.dy + _ry(s) * math.sin(a));
  }

  double _depth(int i) =>
      (math.sin(-math.pi / 2 + (i / _N) * 2 * math.pi) + 1) / 2;
  int get _vc => count % _N == 0 && count > 0 ? _N : count % _N;

  @override
  void paint(Canvas canvas, Size size) {
    _drawString(canvas, size);
    _drawBeads(canvas, size);
    _drawHolder(canvas, size);
    _drawTassel(canvas, size);
    if (completed && completeProgress > 0) _drawGlow(canvas, size);
  }

  void _drawString(Canvas canvas, Size size) {
    final vc = _vc;
    for (var i = 0; i < _N; i++) {
      final d = _depth(i);
      canvas.drawLine(
        _pos(size, i),
        _pos(size, (i + 1) % _N),
        Paint()
          ..color = beadTheme.string.withValues(
            alpha: i < vc ? (0.55 + 0.35 * d) : (0.1 + 0.1 * d),
          )
          ..strokeWidth = 1.8 + d * 0.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawBeads(Canvas canvas, Size size) {
    final vc = _vc;
    final order = List.generate(_N, (i) => i)
      ..sort((a, b) => _depth(a).compareTo(_depth(b)));
    for (final i in order) {
      double r = (i == 0 || i == 11 || i == 22) ? 10.5 : 8.0;
      final d = _depth(i);
      r *= (0.82 + 0.28 * d);
      if (i == vc - 1 && count > 0 && !completed) r += 3.8 * tapProgress;
      _drawBead(
        canvas,
        _pos(size, i),
        r,
        i < vc,
        i == vc - 1 && count > 0 && !completed,
        i,
        d,
      );
    }
  }

  void _drawBead(
    Canvas canvas,
    Offset pos,
    double r,
    bool used,
    bool active,
    int idx,
    double depth,
  ) {
    final base = used ? beadTheme.bead : beadTheme.bead.withValues(alpha: 0.18);
    final light = Color.lerp(base, Colors.white, used ? 0.62 : 0.3)!;
    final dark = Color.lerp(base, Colors.black, 0.24)!;
    if (used && depth > 0.3) {
      canvas.drawCircle(
        pos + Offset(1.5 * depth, 2.5 * depth),
        r,
        Paint()
          ..color = base.withValues(alpha: 0.22 * depth)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 2 * depth),
      );
    }
    final angle = -math.pi / 2 + (idx / _N) * 2 * math.pi;
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(
            -0.32 + 0.2 * math.cos(angle + 0.4),
            -0.38 + 0.15 * math.sin(angle),
          ),
          colors: [light, base, dark],
          stops: const [0.0, 0.44, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: r)),
    );
    canvas.drawCircle(
      pos,
      r,
      Paint()
        ..color = (used ? base : beadTheme.bead).withValues(
          alpha: used ? (0.4 + 0.2 * depth) : 0.12,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 + 0.4 * (1 - depth),
    );
    if (used && depth > 0.2)
      canvas.drawCircle(
        pos + Offset(-r * 0.26, -r * 0.28),
        r * (0.17 + 0.06 * depth),
        Paint()..color = Colors.white.withValues(alpha: 0.5 + 0.35 * depth),
      );
    if (active && tapProgress > 0) {
      canvas.drawCircle(
        pos,
        r + 5 * tapProgress,
        Paint()
          ..color = beadTheme.bead.withValues(alpha: 0.3 * (1 - tapProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      canvas.drawCircle(
        pos,
        r + 9 * tapProgress,
        Paint()
          ..color = beadTheme.bead.withValues(alpha: 0.12 * (1 - tapProgress))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawHolder(Canvas canvas, Size size) {
    final top = Offset(_center(size).dx, _center(size).dy - _ry(size));
    for (final dx in [-18.0, 18.0])
      canvas.drawLine(
        top + Offset(dx, 8),
        top,
        Paint()
          ..color = beadTheme.string.withValues(alpha: 0.6)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    canvas.drawCircle(
      top,
      7,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [_goldL, _gold, _goldD],
        ).createShader(Rect.fromCircle(center: top, radius: 7)),
    );
    canvas.drawCircle(
      top,
      7,
      Paint()
        ..color = _goldD.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawCircle(
      top + const Offset(-2, -2),
      2.5,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    const cLen = 38.0, cW = 5.0;
    final cordTop = top + const Offset(0, -cLen);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: top + const Offset(0, -cLen / 2),
          width: cW,
          height: cLen,
        ),
        const Radius.circular(3),
      ),
      Paint()
        ..shader =
            LinearGradient(
              colors: [
                beadTheme.string.withValues(alpha: 0.85),
                beadTheme.string,
                beadTheme.string.withValues(alpha: 0.7),
              ],
              stops: const [0, 0.5, 1],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(
              Rect.fromCenter(
                center: top + const Offset(0, -cLen / 2),
                width: cW,
                height: cLen,
              ),
            ),
    );
    const rH = 22.0, rW = 24.0;
    final rc = cordTop + const Offset(0, -rH / 2);
    canvas.drawOval(
      Rect.fromCenter(center: rc, width: rW, height: rH),
      Paint()
        ..shader = LinearGradient(
          colors: [_goldL, _gold, _goldD],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCenter(center: rc, width: rW, height: rH)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: rc, width: rW - 8, height: rH - 8),
      Paint()
        ..color = isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FF),
    );
    canvas.drawOval(
      Rect.fromCenter(center: rc, width: rW, height: rH),
      Paint()
        ..color = _goldD.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    canvas.drawArc(
      Rect.fromCenter(center: rc, width: rW - 2, height: rH - 2),
      -math.pi * 0.75,
      math.pi * 0.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTassel(Canvas canvas, Size size) {
    final base = Offset(_center(size).dx, _center(size).dy + _ry(size));
    for (final dx in [-5.0, -2.0, 0.0, 2.0, 5.0]) {
      canvas.drawLine(
        base + Offset(dx * 1.4, -4),
        base,
        Paint()
          ..color = beadTheme.string.withValues(alpha: 0.55)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      base,
      9.5,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.38),
          colors: [_goldL, _gold, _goldD],
        ).createShader(Rect.fromCircle(center: base, radius: 9.5)),
    );
    canvas.drawCircle(
      base,
      9.5,
      Paint()
        ..color = _goldD.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawCircle(
      base + const Offset(-2.5, -2.5),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    final tTop = base + const Offset(0, 9.5);
    for (var i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(tTop.dx + i * 4.5, tTop.dy),
        Offset(tTop.dx + i * 5.2 + (i % 2 == 0 ? 2.0 : 0.0), tTop.dy + 36),
        Paint()
          ..color = beadTheme.string.withValues(
            alpha: 0.6 + 0.15 * (i.abs() / 3),
          )
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }
    final tbc = Offset(tTop.dx, tTop.dy + 43);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: tbc, width: 20, height: 14),
        const Radius.circular(4),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [_goldL, _gold, _goldD],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCenter(center: tbc, width: 20, height: 14)),
    );
  }

  void _drawGlow(Canvas canvas, Size size) {
    canvas.drawCircle(
      _center(size),
      math.min(_rx(size), _ry(size)) * 1.4 * completeProgress,
      Paint()
        ..color = beadTheme.bead.withValues(alpha: 0.08 * completeProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
  }

  @override
  bool shouldRepaint(covariant _TasbihPainter o) =>
      o.count != count ||
      o.tapProgress != tapProgress ||
      o.completed != completed ||
      o.completeProgress != completeProgress ||
      o.isDark != isDark ||
      o.beadTheme.id != beadTheme.id;
}

enum HapticFeedbackType { light, medium, heavy, select }
