import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../models/new_session_tab.dart';
import '../../../models/terminal_app.dart';

part 'settings_state.freezed.dart';

/// Application-wide user settings.
@freezed
abstract class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    /// Theme mode: system, light, or dark.
    @Default(ThemeMode.system) ThemeMode themeMode,

    /// App display locale ID (e.g. 'ja', 'en').
    /// Empty string means follow the device default.
    @Default('') String appLocaleId,

    /// Locale ID for speech recognition (e.g. 'ja-JP', 'en-US').
    /// Empty string means use device default.
    @Default('ja-JP') String speechLocaleId,

    /// Currently connected Machine ID (null when disconnected).
    String? activeMachineId,

    /// Shorebird update track ('stable' or 'staging').
    @Default('stable') String shorebirdTrack,

    /// Indent size for list formatting (1-4 spaces).
    @Default(2) int indentSize,

    /// Whether to hide the voice input button in the chat input bar.
    @Default(false) bool hideVoiceInput,

    /// External terminal app configuration (preset or custom URL template).
    @Default(TerminalAppConfig.empty) TerminalAppConfig terminalApp,

    /// Visible tabs (and their order) in the new session sheet.
    @Default(defaultNewSessionTabs) List<NewSessionTab> newSessionTabs,
  }) = _SettingsState;
}
