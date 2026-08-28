// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/colors.dart';
import '../../../core/api/dio_consumer.dart';

// ════════════════════════════════════════════════
// MODEL
// ════════════════════════════════════════════════
class ContactLinks {
  final String? whatsapp;
  final String? phone;
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? tiktok;
  final String? website;

  ContactLinks({
    this.whatsapp,
    this.phone,
    this.facebook,
    this.instagram,
    this.twitter,
    this.tiktok,
    this.website,
  });

  factory ContactLinks.fromJson(Map<String, dynamic> json) {
    return ContactLinks(
      whatsapp: _nullable(json['whatsapp']),
      phone: _nullable(json['phone']),
      facebook: _nullable(json['facebook']),
      instagram: _nullable(json['instagram']),
      twitter: _nullable(json['twitter']),
      tiktok: _nullable(json['tiktok']),
      website: _nullable(json['website']),
    );
  }

  static String? _nullable(dynamic v) {
    if (v == null || v.toString().trim().isEmpty) return null;
    return v.toString().trim();
  }
}

// ════════════════════════════════════════════════
// STATE
// ════════════════════════════════════════════════
class HelpCenterState {
  final bool isLoading;
  final ContactLinks? links;
  final String? error;
  final bool isSending;
  final String? sendSuccess;
  final String? sendError;

  const HelpCenterState({
    this.isLoading = false,
    this.links,
    this.error,
    this.isSending = false,
    this.sendSuccess,
    this.sendError,
  });

  HelpCenterState copyWith({
    bool? isLoading,
    ContactLinks? links,
    String? error,
    bool? isSending,
    String? sendSuccess,
    String? sendError,
    bool clearSendResult = false,
  }) {
    return HelpCenterState(
      isLoading: isLoading ?? this.isLoading,
      links: links ?? this.links,
      error: error ?? this.error,
      isSending: isSending ?? this.isSending,
      sendSuccess: clearSendResult ? null : (sendSuccess ?? this.sendSuccess),
      sendError: clearSendResult ? null : (sendError ?? this.sendError),
    );
  }
}

// ════════════════════════════════════════════════
// CUBIT
// ════════════════════════════════════════════════
class HelpCenterCubit extends Cubit<HelpCenterState> {
  final DioConsumer _api = DioConsumer(dio: Dio());

  HelpCenterCubit() : super(const HelpCenterState()) {
    loadContactLinks();
  }

  Future<void> loadContactLinks() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final res = await _api.get('system/contact-links');
      final links = ContactLinks.fromJson(res['links'] as Map<String, dynamic>);
      emit(state.copyWith(isLoading: false, links: links));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> sendComplaint({
    required String name,
    required String phone,
    required String message,
  }) async {
    emit(state.copyWith(isSending: true, clearSendResult: true));
    try {
      final res = await _api.post(
        'system/support',
        data: {'name': name, 'phone': phone, 'message': message},
      );
      emit(
        state.copyWith(
          isSending: false,
          sendSuccess: res['message'] ?? 'تم إرسال شكواك بنجاح',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isSending: false, sendError: 'حدث خطأ، حاول مرة أخرى'),
      );
    }
  }
}

// ════════════════════════════════════════════════
// SCREEN
// ════════════════════════════════════════════════
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HelpCenterCubit(),
      child: const _HelpCenterView(),
    );
  }
}

class _HelpCenterView extends StatelessWidget {
  const _HelpCenterView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: CustomScrollView(
        slivers: [
          // Premium Gradient AppBar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'مركز المساعدة',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [AppColors.primary, Color(0xFF4A00E0)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.support_agent_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 60,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'كيف يمكننا مساعدتك اليوم؟',
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top FAQs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'الأسئلة الشائعة',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _FAQItem(
                    question: 'كيف يمكنني تتبع طلبي؟',
                    answer:
                        'يمكنك تتبع طلبك من خلال الذهاب إلى قسم "طلباتي" في الملف الشخصي واختيار الطلب المراد تتبعه لرؤية حالته الحالية.',
                  ),
                  const _FAQItem(
                    question: 'ما هي طرق الدفع المتاحة؟',
                    answer:
                        'نوفر حالياً خيار الدفع عند الاستلام، وسنقوم قريباً بتوفير خيارات الدفع الإلكتروني عبر البطاقات الائتمانية والمحافظ الإلكترونية.',
                  ),
                  const _FAQItem(
                    question: 'كم يستغرق وقت التوصيل؟',
                    answer:
                        'يستغرق التوصيل عادةً من 30 إلى 60 دقيقة حسب موقعك وحجم الطلب والظروف الجوية.',
                  ),
                ],
              ),
            ),
          ),

          // Contact Section (dynamic from backend)
          SliverToBoxAdapter(
            child: BlocBuilder<HelpCenterCubit, HelpCenterState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تواصل مباشرة مع الدعم',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.error != null)
                        _buildStaticContactCards()
                      else if (state.links != null)
                        _buildDynamicContactCards(state.links!)
                      else
                        _buildStaticContactCards(),
                    ],
                  ),
                );
              },
            ),
          ),

          // Complaint Form Section
          const SliverToBoxAdapter(child: _ComplaintSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildDynamicContactCards(ContactLinks links) {
    final List<_ContactInfo> cards = [];

    if (links.whatsapp != null) {
      cards.add(
        _ContactInfo(
          icon: FontAwesomeIcons.whatsapp,
          title: 'واتساب',
          subtitle: 'محادثة فورية',
          color: const Color(0xFF25D366),
          url:
              'https://wa.me/${links.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}',
        ),
      );
    }
    if (links.phone != null) {
      cards.add(
        _ContactInfo(
          icon: FontAwesomeIcons.phone,
          title: 'اتصال هاتفي',
          subtitle: links.phone!,
          color: const Color(0xFF3498DB),
          url: 'tel:${links.phone}',
        ),
      );
    }
    if (links.facebook != null) {
      cards.add(
        _ContactInfo(
          icon: FontAwesomeIcons.facebook,
          title: 'فيسبوك',
          subtitle: 'تابعنا',
          color: const Color(0xFF1877F2),
          url: links.facebook!,
        ),
      );
    }
    if (links.instagram != null) {
      cards.add(
        _ContactInfo(
          icon: FontAwesomeIcons.instagram,
          title: 'انستغرام',
          subtitle: 'تابعنا',
          color: const Color(0xFFE4405F),
          url: links.instagram!,
        ),
      );
    }
    if (links.tiktok != null) {
      cards.add(
        _ContactInfo(
          icon: FontAwesomeIcons.tiktok,
          title: 'تيك توك',
          subtitle: 'تابعنا',
          color: const Color(0xFF010101),
          url: links.tiktok!,
        ),
      );
    }
    if (links.website != null) {
      cards.add(
        _ContactInfo(
          icon: FontAwesomeIcons.globe,
          title: 'موقعنا',
          subtitle: 'زيارة الموقع',
          color: const Color(0xFFF39C12),
          url: links.website!,
        ),
      );
    }

    if (cards.isEmpty) return _buildStaticContactCards();

    return _buildCardsGrid(cards);
  }

  Widget _buildStaticContactCards() {
    final cards = [
      _ContactInfo(
        icon: FontAwesomeIcons.whatsapp,
        title: 'واتساب',
        subtitle: 'محادثة فورية',
        color: const Color(0xFF25D366),
      ),
      _ContactInfo(
        icon: FontAwesomeIcons.phone,
        title: 'اتصال هاتفي',
        subtitle: 'متاح 24 ساعة',
        color: const Color(0xFF3498DB),
      ),
      _ContactInfo(
        icon: FontAwesomeIcons.envelope,
        title: 'البريد',
        subtitle: 'رد خلال 24 ساعة',
        color: const Color(0xFFE74C3C),
      ),
      _ContactInfo(
        icon: FontAwesomeIcons.mapLocationDot,
        title: 'موقعنا',
        subtitle: 'فروعنا في الأردن',
        color: const Color(0xFFF39C12),
      ),
    ];
    return _buildCardsGrid(cards);
  }

  Widget _buildCardsGrid(List<_ContactInfo> cards) {
    final rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      final left = cards[i];
      final right = i + 1 < cards.length ? cards[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _ContactCard(info: left)),
            const SizedBox(width: 16),
            Expanded(
              child: right != null
                  ? _ContactCard(info: right)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }
}

// ─────────────────────────────────────────────
// Complaint Section
// ─────────────────────────────────────────────
class _ComplaintSection extends StatefulWidget {
  const _ComplaintSection();

  @override
  State<_ComplaintSection> createState() => _ComplaintSectionState();
}

class _ComplaintSectionState extends State<_ComplaintSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<HelpCenterCubit>().sendComplaint(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      message: _msgCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpCenterCubit, HelpCenterState>(
      listenWhen: (p, c) => c.sendSuccess != null || c.sendError != null,
      listener: (context, state) {
        if (state.sendSuccess != null) {
          _nameCtrl.clear();
          _phoneCtrl.clear();
          _msgCtrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.sendSuccess!, style: GoogleFonts.tajawal()),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state.sendError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.sendError!, style: GoogleFonts.tajawal()),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.commentDots,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'أرسل شكوى أو استفسار',
                          style: GoogleFonts.tajawal(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _nameCtrl,
                      label: 'الاسم الكريم',
                      icon: Icons.person_outline_rounded,
                      hint: 'اكتب اسمك',
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _phoneCtrl,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_outlined,
                      hint: '07xxxxxxxx',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 14),
                    _buildField(
                      controller: _msgCtrl,
                      label: 'الرسالة',
                      icon: Icons.message_outlined,
                      hint: 'اكتب مشكلتك أو استفسارك بالتفصيل...',
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'الرسالة مطلوبة'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state.isSending
                            ? null
                            : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary
                              .withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: state.isSending
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send_rounded, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'إرسال الشكوى',
                                    style: GoogleFonts.tajawal(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textAlign: TextAlign.right,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.tajawal(color: Colors.black, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: const Color(0xFFF7F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class UrlHelper {
  static Uri parse(String url) {
    final trimmed = url.trim().toLowerCase();

    if (trimmed.startsWith('tel:') ||
        trimmed.startsWith('mailto:') ||
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://')) {
      return Uri.parse(trimmed);
    }

    // Default to https for everything else
    return Uri.parse('https://$trimmed');
  }

  static Future<void> open(String? url) async {
    if (url == null || url.trim().isEmpty) return;

    try {
      final uri = parse(url);
      
      // Use externalApplication to force opening the app (if installed) or browser
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error launching URL ($url): $e');
    }
  }
}

class ContactBuilder {
  static List<_ContactInfo> build(ContactLinks links) {
    return [
      if (links.whatsapp != null)
        _ContactInfo(
          icon: FontAwesomeIcons.whatsapp,
          title: 'واتساب',
          subtitle: 'محادثة فورية',
          color: const Color(0xFF25D366),
          url: 'https://wa.me/${_normalizePhone(links.whatsapp!)}',
        ),

      if (links.phone != null)
        _ContactInfo(
          icon: FontAwesomeIcons.phone,
          title: 'اتصال هاتفي',
          subtitle: links.phone!,
          color: const Color(0xFF3498DB),
          url: 'tel:${links.phone}',
        ),

      if (links.facebook != null)
        _ContactInfo(
          icon: FontAwesomeIcons.facebook,
          title: 'فيسبوك',
          subtitle: 'تابعنا',
          color: const Color(0xFF1877F2),
          url: links.facebook!,
        ),

      if (links.instagram != null)
        _ContactInfo(
          icon: FontAwesomeIcons.instagram,
          title: 'انستغرام',
          subtitle: 'تابعنا',
          color: const Color(0xFFE4405F),
          url: links.instagram!,
        ),

      if (links.tiktok != null)
        _ContactInfo(
          icon: FontAwesomeIcons.tiktok,
          title: 'تيك توك',
          subtitle: 'تابعنا',
          color: const Color(0xFF010101),
          url: links.tiktok!,
        ),

      if (links.website != null)
        _ContactInfo(
          icon: FontAwesomeIcons.globe,
          title: 'موقعنا',
          subtitle: 'زيارة الموقع',
          color: const Color(0xFFF39C12),
          url: links.website!,
        ),
    ];
  }

  static String _normalizePhone(String input) {
    String clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    // Support Jordan normalization if needed (already handled by backend but helpful here too)
    if (clean.startsWith('0') && clean.length == 10) {
      clean = '962' + clean.substring(1);
    }
    return clean;
  }
}

// ─────────────────────────────────────────────
// Contact Info data class
// ─────────────────────────────────────────────
class _ContactInfo {
  final FaIconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? url;

  _ContactInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.url,
  });
}

// ─────────────────────────────────────────────
// Contact Card
// ─────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final _ContactInfo info;

  const _ContactCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => UrlHelper.open(info.url),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: info.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(info.icon, color: info.color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              info.title,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              info.subtitle,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FAQ Item (unchanged logic, same premium style)
// ─────────────────────────────────────────────
class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? AppColors.primary.withOpacity(0.3)
              : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          if (_isExpanded)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          title: Text(
            widget.question,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _isExpanded ? AppColors.primary : Colors.black87,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isExpanded ? Icons.remove : Icons.add,
              size: 18,
              color: _isExpanded ? AppColors.primary : Colors.grey,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                widget.answer,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
