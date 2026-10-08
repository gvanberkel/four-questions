import 'package:flutter/material.dart';

abstract final class ActionIcons {
  static const IconData home = Icons.home_outlined;

  static const IconData history = Icons.history;

  static const IconData menu = Icons.menu;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;

  static const IconData open = Icons.chevron_right;
  static const IconData expandMore = Icons.expand_more;
  static const IconData more = Icons.more_horiz;
  static const IconData close = Icons.close;
  static const IconData search = Icons.search;

  static const IconData signIn = Icons.login;
  static const IconData signOut = Icons.logout;
  static const IconData person = Icons.person_outline;
  static const IconData settings = Icons.settings_outlined;

  static const IconData lightMode = Icons.light_mode_outlined;
  static const IconData darkMode = Icons.dark_mode_outlined;

  static const IconData systemMode = Icons.brightness_auto_outlined;

  static const IconData people = Icons.group_outlined;

  static const IconData goal = Icons.flag_outlined;

  static const IconData reminder = Icons.notifications_none;

  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData refresh = Icons.refresh;
  static const IconData download = Icons.download_outlined;
  static const IconData help = Icons.help_outline;

  static const IconData rising = Icons.arrow_upward;
  static const IconData falling = Icons.arrow_downward;

  static const IconData positive = Icons.check_circle_outline;

  static const IconData attention = Icons.error_outline;
  static const IconData info = Icons.info_outline;

  static const IconData offline = Icons.cloud_off_outlined;

  static const Map<String, IconData> named = {
    'home': home,
    'history': history,
    'menu': menu,
    'back': back,
    'forward': forward,
    'open': open,
    'expandMore': expandMore,
    'more': more,
    'close': close,
    'search': search,
    'signIn': signIn,
    'signOut': signOut,
    'person': person,
    'settings': settings,
    'lightMode': lightMode,
    'darkMode': darkMode,
    'systemMode': systemMode,
    'people': people,
    'goal': goal,
    'reminder': reminder,
    'add': add,
    'edit': edit,
    'delete': delete,
    'refresh': refresh,
    'download': download,
    'help': help,
    'rising': rising,
    'falling': falling,
    'positive': positive,
    'attention': attention,
    'info': info,
    'offline': offline,
  };
}
