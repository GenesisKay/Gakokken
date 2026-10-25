import 'package:flutter/material.dart';

/// Sistema de iconos centralizado de la aplicación
class AppIcons {
  // Acciones generales
  final IconData add;
  final IconData edit;
  final IconData delete;
  final IconData save;
  final IconData cancel;
  final IconData close;
  final IconData search;
  final IconData filter;
  final IconData more;
  final IconData check;
  final IconData refresh;

  // Navegación
  final IconData menu;
  final IconData back;
  final IconData forward;
  final IconData arrowDown;
  final IconData arrowUp;
  final IconData arrowRight;
  final IconData arrowLeft;

  // Estados e información
  final IconData success;
  final IconData error;
  final IconData warning;
  final IconData info;
  final IconData help;

  // Entidades principales
  final IconData wallet;
  final IconData movement;
  final IconData category;
  final IconData budget;
  final IconData savingGoal;
  final IconData home;
  final IconData dashboard;
  final IconData settings;

  // Tipos de movimientos
  final IconData income;
  final IconData expense;
  final IconData transfer;
  final IconData transferIn;
  final IconData transferOut;

  // Otros iconos de finanzas
  final IconData calendar;
  final IconData date;
  final IconData money;
  final IconData creditCard;
  final IconData bank;
  final IconData chart;
  final IconData pieChart;
  final IconData trendingUp;
  final IconData trendingDown;
  final IconData repeat;
  final IconData schedule;
  final IconData history;
  final IconData analytics;
  final IconData barChart;
  final IconData expandMore;
  final IconData expandLess;

  // Iconos de datos
  final IconData visibility;
  final IconData visibilityOff;
  final IconData lock;
  final IconData unlock;
  final IconData download;
  final IconData upload;

  // Iconos de interfaz
  final IconData colorPicker;
  final IconData palette;
  final IconData image;
  final IconData copy;
  final IconData notification;
  final IconData theme;
  final IconData language;
  final IconData flag;
  final IconData receipt;
  final IconData note;

  const AppIcons({
    required this.add,
    required this.edit,
    required this.delete,
    required this.save,
    required this.cancel,
    required this.close,
    required this.search,
    required this.filter,
    required this.more,
    required this.check,
    required this.refresh,
    required this.menu,
    required this.back,
    required this.forward,
    required this.arrowDown,
    required this.arrowUp,
    required this.arrowRight,
    required this.arrowLeft,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.help,
    required this.wallet,
    required this.movement,
    required this.category,
    required this.budget,
    required this.savingGoal,
    required this.home,
    required this.dashboard,
    required this.settings,
    required this.income,
    required this.expense,
    required this.transfer,
    required this.transferIn,
    required this.transferOut,
    required this.calendar,
    required this.date,
    required this.money,
    required this.creditCard,
    required this.bank,
    required this.chart,
    required this.pieChart,
    required this.trendingUp,
    required this.trendingDown,
    required this.repeat,
    required this.schedule,
    required this.history,
    required this.analytics,
    required this.barChart,
    required this.expandMore,
    required this.expandLess,
    required this.visibility,
    required this.visibilityOff,
    required this.lock,
    required this.unlock,
    required this.download,
    required this.upload,
    required this.colorPicker,
    required this.palette,
    required this.image,
    required this.copy,
    required this.notification,
    required this.theme,
    required this.language,
    required this.flag,
    required this.receipt,
    required this.note,
  });

  /// Iconos estándar de Material Design
  static const standard = AppIcons(
    // Acciones generales
    add: Icons.add,
    edit: Icons.edit,
    delete: Icons.delete_forever,
    save: Icons.save,
    cancel: Icons.cancel,
    close: Icons.close,
    search: Icons.search,
    filter: Icons.filter_list,
    more: Icons.more_vert,
    check: Icons.check,
    refresh: Icons.refresh,

    // Navegación
    menu: Icons.menu,
    back: Icons.arrow_back,
    forward: Icons.arrow_forward,
    arrowDown: Icons.keyboard_arrow_down,
    arrowUp: Icons.keyboard_arrow_up,
    arrowRight: Icons.keyboard_arrow_right,
    arrowLeft: Icons.keyboard_arrow_left,

    // Estados e información
    success: Icons.check_circle,
    error: Icons.error,
    warning: Icons.warning,
    info: Icons.info,
    help: Icons.help_outline,

    // Entidades principales
    wallet: Icons.account_balance_wallet,
    movement: Icons.swap_horiz,
    category: Icons.category,
    budget: Icons.pie_chart,
    savingGoal: Icons.savings,
    home: Icons.home_rounded,
    dashboard: Icons.dashboard,
    settings: Icons.settings,

    // Tipos de movimientos
    income: Icons.add_circle,
    expense: Icons.remove_circle,
    transfer: Icons.swap_horiz,
    transferIn: Icons.arrow_downward,
    transferOut: Icons.arrow_upward,

    // Otros iconos de finanzas
    calendar: Icons.calendar_today,
    date: Icons.event,
    money: Icons.attach_money,
    creditCard: Icons.credit_card,
    bank: Icons.account_balance,
    chart: Icons.show_chart,
    pieChart: Icons.pie_chart_outline,
    trendingUp: Icons.trending_up,
    trendingDown: Icons.trending_down,
    repeat: Icons.repeat,
    schedule: Icons.schedule,
    history: Icons.history,
    analytics: Icons.analytics_outlined,
    barChart: Icons.bar_chart,
    expandMore: Icons.expand_more,
    expandLess: Icons.expand_less,

    // Iconos de datos
    visibility: Icons.visibility,
    visibilityOff: Icons.visibility_off,
    lock: Icons.lock,
    unlock: Icons.lock_open,
    download: Icons.download,
    upload: Icons.upload,

    // Iconos de interfaz
    colorPicker: Icons.color_lens,
    palette: Icons.palette,
    image: Icons.image,
    copy: Icons.content_copy,
    notification: Icons.notifications,
    theme: Icons.brightness_6,
    language: Icons.language,
    flag: Icons.flag,
    receipt: Icons.receipt_long,
    note: Icons.note,
  );
}
