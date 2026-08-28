// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 180,
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
                  'السياسات والأحكام',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF1A1F6B)],
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.gavel_rounded,
                        size: 150,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  unselectedLabelColor: Colors.grey,
                  labelColor: AppColors.primary,
                  indicatorColor: AppColors.secondary,
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  tabs: const [
                    Tab(text: 'شروط الاستخدام'),
                    Tab(text: 'سياسة الخصوصية'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildContentSection(_termsOfUse),
              _buildContentSection(_privacyPolicy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(List<_PolicySection> sections) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      section.icon ?? Icons.description_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      section.title,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),
              Text(
                section.content,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static final List<_PolicySection> _termsOfUse = [
    _PolicySection(
      title: '1. مقدمة',
      icon: Icons.info_outline_rounded,
      content:
          'مرحباً بك في تطبيق "الخطيب". باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بالشروط والأحكام التالية. يرجى قراءتها بعناية.',
    ),
    _PolicySection(
      title: '2. حساب المستخدم',
      icon: Icons.account_circle_outlined,
      content:
          'يجب أن تكون المعلومات المقدمة عند إنشاء الحساب دقيقة وكاملة. أنت مسؤول عن الحفاظ على سرية معلومات حسابك وكلمة المرور.',
    ),
    _PolicySection(
      title: '3. الطلبات والأسعار',
      icon: Icons.shopping_basket_outlined,
      content:
          'نحن نبذل قصارى جهدنا لضمان دقة الأسعار والمنتجات. يتم تأكيد الطلبات بناءً على توفر المنتج في المتجر وقت الطلب.',
    ),
    _PolicySection(
      title: '4. التوصيل',
      icon: Icons.local_shipping_outlined,
      content:
          'نسعى لتوصيل طلباتكم في أسرع وقت ممكن. قد تختلف أوقات التوصيل بناءً على ضغط العمل والظروف الجوية وموقع التوصيل.',
    ),
  ];

  static final List<_PolicySection> _privacyPolicy = [
    _PolicySection(
      title: '1. جمع البيانات',
      icon: Icons.data_usage_rounded,
      content:
          'نقوم بجمع المعلومات التي تقدمها لنا، مثل الاسم ورقم الهاتف والعنوان، وذلك لتقديم خدمات التوصيل وتحسين تجربتك في التطبيق.',
    ),
    _PolicySection(
      title: '2. استخدام المعلومات',
      icon: Icons.insights_rounded,
      content:
          'نستخدم بياناتك لتأكيد الطلبات، وتجهيز عمليات التوصيل، وإرسال إشعارات العروض والتحديثات الهامة المتعلقة بحسابك.',
    ),
    _PolicySection(
      title: '3. حماية البيانات',
      icon: Icons.security_rounded,
      content:
          'نحن نتخذ كافة الإجراءات الأمنية اللازمة لحماية بياناتك الشخصية من الوصول غير المصرح به أو التعديل أو الإفصاح.',
    ),
    _PolicySection(
      title: '4. مشاركة البيانات',
      icon: Icons.share_location_rounded,
      content:
          'لا نقوم ببيع بياناتك الشخصية لأي طرف ثالث. تتم مشاركة بيانات العنوان ورقم الهاتف فقط مع فريق التوصيل لإتمام طلبك.',
    ),
  ];
}

class _PolicySection {
  final String title;
  final String content;
  final IconData? icon;

  _PolicySection({required this.title, required this.content, this.icon});
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
