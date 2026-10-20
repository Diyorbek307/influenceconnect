import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../data/constants.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';

/// Редактирование профиля текущего пользователя (бренд или блогер).
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _location;
  late final TextEditingController _followers;
  late final TextEditingController _engagement;
  late String _category;
  late String _platform;
  bool _loading = false;

  bool get _isBlogger => AppRepository.instance.currentUser!.isBlogger;

  @override
  void initState() {
    super.initState();
    final u = AppRepository.instance.currentUser!;
    _name = TextEditingController(text: u.name);
    _bio = TextEditingController(text: u.bio);
    _location = TextEditingController(text: u.location);
    _followers = TextEditingController(text: u.followers > 0 ? u.followers.toString() : '');
    _engagement =
        TextEditingController(text: u.engagement > 0 ? u.engagement.toString() : '');
    _category = AppConst.categories.contains(u.category)
        ? u.category
        : AppConst.categories.first;
    _platform = AppConst.platforms.contains(u.platform)
        ? u.platform
        : AppConst.platforms.first;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppRepository.instance.updateCurrentProfile(
        name: _name.text.trim(),
        bio: _bio.text.trim(),
        location: _location.text.trim(),
        category: _category,
        platform: _isBlogger ? _platform : '',
        followers: _isBlogger ? (int.tryParse(_followers.text.trim()) ?? 0) : 0,
        engagement:
            _isBlogger ? (double.tryParse(_engagement.text.trim()) ?? 0) : 0,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, tr('saved'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _location.dispose();
    _followers.dispose();
    _engagement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('edit_profile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText:
                        _isBlogger ? tr('field_name_blogger') : tr('field_name_brand'),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr('val_name') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bio,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: tr('about_me'),
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.info_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _location,
                  decoration: InputDecoration(
                    labelText: tr('city'),
                    prefixIcon: const Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _isBlogger ? tr('field_niche') : tr('field_industry'),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: AppConst.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                if (_isBlogger) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _platform,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: tr('field_platform'),
                      prefixIcon: const Icon(Icons.public_rounded),
                    ),
                    items: AppConst.platforms
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _platform = v ?? _platform),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _followers,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr('field_followers'),
                      prefixIcon: const Icon(Icons.people_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _engagement,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: tr('field_engagement'),
                      prefixIcon: const Icon(Icons.favorite_outline_rounded),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                GradientButton(
                  label: tr('save'),
                  icon: Icons.save_rounded,
                  loading: _loading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
