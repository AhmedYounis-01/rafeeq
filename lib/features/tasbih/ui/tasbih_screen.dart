import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafeeq/core/themes/app_colors.dart';

// ════════════════════════════════════════════════════════════════════════════
// DATA
// ════════════════════════════════════════════════════════════════════════════

// ─── Adhkar (60+) grouped by category ────────────────────────────────────────
const List<Map<String, dynamic>> kAllAdhkar = [
  // ── بعد الصلاة
  {
    'cat': 'بعد الصلاة',
    'text': 'سُبْحَانَ اللهِ',
    'count': 33,
    'icon': '🌿',
    'sub': 'بعد كل صلاة مكتوبة',
  },
  {
    'cat': 'بعد الصلاة',
    'text': 'الْحَمْدُ لِلَّهِ',
    'count': 33,
    'icon': '🌙',
    'sub': 'تملأ الميزان',
  },
  {
    'cat': 'بعد الصلاة',
    'text': 'اللهُ أَكْبَرُ',
    'count': 34,
    'icon': '⭐',
    'sub': 'بعد كل صلاة مكتوبة',
  },
  {
    'cat': 'بعد الصلاة',
    'text': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيمِ',
    'count': 33,
    'icon': '💫',
    'sub': 'خفيفتان على اللسان ثقيلتان في الميزان',
  },
  {
    'cat': 'بعد الصلاة',
    'text':
        'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'count': 10,
    'icon': '💚',
    'sub': 'كمن أعتق أربعة من ولد إسماعيل',
  },
  {
    'cat': 'بعد الصلاة',
    'text': 'أَسْتَغْفِرُ اللهَ',
    'count': 3,
    'icon': '🕊',
    'sub': 'بعد الانتهاء من الصلاة',
  },
  {
    'cat': 'بعد الصلاة',
    'text': 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
    'count': 100,
    'icon': '🕊',
    'sub': 'من استغفر الله غُفر له',
  },
  // ── الصلاة على النبي
  {
    'cat': 'الصلاة على النبي ﷺ',
    'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    'count': 100,
    'icon': '☀️',
    'sub': 'أدنى صلاة عليه ﷺ',
  },
  {
    'cat': 'الصلاة على النبي ﷺ',
    'text': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'count': 100,
    'icon': '☀️',
    'sub': 'من صلّى عليّ عشراً صلى الله عليه مئة',
  },
  {
    'cat': 'الصلاة على النبي ﷺ',
    'text': 'صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ',
    'count': 33,
    'icon': '✨',
    'sub': 'الصلاة على النبي تقرب من الله',
  },
  // ── التهليل والتكبير
  {
    'cat': 'التهليل والتكبير',
    'text': 'لَا إِلَهَ إِلَّا اللهُ',
    'count': 100,
    'icon': '🌟',
    'sub': 'أفضل الذِكر',
  },
  {
    'cat': 'التهليل والتكبير',
    'text':
        'اللهُ أَكْبَرُ كَبِيرًا وَالْحَمْدُ لِلَّهِ كَثِيرًا وَسُبْحَانَ اللهِ بُكْرَةً وَأَصِيلًا',
    'count': 33,
    'icon': '🌅',
    'sub': 'من ذِكر اليوم والليلة',
  },
  {
    'cat': 'التهليل والتكبير',
    'text':
        'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيِي وَيُمِيتُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'count': 10,
    'icon': '💎',
    'sub': 'عشر مرات صباحًا ومساءً',
  },
  // ── التسبيح
  {
    'cat': 'التسبيح',
    'text': 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
    'count': 100,
    'icon': '🌿',
    'sub': 'من قالها مئة مرة غُفرت ذنوبه',
  },
  {
    'cat': 'التسبيح',
    'text': 'سُبْحَانَ اللهِ الْعَظِيمِ وَبِحَمْدِهِ',
    'count': 33,
    'icon': '🌿',
    'sub': 'غُرست له نخلة في الجنة',
  },
  {
    'cat': 'التسبيح',
    'text':
        'سُبْحَانَ اللهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللهُ وَاللهُ أَكْبَرُ',
    'count': 33,
    'icon': '💫',
    'sub': 'أحب الكلام إلى الله',
  },
  {
    'cat': 'التسبيح',
    'text':
        'سُبْحَانَ اللهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
    'count': 3,
    'icon': '🌊',
    'sub': 'ثلاث مرات تعدل أكثر من ذلك',
  },
  // ── أذكار الصباح
  {
    'cat': 'أذكار الصباح',
    'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ',
    'count': 1,
    'icon': '🌄',
    'sub': 'قل حين تصبح',
  },
  {
    'cat': 'أذكار الصباح',
    'text':
        'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
    'count': 1,
    'icon': '🌄',
    'sub': 'قل حين تصبح',
  },
  {
    'cat': 'أذكار الصباح',
    'text':
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ',
    'count': 1,
    'icon': '🌸',
    'sub': 'سيد الاستغفار',
  },
  {
    'cat': 'أذكار الصباح',
    'text': 'أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    'count': 3,
    'icon': '🛡️',
    'sub': 'حفظ من الشيطان',
  },
  {
    'cat': 'أذكار الصباح',
    'text': 'بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ',
    'count': 3,
    'icon': '✨',
    'sub': 'افتتاح اليوم بسم الله',
  },
  // ── أذكار المساء
  {
    'cat': 'أذكار المساء',
    'text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
    'count': 1,
    'icon': '🌇',
    'sub': 'قل حين تمسي',
  },
  {
    'cat': 'أذكار المساء',
    'text':
        'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
    'count': 1,
    'icon': '🌇',
    'sub': 'قل حين تمسي',
  },
  {
    'cat': 'أذكار المساء',
    'text':
        'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
    'count': 3,
    'icon': '🌿',
    'sub': 'ثلاث مرات',
  },
  // ── أذكار النوم
  {
    'cat': 'أذكار النوم',
    'text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    'count': 1,
    'icon': '🌙',
    'sub': 'قل حين تأوي إلى فراشك',
  },
  {
    'cat': 'أذكار النوم',
    'text': 'سُبْحَانَ اللهِ',
    'count': 33,
    'icon': '🌙',
    'sub': 'قبل النوم',
  },
  {
    'cat': 'أذكار النوم',
    'text': 'الْحَمْدُ لِلَّهِ',
    'count': 33,
    'icon': '🌙',
    'sub': 'قبل النوم',
  },
  {
    'cat': 'أذكار النوم',
    'text': 'اللهُ أَكْبَرُ',
    'count': 34,
    'icon': '🌙',
    'sub': 'قبل النوم — خير لك من خادم',
  },
  {
    'cat': 'أذكار النوم',
    'text': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
    'count': 3,
    'icon': '🌙',
    'sub': 'ثلاث مرات قبل النوم',
  },
  // ── الحوقلة والاستعانة
  {
    'cat': 'الحوقلة والاستعانة',
    'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    'count': 100,
    'icon': '⚡',
    'sub': 'كنز من كنوز الجنة',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'text': 'حَسْبُنَا اللهُ وَنِعْمَ الْوَكِيلُ',
    'count': 100,
    'icon': '🛡️',
    'sub': 'قالها إبراهيم في النار',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'text': 'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
    'count': 7,
    'icon': '💙',
    'sub': 'سبع مرات صباحًا ومساءً',
  },
  {
    'cat': 'الحوقلة والاستعانة',
    'text': 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    'count': 40,
    'icon': '💎',
    'sub': 'من أسماء الله الحسنى',
  },
  // ── الدعاء والتوسل
  {
    'cat': 'الدعاء والتوسل',
    'text':
        'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ',
    'count': 100,
    'icon': '🕊',
    'sub': 'كان النبي ﷺ يقولها في المجلس',
  },
  {
    'cat': 'الدعاء والتوسل',
    'text': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي كُلَّهُ دِقَّهُ وَجِلَّهُ',
    'count': 33,
    'icon': '🕊',
    'sub': 'المغفرة الشاملة',
  },
  {
    'cat': 'الدعاء والتوسل',
    'text': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ',
    'count': 33,
    'icon': '💚',
    'sub': 'من أجمع الدعاء',
  },
  {
    'cat': 'الدعاء والتوسل',
    'text':
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    'count': 10,
    'icon': '🌸',
    'sub': 'أكثر الدعاء الذي كان يدعو به النبي ﷺ',
  },
  {
    'cat': 'الدعاء والتوسل',
    'text':
        'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ',
    'count': 3,
    'icon': '✨',
    'sub': 'كفارة المجلس',
  },
  // ── آيات وأدعية مختارة
  {
    'cat': 'آيات وأدعية',
    'text':
        'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    'count': 3,
    'icon': '🛡️',
    'sub': 'من قالها ثلاثاً لم يضره شيء',
  },
  {
    'cat': 'آيات وأدعية',
    'text':
        'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ',
    'count': 33,
    'icon': '🌹',
    'sub': 'الصلاة الإبراهيمية',
  },
  {
    'cat': 'آيات وأدعية',
    'text':
        'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    'count': 40,
    'icon': '💙',
    'sub': 'دعاء يونس عليه السلام',
  },
  {
    'cat': 'آيات وأدعية',
    'text':
        'رَبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَنْ يَحْضُرُونِ',
    'count': 3,
    'icon': '🛡️',
    'sub': 'الاستعاذة من الشياطين',
  },
  {
    'cat': 'آيات وأدعية',
    'text':
        'آيَةُ الْكُرْسِيِّ — اللهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
    'count': 1,
    'icon': '📖',
    'sub': 'أعظم آية في كتاب الله',
  },
  {
    'cat': 'آيات وأدعية',
    'text': 'قُلْ هُوَ اللهُ أَحَدٌ',
    'count': 3,
    'icon': '📖',
    'sub': 'تعدل ثلث القرآن',
  },
  {
    'cat': 'آيات وأدعية',
    'text': 'رَبِّ زِدْنِي عِلْمًا',
    'count': 33,
    'icon': '📚',
    'sub': 'الدعاء بزيادة العلم',
  },
  // ── الشكر والثناء
  {
    'cat': 'الشكر والثناء',
    'text': 'اللَّهُمَّ لَكَ الْحَمْدُ كُلُّهُ وَلَكَ الشُّكْرُ كُلُّهُ',
    'count': 10,
    'icon': '🌟',
    'sub': 'شكر الله على نعمه',
  },
  {
    'cat': 'الشكر والثناء',
    'text': 'الْحَمْدُ لِلَّهِ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ',
    'count': 33,
    'icon': '🌸',
    'sub': 'ملء الموازين',
  },
  {
    'cat': 'الشكر والثناء',
    'text':
        'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    'count': 3,
    'icon': '💚',
    'sub': 'وصية النبي ﷺ لمعاذ',
  },
  // ── للرزق والبركة
  {
    'cat': 'الرزق والبركة',
    'text':
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ رِزْقًا طَيِّبًا وَعِلْمًا نَافِعًا وَعَمَلًا مُتَقَبَّلًا',
    'count': 3,
    'icon': '💰',
    'sub': 'دعاء الرزق والعلم',
  },
  {
    'cat': 'الرزق والبركة',
    'text': 'اللَّهُمَّ بَارِكْ لِي فِيمَا رَزَقْتَنِي وَقِنِي عَذَابَكَ',
    'count': 3,
    'icon': '🌟',
    'sub': 'طلب البركة في الرزق',
  },
  {
    'cat': 'الرزق والبركة',
    'text': 'تَوَكَّلْتُ عَلَى اللهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ',
    'count': 7,
    'icon': '⚡',
    'sub': 'التوكل على الله',
  },
];

// ─── Finish Tips (shown after completing a dhikr) ─────────────────────────────
const List<Map<String, String>> kFinishTips = [
  {'text': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ', 'source': 'سورة البقرة: ١٥٣'},
  {
    'text': 'وَاصْبِرْ وَمَا صَبْرُكَ إِلَّا بِاللَّهِ',
    'source': 'سورة النحل: ١٢٧',
  },
  {
    'text': 'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ',
    'source': 'سورة البقرة: ٢٢٢',
  },
  {'text': 'وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ', 'source': 'سورة آل عمران: ١٣٤'},
  {'text': 'إِنَّ اللَّهَ يُحِبُّ الْمُتَّقِينَ', 'source': 'سورة التوبة: ٤'},
  {'text': 'وَمَا عِندَ اللَّهِ خَيْرٌ وَأَبْقَى', 'source': 'سورة القصص: ٦٠'},
  {'text': 'وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ', 'source': 'سورة الأعراف: ١٥٦'},
  {'text': 'إِنَّ اللَّهَ غَفُورٌ رَحِيمٌ', 'source': 'متكرر في القرآن'},
  {'text': 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ', 'source': 'سورة الحديد: ٤'},
  {'text': 'اللَّهُ لَطِيفٌ بِعِبَادِهِ', 'source': 'سورة الشورى: ١٩'},

  {
    'text':
        'مَنْ لَزِمَ الِاسْتِغْفَارَ جَعَلَ اللَّهُ لَهُ مِنْ كُلِّ ضِيقٍ مَخْرَجًا',
    'source': 'أبو داود',
  },
  {'text': 'الدُّعَاءُ هُوَ الْعِبَادَةُ', 'source': 'الترمذي'},
  {
    'text':
        'إِنَّ أَحَبَّ الْكَلَامِ إِلَى اللَّهِ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'source': 'مسلم',
  },
  {
    'text': 'مَنْ قَالَ لَا إِلَهَ إِلَّا اللَّهُ دَخَلَ الْجَنَّةَ',
    'source': 'أحمد',
  },
  {
    'text':
        'مَنْ اسْتَغْفَرَ اللَّهَ غُفِرَ لَهُ وَإِنْ كَانَ فَارًّا مِنَ الزَّحْفِ',
    'source': 'أبو داود',
  },
  {
    'text': 'أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ',
    'source': 'مسلم',
  },
  {
    'text': 'مَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللَّهُ عَلَيْهِ بِهَا عَشْرًا',
    'source': 'مسلم',
  },
  {'text': 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ', 'source': 'الترمذي'},
  {'text': 'أَفْضَلُ الذِّكْرِ لَا إِلَهَ إِلَّا اللَّهُ', 'source': 'الترمذي'},
  {
    'text': 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    'source': 'البخاري',
  },

  {
    'text':
        'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    'source': 'أبو داود',
  },
  {'text': 'اللَّهُمَّ اغْفِرْ لِي وَارْحَمْنِي وَاهْدِنِي', 'source': 'مسلم'},
  {
    'text':
        'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ',
    'source': 'أبو داود',
  },
  {'text': 'اللَّهُمَّ ثَبِّتْ قَلْبِي عَلَى دِينِكَ', 'source': 'الترمذي'},
  {
    'text': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
    'source': 'البخاري',
  },
  {'text': 'اللَّهُمَّ ارْزُقْنِي حُسْنَ الْخَاتِمَةِ', 'source': 'دعاء مأثور'},
  {
    'text': 'اللَّهُمَّ اجْعَلْنِي مِنَ الذَّاكِرِينَ كَثِيرًا',
    'source': 'دعاء',
  },
  {'text': 'اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ', 'source': 'دعاء قرآني'},
  {'text': 'رَبِّ زِدْنِي عِلْمًا', 'source': 'سورة طه: ١١٤'},
  {
    'text': 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
    'source': 'سورة البقرة: ١٢٧',
  },
];

// ─── Bead Themes ─────────────────────────────────────────────────────────────
class _BeadTheme {
  final String id, name;
  final Color bead, beadDark, string;
  const _BeadTheme({
    required this.id,
    required this.name,
    required this.bead,
    required this.beadDark,
    required this.string,
  });
}

const kBeadThemes = [
  _BeadTheme(
    id: 'jade',
    name: 'زمرد',
    bead: Color(0xFF028544),
    beadDark: Color(0xFF015C2F),
    string: Color(0xFF028544),
  ),
  _BeadTheme(
    id: 'amber',
    name: 'عنبر',
    bead: Color(0xFFB8962E),
    beadDark: Color(0xFF7A620F),
    string: Color(0xFFB8962E),
  ),
  _BeadTheme(
    id: 'turquoise',
    name: 'فيروز',
    bead: Color(0xFF0BA4A0),
    beadDark: Color(0xFF076E6B),
    string: Color(0xFF0BA4A0),
  ),
  _BeadTheme(
    id: 'ruby',
    name: 'ياقوت',
    bead: Color(0xFFB02020),
    beadDark: Color(0xFF7A0F0F),
    string: Color(0xFFB02020),
  ),
  _BeadTheme(
    id: 'pearl',
    name: 'لؤلؤ',
    bead: Color(0xFF8899BB),
    beadDark: Color(0xFF4A5A7A),
    string: Color(0xFF8899BB),
  ),
  _BeadTheme(
    id: 'wood',
    name: 'خشب',
    bead: Color(0xFF8B5E3C),
    beadDark: Color(0xFF5A3D26),
    string: Color(0xFF8B5E3C),
  ),
  _BeadTheme(
    id: 'indigo',
    name: 'نيلي',
    bead: Color(0xFF3F51B5),
    beadDark: Color(0xFF273380),
    string: Color(0xFF3F51B5),
  ),
  _BeadTheme(
    id: 'rose',
    name: 'وردي',
    bead: Color(0xFFB5367A),
    beadDark: Color(0xFF7A1E50),
    string: Color(0xFFB5367A),
  ),
];

// ─── Session ──────────────────────────────────────────────────────────────────
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

// ─── Responsive Config ────────────────────────────────────────────────────────
class _Cfg {
  final double side, width, height;
  _Cfg(BuildContext ctx)
    : side = MediaQuery.of(ctx).size.shortestSide,
      width = MediaQuery.of(ctx).size.width,
      height = MediaQuery.of(ctx).size.height;

  bool get isTablet => side >= 600;
  double get titleFont => (side * 0.058).clamp(18.0, 28.0);
  double get dhikrFont => (side * 0.046).clamp(15.0, 22.0);
  double get labelFont => (side * 0.033).clamp(11.0, 16.0);
  double get cardRadius => isTablet ? 28.0 : 22.0;
  double get hPad => isTablet ? 28.0 : 16.0;
  double get counterSize => (side * 0.22).clamp(72.0, 108.0);
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
  // ── State ──
  int _dhikrIndex = 0;
  int _count = 0;
  bool _completed = false;
  int _beadThemeIdx = 0;
  bool _silentMode = false;

  // Playlist mode
  bool _playlistMode = false;
  List<int> _playlistIndices = [];
  int _playlistPos = 0;

  // Session tracking
  final List<_Session> _sessions = [];
  int _todayTotal = 0;

  // ── Animations ──
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapAnim;
  late final AnimationController _completeCtrl;
  late final Animation<double> _completeAnim;
  late final AnimationController _bgCtrl;
  late final Animation<double> _bgAnim;
  late final AnimationController _tipCtrl;
  late final Animation<double> _tipAnim;

  // ── Getters ──
  int get _effectiveDhikrIndex => _playlistMode && _playlistIndices.isNotEmpty
      ? _playlistIndices[_playlistPos % _playlistIndices.length]
      : _dhikrIndex;
  Map<String, dynamic> get _dhikr => kAllAdhkar[_effectiveDhikrIndex];
  int get _target => _dhikr['count'] as int;
  _BeadTheme get _beadTheme => kBeadThemes[_beadThemeIdx];

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
    if (_silentMode) return;
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

  void _onTap() {
    if (_completed) {
      _haptic(HapticFeedbackType.medium);
      _completeCtrl.reset();
      _tipCtrl.reset();
      _tapCtrl.forward(from: 0);
      // Auto-advance playlist
      if (_playlistMode && _playlistIndices.isNotEmpty) {
        setState(() {
          _playlistPos = (_playlistPos + 1) % _playlistIndices.length;
          _count = 1;
          _completed = false;
        });
      } else {
        setState(() {
          _count = 1;
          _completed = false;
        });
      }
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

  void _setCount(int n) {
    _haptic(HapticFeedbackType.select);
    if (!_completed) {
      // set target by navigating to matching or using custom
      _reset();
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

  void _navigate(int dir) {
    _haptic(HapticFeedbackType.select);
    _completeCtrl.reset();
    _tipCtrl.reset();
    setState(() {
      _dhikrIndex = (_dhikrIndex + dir + kAllAdhkar.length) % kAllAdhkar.length;
      _count = 0;
      _completed = false;
    });
  }

  String _randomTip() {
    final rng = math.Random();
    final tip = kFinishTips[rng.nextInt(kFinishTips.length)];
    return '"${tip['text']!}"\n— ${tip['source']!}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = _Cfg(context);
    final primary = AppColors.getPrimary(context);
    final beadColor = _beadTheme.bead;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF0F8F2),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            _TopBar(
              isDark: isDark,
              cfg: cfg,
              primary: primary,
              silentMode: _silentMode,
              sessionCount: _sessions.length,
              onReset: _reset,
              onNext: () => _navigate(1),
              onSilentToggle: () => setState(() => _silentMode = !_silentMode),
              onSettings: () => _showSettings(context, isDark, cfg, primary),
              onSessionLog: () =>
                  _showSessionLog(context, isDark, cfg, primary),
            ),

            // ── Dhikr Card ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOut),
                      ),
                  child: child,
                ),
              ),
              child: _DhikrCard(
                key: ValueKey(_effectiveDhikrIndex),
                text: _dhikr['text'] as String,
                subtitle: _dhikr['sub'] as String,
                icon: _dhikr['icon'] as String,
                category: _dhikr['cat'] as String,
                target: _target,
                isDark: isDark,
                cfg: cfg,
                primary: primary,
                playlistMode: _playlistMode,
                playlistPos: _playlistMode
                    ? '${_playlistPos + 1}/${_playlistIndices.length}'
                    : null,
                onPrev: () => _navigate(-1),
                onNext: () => _navigate(1),
                onBrowse: () =>
                    _showDhikrBrowser(context, isDark, cfg, primary),
              ),
            ),

            // ── Quick Presets ──
            _QuickPresets(
              primary: primary,
              isDark: isDark,
              cfg: cfg,
              onSelect: (n) =>
                  _showPresetDialog(context, n, isDark, cfg, primary),
            ),

            // ── Tasbih Area ──
            Expanded(
              child: GestureDetector(
                onTap: _onTap,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    // Background
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _bgAnim,
                        builder: (_, __) => CustomPaint(
                          painter: _BgDecorPainter(
                            isDark: isDark,
                            primary: beadColor,
                            progress: _bgAnim.value,
                          ),
                        ),
                      ),
                    ),

                    // Tasbih illustration
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_tapCtrl, _completeCtrl]),
                        builder: (_, _) => RepaintBoundary(
                          child: CustomPaint(
                            painter: _TasbihPainter(
                              count: _count,
                              total: _target,
                              tapProgress: _tapAnim.value,
                              completed: _completed,
                              completeProgress: _completeAnim.value,
                              isDark: isDark,
                              beadTheme: _beadTheme,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Completion tip card
                    if (_completed)
                      Positioned(
                        top: 8,
                        left: cfg.hPad,
                        right: cfg.hPad,
                        child: AnimatedBuilder(
                          animation: _tipAnim,
                          builder: (_, __) => Transform.scale(
                            scale: 0.7 + 0.3 * _tipAnim.value,
                            child: Opacity(
                              opacity: _tipAnim.value.clamp(0.0, 1.0),
                              child: _FinishTipCard(
                                tip: _randomTip(),
                                primary: primary,
                                isDark: isDark,
                                cfg: cfg,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Today's total badge (top-left)
                    Positioned(
                      top: 8,
                      left: 12,
                      child: _TodayBadge(
                        total: _todayTotal,
                        primary: primary,
                        isDark: isDark,
                      ),
                    ),

                    // Counter button
                    Positioned(
                      bottom: cfg.isTablet ? 36 : 22,
                      right: cfg.isTablet ? 44 : 22,
                      child: _CounterButton(
                        count: _count,
                        total: _target,
                        completed: _completed,
                        tapAnim: _tapAnim,
                        completeAnim: _completeAnim,
                        isDark: isDark,
                        cfg: cfg,
                        primary: primary,
                        beadColor: beadColor,
                        onTap: _onTap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sheets ────────────────────────────────────────────────────────────────

  void _showSettings(BuildContext ctx, bool isDark, _Cfg cfg, Color primary) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: cfg.isTablet ? 560.0 : double.infinity,
      ),
      builder: (_) => _SettingsSheet(
        isDark: isDark,
        cfg: cfg,
        primary: primary,
        beadThemeIdx: _beadThemeIdx,
        silentMode: _silentMode,
        playlistMode: _playlistMode,
        playlistIndices: _playlistIndices,
        onBeadTheme: (i) => setState(() => _beadThemeIdx = i),
        onSilent: (v) => setState(() => _silentMode = v),
        onPlaylistChanged: (indices) => setState(() {
          _playlistIndices = indices;
          _playlistMode = indices.isNotEmpty;
          _playlistPos = 0;
          _count = 0;
          _completed = false;
        }),
        onOpenBrowser: () {
          Navigator.pop(ctx);
          _showDhikrBrowser(ctx, isDark, cfg, primary);
        },
      ),
    );
  }

  void _showSessionLog(BuildContext ctx, bool isDark, _Cfg cfg, Color primary) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: cfg.isTablet ? 560.0 : double.infinity,
      ),
      builder: (_) => _SessionLogSheet(
        sessions: _sessions,
        isDark: isDark,
        cfg: cfg,
        primary: primary,
        todayTotal: _todayTotal,
      ),
    );
  }

  void _showDhikrBrowser(
    BuildContext ctx,
    bool isDark,
    _Cfg cfg,
    Color primary,
  ) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: cfg.isTablet ? 620.0 : double.infinity,
      ),
      builder: (_) => _DhikrBrowserSheet(
        isDark: isDark,
        cfg: cfg,
        primary: primary,
        currentIndex: _dhikrIndex,
        onSelect: (i) {
          Navigator.pop(ctx);
          _completeCtrl.reset();
          _tipCtrl.reset();
          setState(() {
            _dhikrIndex = i;
            _count = 0;
            _completed = false;
          });
        },
      ),
    );
  }

  void _showPresetDialog(
    BuildContext ctx,
    int? preset,
    bool isDark,
    _Cfg cfg,
    Color primary,
  ) {
    // Just navigate to the closest dhikr with that count
    if (preset == null) {
      // Custom — show text input
      return;
    }
    // Find first dhikr with this count
    final idx = kAllAdhkar.indexWhere((d) => d['count'] == preset);
    if (idx >= 0) {
      _completeCtrl.reset();
      _tipCtrl.reset();
      setState(() {
        _dhikrIndex = idx;
        _count = 0;
        _completed = false;
      });
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS
// ════════════════════════════════════════════════════════════════════════════

// ─── Top Bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool isDark, silentMode;
  final int sessionCount;
  final _Cfg cfg;
  final Color primary;
  final VoidCallback onReset, onNext, onSilentToggle, onSettings, onSessionLog;

  const _TopBar({
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.silentMode,
    required this.sessionCount,
    required this.onReset,
    required this.onNext,
    required this.onSilentToggle,
    required this.onSettings,
    required this.onSessionLog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Reset
          _TinyBtn(
            icon: Icons.refresh_rounded,
            onTap: onReset,
            primary: primary,
          ),
          const SizedBox(width: 4),
          // Silent mode
          _TinyBtn(
            icon: silentMode
                ? Icons.vibration_rounded
                : Icons.notifications_rounded,
            onTap: onSilentToggle,
            primary: primary,
            active: silentMode,
          ),
          // Title
          Expanded(
            child: Text(
              'التسبيح',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: cfg.titleFont,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Session log
          _TinyBtn(
            icon: Icons.history_rounded,
            onTap: onSessionLog,
            primary: primary,
            badge: sessionCount > 0 ? '$sessionCount' : null,
          ),
          const SizedBox(width: 4),
          // Settings
          _TinyBtn(
            icon: Icons.tune_rounded,
            onTap: onSettings,
            primary: primary,
          ),
        ],
      ),
    );
  }
}

class _TinyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primary;
  final bool active;
  final String? badge;
  const _TinyBtn({
    required this.icon,
    required this.onTap,
    required this.primary,
    this.active = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                  ? primary.withValues(alpha: 0.2)
                  : primary.withValues(alpha: 0.08),
              border: Border.all(
                color: primary.withValues(alpha: active ? 0.4 : 0.15),
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
}

// ─── Dhikr Card ───────────────────────────────────────────────────────────────
class _DhikrCard extends StatelessWidget {
  final String text, subtitle, icon, category;
  final int target;
  final bool isDark;
  final _Cfg cfg;
  final Color primary;
  final bool playlistMode;
  final String? playlistPos;
  final VoidCallback onPrev, onNext, onBrowse;

  const _DhikrCard({
    super.key,
    required this.text,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.target,
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.playlistMode,
    required this.playlistPos,
    required this.onPrev,
    required this.onNext,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: cfg.hPad, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundCardDark : AppColors.white,
        borderRadius: BorderRadius.circular(cfg.cardRadius),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.14 : 0.07),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header bar
          GestureDetector(
            onTap: onBrowse,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cfg.cardRadius),
                ),
              ),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      category,
                      style: GoogleFonts.amiri(
                        fontSize: cfg.labelFont,
                        color: isDark
                            ? AppColors.textPrimaryDark.withValues(alpha: 0.75)
                            : primary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (playlistMode && playlistPos != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.playlist_play_rounded,
                            color: primary,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            playlistPos!,
                            style: TextStyle(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Icon(
                    Icons.search_rounded,
                    color: primary.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Dhikr text
          Padding(
            padding: EdgeInsets.fromLTRB(cfg.hPad, 12, cfg.hPad, 8),
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiriQuran(
                fontSize: cfg.dhikrFont,
                height: 1.9,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: cfg.labelFont - 1,
                color: isDark
                    ? AppColors.textPrimaryDark.withValues(alpha: 0.55)
                    : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Nav row
          Padding(
            padding: EdgeInsets.fromLTRB(cfg.hPad, 8, cfg.hPad, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavBtn(
                  icon: Icons.chevron_right_rounded,
                  onTap: onPrev,
                  primary: primary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: primary.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    '$target مرة',
                    style: GoogleFonts.amiri(
                      fontSize: cfg.labelFont + 1,
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _NavBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: onNext,
                  primary: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primary;
  const _NavBtn({
    required this.icon,
    required this.onTap,
    required this.primary,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.07),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Icon(icon, color: primary, size: 22),
    ),
  );
}

// ─── Quick Presets ────────────────────────────────────────────────────────────
class _QuickPresets extends StatelessWidget {
  final Color primary;
  final bool isDark;
  final _Cfg cfg;
  final void Function(int? count) onSelect;
  const _QuickPresets({
    required this.primary,
    required this.isDark,
    required this.cfg,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: cfg.hPad, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'سريع:',
            style: GoogleFonts.amiri(
              fontSize: cfg.labelFont,
              color: isDark
                  ? AppColors.textPrimaryDark.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          for (final n in [3, 33, 34, 100])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onSelect(n),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primary.withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    '×$n',
                    style: GoogleFonts.amiri(
                      fontSize: cfg.labelFont,
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 3),
          GestureDetector(
            onTap: () => onSelect(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withValues(alpha: 0.12)),
              ),
              child: Icon(Icons.add_rounded, size: 16, color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Counter Button ───────────────────────────────────────────────────────────
class _CounterButton extends StatelessWidget {
  final int count, total;
  final bool completed;
  final Animation<double> tapAnim, completeAnim;
  final bool isDark;
  final _Cfg cfg;
  final Color primary, beadColor;
  final VoidCallback onTap;

  const _CounterButton({
    required this.count,
    required this.total,
    required this.completed,
    required this.tapAnim,
    required this.completeAnim,
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.beadColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sz = cfg.counterSize;
    return AnimatedBuilder(
      animation: Listenable.merge([tapAnim, completeAnim]),
      builder: (_, __) {
        final scale = completed
            ? (0.88 + 0.18 * completeAnim.value)
            : (1.0 + 0.07 * tapAnim.value);
        final btnColor = completed ? AppColors.success : beadColor;
        final progress = total > 0 ? count / total : 0.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: sz,
              height: sz,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: completed
                      ? [AppColors.success, const Color(0xFF00B864)]
                      : [btnColor, Color.lerp(btnColor, Colors.white, 0.2)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: btnColor.withValues(alpha: 0.5),
                    blurRadius: 22,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress arc
                  CustomPaint(
                    size: Size(sz, sz),
                    painter: _ArcPainter(
                      progress: progress,
                      color: AppColors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        completed
                            ? Icons.check_circle_rounded
                            : Icons.touch_app_rounded,
                        color: AppColors.white,
                        size: sz * 0.28,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        completed ? 'اكتمل' : '$count/$total',
                        style: GoogleFonts.amiri(
                          color: AppColors.white,
                          fontSize: sz * 0.17,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Today Badge ──────────────────────────────────────────────────────────────
class _TodayBadge extends StatelessWidget {
  final int total;
  final Color primary;
  final bool isDark;
  const _TodayBadge({
    required this.total,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    return AnimatedOpacity(
      opacity: total > 0 ? 0.9 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 12, color: primary),
            const SizedBox(width: 4),
            Text(
              '$total : تسبيحة الأن',
              style: GoogleFonts.amiri(
                fontSize: 11,
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Finish Tip Card ──────────────────────────────────────────────────────────
class _FinishTipCard extends StatelessWidget {
  final String tip;
  final Color primary;
  final bool isDark;
  final _Cfg cfg;
  const _FinishTipCard({
    required this.tip,
    required this.primary,
    required this.isDark,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, Color.lerp(primary, AppColors.success, 0.4)!],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
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
                'اكتمل التسبيح 🎉',
                style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 14),
          Text(
            tip,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: cfg.labelFont,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Sheet ───────────────────────────────────────────────────────────
class _SettingsSheet extends StatefulWidget {
  final bool isDark, silentMode, playlistMode;
  final _Cfg cfg;
  final Color primary;
  final int beadThemeIdx;
  final List<int> playlistIndices;
  final void Function(int) onBeadTheme;
  final void Function(bool) onSilent;
  final void Function(List<int>) onPlaylistChanged;
  final VoidCallback onOpenBrowser;

  const _SettingsSheet({
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.beadThemeIdx,
    required this.silentMode,
    required this.playlistMode,
    required this.playlistIndices,
    required this.onBeadTheme,
    required this.onSilent,
    required this.onPlaylistChanged,
    required this.onOpenBrowser,
  });

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _selectedTheme;
  late bool _silentMode;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.beadThemeIdx;
    _silentMode = widget.silentMode;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.backgroundCardDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: widget.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(primary: widget.primary),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'الإعدادات',
              style: GoogleFonts.amiri(
                fontSize: widget.cfg.titleFont,
                color: widget.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(height: 1, color: widget.primary.withValues(alpha: 0.15)),
          const SizedBox(height: 16),

          // Bead themes
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'خامة الخرز',
              style: GoogleFonts.amiri(
                fontSize: widget.cfg.labelFont + 2,
                color: widget.isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kBeadThemes.asMap().entries.map((e) {
              final selected = e.key == _selectedTheme;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTheme = e.key);
                  widget.onBeadTheme(e.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? e.value.bead.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? e.value.bead
                          : e.value.bead.withValues(alpha: 0.3),
                      width: selected ? 2 : 1,
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
                      const SizedBox(width: 6),
                      Text(
                        e.value.name,
                        style: GoogleFonts.amiri(
                          fontSize: widget.cfg.labelFont,
                          color: selected
                              ? e.value.bead
                              : (widget.isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          // Silent mode toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.vibration_rounded, color: widget.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وضع الصمت',
                        style: GoogleFonts.amiri(
                          fontSize: widget.cfg.labelFont + 1,
                          color: widget.isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'اهتزازات فقط بدون صوت',
                        style: GoogleFonts.amiri(
                          fontSize: widget.cfg.labelFont - 1,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _silentMode,
                  activeColor: widget.primary,
                  onChanged: (v) {
                    setState(() => _silentMode = v);
                    widget.onSilent(v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Playlist
          GestureDetector(
            onTap: widget.onOpenBrowser,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.playlist_add_rounded,
                    color: widget.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قائمة الأذكار',
                          style: GoogleFonts.amiri(
                            fontSize: widget.cfg.labelFont + 1,
                            color: widget.isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'اختر أذكاراً متتالية (${widget.playlistIndices.length} محدد)',
                          style: GoogleFonts.amiri(
                            fontSize: widget.cfg.labelFont - 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: widget.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Session Log Sheet ────────────────────────────────────────────────────────
class _SessionLogSheet extends StatelessWidget {
  final List<_Session> sessions;
  final bool isDark;
  final _Cfg cfg;
  final Color primary;
  final int todayTotal;

  const _SessionLogSheet({
    required this.sessions,
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.todayTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundCardDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(primary: primary),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'سجل الجلسة',
                  style: GoogleFonts.amiri(
                    fontSize: cfg.titleFont * 0.85,
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Total row
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, color: primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'المجموع للجلسة: $todayTotal تسبيحة',
                  style: GoogleFonts.amiri(
                    fontSize: cfg.labelFont + 2,
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'لا توجد جلسات بعد، ابدأ التسبيح!',
                style: GoogleFonts.amiri(
                  fontSize: cfg.labelFont + 1,
                  color: isDark
                      ? AppColors.textPrimaryDark.withValues(alpha: 0.5)
                      : AppColors.textSecondary,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: sessions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: primary.withValues(alpha: 0.08)),
                itemBuilder: (_, i) {
                  final s = sessions[sessions.length - 1 - i]; // newest first
                  final timeStr =
                      '${s.time.hour.toString().padLeft(2, '0')}:${s.time.minute.toString().padLeft(2, '0')}';
                  return ListTile(
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
                      style: GoogleFonts.amiriQuran(
                        fontSize: cfg.labelFont + 1,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${s.count} مرة',
                      style: GoogleFonts.amiri(
                        fontSize: cfg.labelFont,
                        color: primary,
                      ),
                    ),
                    trailing: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Dhikr Browser Sheet ──────────────────────────────────────────────────────
class _DhikrBrowserSheet extends StatefulWidget {
  final bool isDark;
  final _Cfg cfg;
  final Color primary;
  final int currentIndex;
  final void Function(int) onSelect;

  const _DhikrBrowserSheet({
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  State<_DhikrBrowserSheet> createState() => _DhikrBrowserSheetState();
}

class _DhikrBrowserSheetState extends State<_DhikrBrowserSheet> {
  String _filter = '';
  final _cats = <String>{};

  @override
  void initState() {
    super.initState();
    _cats.addAll(kAllAdhkar.map((d) => d['cat'] as String));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kAllAdhkar.asMap().entries.where((e) {
      final d = e.value;
      return _filter.isEmpty ||
          (d['text'] as String).contains(_filter) ||
          (d['cat'] as String).contains(_filter);
    }).toList();

    // Group by category
    final bycat = <String, List<MapEntry<int, Map<String, dynamic>>>>{};
    for (final e in filtered) {
      final cat = e.value['cat'] as String;
      bycat.putIfAbsent(cat, () => []).add(e);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.backgroundCardDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: widget.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(primary: widget.primary),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'اختر الذِكر',
              style: GoogleFonts.amiri(
                fontSize: widget.cfg.titleFont * 0.85,
                color: widget.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Search
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: widget.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.primary.withValues(alpha: 0.12)),
            ),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن ذِكر...',
                hintStyle: GoogleFonts.amiri(color: AppColors.textSecondary),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: widget.primary,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: GoogleFonts.amiri(
                fontSize: 14,
                color: widget.isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: bycat.entries
                  .map(
                    (cat) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Text(
                            cat.key,
                            style: GoogleFonts.amiri(
                              fontSize: widget.cfg.labelFont + 1,
                              color: widget.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...cat.value.map((e) {
                          final isSelected = e.key == widget.currentIndex;
                          return GestureDetector(
                            onTap: () => widget.onSelect(e.key),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.primary.withValues(alpha: 0.12)
                                    : widget.primary.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.primary.withValues(
                                    alpha: isSelected ? 0.35 : 0.08,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    e.value['icon'] as String,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e.value['text'] as String,
                                      textDirection: TextDirection.rtl,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.amiriQuran(
                                        fontSize: widget.cfg.labelFont + 2,
                                        color: widget.isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${e.value['count']}×',
                                      style: GoogleFonts.amiri(
                                        fontSize: 11,
                                        color: widget.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        Divider(
                          height: 8,
                          color: widget.primary.withValues(alpha: 0.08),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
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
      color: primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// PAINTERS
// ════════════════════════════════════════════════════════════════════════════

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.progress != progress;
}

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
    final a = isDark ? 0.04 : 0.05;
    final p = Paint()
      ..color = primary.withValues(alpha: a)
      ..style = PaintingStyle.fill;
    final f = 8.0 * progress;
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.22 + f), 42, p);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.17 - f), 28, p);
    canvas.drawCircle(
      Offset(size.width * 0.07, size.height * 0.76 - f * 0.5),
      20,
      p,
    );
    canvas.drawCircle(
      Offset(size.width * 0.93, size.height * 0.62 + f * 0.7),
      32,
      p,
    );

    final lp = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.05 : 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (int i = -4; i < 8; i++) {
      final x = i * 60.0;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), lp);
    }
  }

  @override
  bool shouldRepaint(covariant _BgDecorPainter old) =>
      old.progress != progress ||
      old.isDark != isDark ||
      old.primary != primary;
}

// ─── Main Tasbih Painter ──────────────────────────────────────────────────────
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

  Offset _center(Size s) => Offset(s.width * 0.5, s.height * 0.60);
  double _rx(Size s) => s.width * 0.255;
  double _ry(Size s) => s.height * 0.285;

  Offset _pos(Size s, int i) {
    final c = _center(s);
    final a = -math.pi / 2 + (i / _N) * 2 * math.pi;
    return Offset(c.dx + _rx(s) * math.cos(a), c.dy + _ry(s) * math.sin(a));
  }

  double _depth(int i) {
    final a = -math.pi / 2 + (i / _N) * 2 * math.pi;
    return (math.sin(a) + 1) / 2;
  }

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
    for (int i = 0; i < _N; i++) {
      final p1 = _pos(size, i);
      final p2 = _pos(size, (i + 1) % _N);
      final used = i < vc;
      final d = _depth(i);
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = beadTheme.string.withValues(
            alpha: used ? (0.55 + 0.35 * d) : (0.1 + 0.1 * d),
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
      final pos = _pos(size, i);
      final used = i < vc;
      final active = i == vc - 1 && count > 0 && !completed;
      final sep = i == 0 || i == 11 || i == 22;
      final d = _depth(i);
      double r = sep ? 10.5 : 8.0;
      r *= (0.82 + 0.28 * d);
      if (active) r += 3.8 * tapProgress;
      _drawBead(canvas, pos, r, used, active, i, d);
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
    if (used && depth > 0.2) {
      canvas.drawCircle(
        pos + Offset(-r * 0.26, -r * 0.28),
        r * (0.17 + 0.06 * depth),
        Paint()..color = Colors.white.withValues(alpha: 0.5 + 0.35 * depth),
      );
    }
    if (used && depth > 0.4) {
      canvas.drawLine(
        pos + Offset(-r * 0.55, -r * 0.80),
        pos + Offset(-r * 0.22, -r * 0.32),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18 * depth)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }
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
    for (final dx in [-18.0, 18.0]) {
      canvas.drawLine(
        top + Offset(dx, 8),
        top,
        Paint()
          ..color = beadTheme.string.withValues(alpha: 0.6)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }
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
    for (int k = 0; k < 5; k++) {
      canvas.drawLine(
        Offset(top.dx - cW * 0.3, top.dy - 6 - k * 7),
        Offset(top.dx + cW * 0.3, top.dy - 9 - k * 7),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

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
        ..color = isDark ? AppColors.backgroundDark : const Color(0xFFF0F8F2),
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
    for (int i = -3; i <= 3; i++) {
      final w = i % 2 == 0 ? 2.0 : 0.0;
      canvas.drawLine(
        Offset(tTop.dx + i * 4.5, tTop.dy),
        Offset(tTop.dx + i * 5.2 + w, tTop.dy + 36),
        Paint()
          ..color = beadTheme.string.withValues(
            alpha: 0.6 + 0.15 * (i.abs() / 3),
          )
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round,
      );
    }
    final tbc = Offset(tTop.dx, tTop.dy + 36 + 7);
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
    final c = _center(size);
    canvas.drawCircle(
      c,
      math.min(_rx(size), _ry(size)) * 1.4 * completeProgress,
      Paint()
        ..color = beadTheme.bead.withValues(alpha: 0.08 * completeProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );
  }

  @override
  bool shouldRepaint(covariant _TasbihPainter old) =>
      old.count != count ||
      old.tapProgress != tapProgress ||
      old.completed != completed ||
      old.completeProgress != completeProgress ||
      old.isDark != isDark ||
      old.beadTheme.id != beadTheme.id;
}

// ─── Haptic helper ────────────────────────────────────────────────────────────
enum HapticFeedbackType { light, medium, heavy, select }
