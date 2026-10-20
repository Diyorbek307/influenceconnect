import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../data/constants.dart';
import '../../l10n/l10n.dart';
import '../../models/campaign.dart';
import '../../widgets/common.dart';

/// Форма создания или редактирования кампании.
class CampaignFormScreen extends StatefulWidget {
  final Campaign? existing;
  const CampaignFormScreen({super.key, this.existing});

  @override
  State<CampaignFormScreen> createState() => _CampaignFormScreenState();
}

class _CampaignFormScreenState extends State<CampaignFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _budget;
  late String _category;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _budget = TextEditingController(text: e != null ? e.budget.toString() : '');
    _category = e?.category ??
        (AppRepository.instance.currentUser?.category.isNotEmpty == true
            ? AppRepository.instance.currentUser!.category
            : AppConst.categories.first);
    if (!AppConst.categories.contains(_category)) {
      _category = AppConst.categories.first;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = AppRepository.instance;
    final budget = int.tryParse(_budget.text.trim()) ?? 0;
    try {
      if (_isEdit) {
        await repo.updateCampaign(
          widget.existing!.id,
          title: _title.text.trim(),
          description: _description.text.trim(),
          budget: budget,
          category: _category,
        );
      } else {
        await repo.createCampaign(
          brandId: repo.currentUser!.id,
          title: _title.text.trim(),
          description: _description.text.trim(),
          budget: budget,
          category: _category,
          imageUrl: '',
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showSnack(context, _isEdit ? 'Кампания обновлена' : 'Кампания создана');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Редактировать кампанию' : 'Новая кампания')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Опишите задачу подробнее (от 10 символов)'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budget,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Бюджет, ₽',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Введите сумму бюджета';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: AppConst.categories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: _isEdit ? tr('save') : tr('create_campaign'),
                  icon: Icons.check_rounded,
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
