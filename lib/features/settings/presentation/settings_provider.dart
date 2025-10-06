import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di.dart';
import '../../settings/data/settings_dao.dart';

class SettingsState {
  final String? sheetsLink;
  final bool saving;
  SettingsState({this.sheetsLink, this.saving = false});

  SettingsState copyWith({String? sheetsLink, bool? saving}) =>
      SettingsState(sheetsLink: sheetsLink ?? this.sheetsLink, saving: saving ?? this.saving);
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  final _dao = sl<SettingsDao>();

  Future<void> load() async {
    final link = await _dao.getValue('sheets_link');
    state = state.copyWith(sheetsLink: link);
  }

  Future<void> saveLink(String? link) async {
    state = state.copyWith(saving: true);
    await _dao.setValue('sheets_link', link);
    state = state.copyWith(sheetsLink: link, saving: false);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final n = SettingsNotifier();
  n.load();
  return n;
});
