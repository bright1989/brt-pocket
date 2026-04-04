import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/messages.dart';
import '../../../models/new_session_tab.dart';
import '../../../models/terminal_app.dart';
import '../../../services/bridge_service.dart';
import '../../../services/machine_manager_service.dart';
import 'settings_state.dart';

/// Manages user settings with SharedPreferences persistence.
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;
  final BridgeService? _bridge;
  final MachineManagerService? _machineManager;
  StreamSubscription<BridgeConnectionState>? _bridgeSub;

  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyAppLocale = 'settings_app_locale';
  static const _keySpeechLocale = 'settings_speech_locale';

  /// SharedPreferences key for the Shorebird update track.
  /// Also read directly from SharedPreferences in main.dart at startup.
  static const keyShorebirdTrack = 'settings_shorebird_track';
  static const _keyHideVoiceInput = 'settings_hide_voice_input';
  static const _keyTerminalApp = 'settings_terminal_app';
  static const _keyNewSessionTabs = 'settings_new_session_tabs';
  // Legacy key for migration
  static const _keyIndentSize = 'settings_indent_size';

  SettingsCubit(
    this._prefs, {
    BridgeService? bridgeService,
    MachineManagerService? machineManager,
  }) : _bridge = bridgeService,
       _machineManager = machineManager,
       super(_load(_prefs)) {
    final bridge = _bridge;
    if (bridge != null) {
      _bridgeSub = bridge.connectionStatus.listen((status) {
        if (status == BridgeConnectionState.connected) {
          _updateActiveMachine();
        } else if (status == BridgeConnectionState.disconnected) {
          emit(state.copyWith(activeMachineId: null));
        }
      });
      // Resolve active machine if already connected at init time
      if (bridge.isConnected) {
        _updateActiveMachine();
      }
    }
  }

  /// Resolve the currently connected Machine ID from the bridge URL.
  void _updateActiveMachine() {
    final bridge = _bridge;
    final manager = _machineManager;
    if (bridge == null || manager == null) return;

    final url = bridge.lastUrl;
    if (url == null) return;

    final uri = Uri.tryParse(
      url.replaceFirst('ws://', 'http://').replaceFirst('wss://', 'https://'),
    );
    if (uri == null) return;

    final machine = manager.findByHostPort(
      uri.host,
      uri.hasPort ? uri.port : 8765,
    );
    if (machine != null) {
      emit(state.copyWith(activeMachineId: machine.id));
    }
  }

  static SettingsState _load(SharedPreferences prefs) {
    final themeModeIndex = prefs.getInt(_keyThemeMode);
    final appLocale = prefs.getString(_keyAppLocale) ?? '';
    final speechLocale = prefs.getString(_keySpeechLocale);

    final shorebirdTrack = prefs.getString(keyShorebirdTrack) ?? 'stable';
    final indentSize = prefs.getInt(_keyIndentSize) ?? 2;
    final hideVoiceInput = prefs.getBool(_keyHideVoiceInput) ?? false;

    // Load terminal app config
    var terminalApp = TerminalAppConfig.empty;
    final terminalJson = prefs.getString(_keyTerminalApp);
    if (terminalJson != null) {
      try {
        final map = jsonDecode(terminalJson) as Map<String, dynamic>;
        terminalApp = TerminalAppConfig.fromJson(map);
      } catch (_) {
        // Ignore parse errors
      }
    }

    // Load new session tabs
    var newSessionTabs = defaultNewSessionTabs;
    final tabsJson = prefs.getString(_keyNewSessionTabs);
    if (tabsJson != null) {
      newSessionTabs = tabsFromJson(tabsJson) ?? defaultNewSessionTabs;
    }

    return SettingsState(
      themeMode:
          (themeModeIndex != null &&
              themeModeIndex >= 0 &&
              themeModeIndex < ThemeMode.values.length)
          ? ThemeMode.values[themeModeIndex]
          : ThemeMode.system,
      appLocaleId: appLocale,
      speechLocaleId: speechLocale ?? 'ja-JP',
      shorebirdTrack: shorebirdTrack,
      indentSize: indentSize.clamp(1, 4),
      hideVoiceInput: hideVoiceInput,
      terminalApp: terminalApp,
      newSessionTabs: newSessionTabs,
    );
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setInt(_keyThemeMode, mode.index);
    emit(state.copyWith(themeMode: mode));
  }

  void setAppLocaleId(String localeId) {
    _prefs.setString(_keyAppLocale, localeId);
    emit(state.copyWith(appLocaleId: localeId));
  }

  void setIndentSize(int size) {
    final clamped = size.clamp(1, 4);
    _prefs.setInt(_keyIndentSize, clamped);
    emit(state.copyWith(indentSize: clamped));
  }

  void setShorebirdTrack(String track) {
    _prefs.setString(keyShorebirdTrack, track);
    emit(state.copyWith(shorebirdTrack: track));
  }

  void setHideVoiceInput(bool hide) {
    _prefs.setBool(_keyHideVoiceInput, hide);
    emit(state.copyWith(hideVoiceInput: hide));
  }

  void setSpeechLocaleId(String localeId) {
    _prefs.setString(_keySpeechLocale, localeId);
    emit(state.copyWith(speechLocaleId: localeId));
  }

  void setTerminalApp(TerminalAppConfig config) {
    _prefs.setString(_keyTerminalApp, jsonEncode(config.toJson()));
    emit(state.copyWith(terminalApp: config));
  }

  void clearTerminalApp() {
    _prefs.remove(_keyTerminalApp);
    emit(state.copyWith(terminalApp: TerminalAppConfig.empty));
  }

  void setNewSessionTabs(List<NewSessionTab> tabs) {
    _prefs.setString(_keyNewSessionTabs, tabsToJson(tabs));
    emit(state.copyWith(newSessionTabs: tabs));
  }

  @override
  Future<void> close() async {
    await _bridgeSub?.cancel();
    return super.close();
  }
}
