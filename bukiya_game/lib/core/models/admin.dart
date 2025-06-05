import 'package:flutter/material.dart';

/// 管理者権限レベル
enum AdminRole {
  superAdmin,    // スーパー管理者（全権限）
  gameAdmin,     // ゲーム管理者（ゲームデータ管理）
  moderator,     // モデレーター（限定権限）
}

/// 管理者アカウント
class AdminAccount {
  final String id;
  final String username;
  final String email;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final String? profileImageUrl;

  const AdminAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role.name,
    'permissions': permissions.map((e) => e.name).toList(),
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'last_login_at': lastLoginAt.toIso8601String(),
    'profile_image_url': profileImageUrl,
  };

  factory AdminAccount.fromJson(Map<String, dynamic> json) => AdminAccount(
    id: json['id'],
    username: json['username'],
    email: json['email'],
    role: AdminRole.values.firstWhere((e) => e.name == json['role']),
    permissions: (json['permissions'] as List<dynamic>)
        .map((e) => AdminPermission.values.firstWhere((p) => p.name == e))
        .toList(),
    isActive: json['is_active'] ?? true,
    createdAt: DateTime.parse(json['created_at']),
    lastLoginAt: DateTime.parse(json['last_login_at']),
    profileImageUrl: json['profile_image_url'],
  );

  bool hasPermission(AdminPermission permission) => permissions.contains(permission);

  AdminAccount copyWith({
    String? id,
    String? username,
    String? email,
    AdminRole? role,
    List<AdminPermission>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileImageUrl,
  }) {
    return AdminAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

/// 管理者権限
enum AdminPermission {
  // 武器管理
  weaponRead,      // 武器情報閲覧
  weaponCreate,    // 武器作成
  weaponEdit,      // 武器編集
  weaponDelete,    // 武器削除

  // 素材管理
  materialRead,    // 素材情報閲覧
  materialCreate,  // 素材作成
  materialEdit,    // 素材編集
  materialDelete,  // 素材削除

  // ユーザー管理
  userRead,        // ユーザー情報閲覧
  userEdit,        // ユーザー編集
  userDelete,      // ユーザー削除
  userBan,         // ユーザーBAN

  // システム管理
  systemConfig,    // システム設定変更
  systemLogs,      // ログ閲覧
  systemBackup,    // バックアップ操作
  systemRestore,   // リストア操作

  // 統計・分析
  analyticsRead,   // 統計データ閲覧
  analyticsExport, // データエクスポート

  // ゲーム管理
  gameEvents,      // イベント管理
  gameBalance,     // バランス調整
}

/// CRUD操作タイプ
enum CrudOperation {
  create,
  read,
  update,
  delete,
}

/// 管理操作ログ
class AdminActionLog {
  final String id;
  final String adminId;
  final String adminUsername;
  final CrudOperation operation;
  final String targetType;    // 'weapon', 'material', 'user', etc.
  final String targetId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final DateTime timestamp;
  final String? notes;
  final String? ipAddress;
  final String? userAgent;

  const AdminActionLog({
    required this.id,
    required this.adminId,
    required this.adminUsername,
    required this.operation,
    required this.targetType,
    required this.targetId,
    this.oldData,
    this.newData,
    required this.timestamp,
    this.notes,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'admin_id': adminId,
    'admin_username': adminUsername,
    'operation': operation.name,
    'target_type': targetType,
    'target_id': targetId,
    'old_data': oldData,
    'new_data': newData,
    'timestamp': timestamp.toIso8601String(),
    'notes': notes,
    'ip_address': ipAddress,
    'user_agent': userAgent,
  };

  factory AdminActionLog.fromJson(Map<String, dynamic> json) => AdminActionLog(
    id: json['id'],
    adminId: json['admin_id'],
    adminUsername: json['admin_username'],
    operation: CrudOperation.values.firstWhere((e) => e.name == json['operation']),
    targetType: json['target_type'],
    targetId: json['target_id'],
    oldData: json['old_data'],
    newData: json['new_data'],
    timestamp: DateTime.parse(json['timestamp']),
    notes: json['notes'],
    ipAddress: json['ip_address'],
    userAgent: json['user_agent'],
  );

  String get operationDisplayText {
    switch (operation) {
      case CrudOperation.create:
        return '作成';
      case CrudOperation.read:
        return '閲覧';
      case CrudOperation.update:
        return '更新';
      case CrudOperation.delete:
        return '削除';
    }
  }

  Color get operationColor {
    switch (operation) {
      case CrudOperation.create:
        return Colors.green;
      case CrudOperation.read:
        return Colors.blue;
      case CrudOperation.update:
        return Colors.orange;
      case CrudOperation.delete:
        return Colors.red;
    }
  }
}

/// データテーブルの設定
class AdminTableConfig {
  final String title;
  final List<AdminTableColumn> columns;
  final bool enableSearch;
  final bool enableFilter;
  final bool enableSort;
  final bool enableExport;
  final bool enableBulkActions;
  final int itemsPerPage;

  const AdminTableConfig({
    required this.title,
    required this.columns,
    this.enableSearch = true,
    this.enableFilter = true,
    this.enableSort = true,
    this.enableExport = true,
    this.enableBulkActions = false,
    this.itemsPerPage = 20,
  });
}

/// テーブルカラム定義
class AdminTableColumn {
  final String key;
  final String label;
  final bool sortable;
  final bool filterable;
  final AdminColumnType type;
  final double? width;
  final String Function(dynamic)? formatter;

  const AdminTableColumn({
    required this.key,
    required this.label,
    this.sortable = true,
    this.filterable = true,
    this.type = AdminColumnType.text,
    this.width,
    this.formatter,
  });
}

/// カラムデータタイプ
enum AdminColumnType {
  text,
  number,
  date,
  boolean,
  enum_,
  image,
  action,
}

/// フォームフィールド設定
class AdminFormField {
  final String key;
  final String label;
  final AdminFieldType type;
  final bool required;
  final String? placeholder;
  final List<String>? options;
  final String? Function(String?)? validator;
  final dynamic defaultValue;
  final Map<String, dynamic>? metadata;

  const AdminFormField({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.options,
    this.validator,
    this.defaultValue,
    this.metadata,
  });
}

/// フォームフィールドタイプ
enum AdminFieldType {
  text,
  number,
  email,
  password,
  textarea,
  dropdown,
  checkbox,
  radio,
  file,
  image,
  date,
  datetime,
  color,
  range,
}

/// バルク操作
class BulkAction {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final bool requiresConfirmation;
  final String? confirmationMessage;

  const BulkAction({
    required this.id,
    required this.label,
    required this.icon,
    this.color = Colors.blue,
    this.requiresConfirmation = false,
    this.confirmationMessage,
  });
}

/// 検索・フィルター条件
class AdminSearchFilter {
  final String? searchQuery;
  final Map<String, dynamic> filters;
  final String? sortBy;
  final bool sortAscending;
  final int page;
  final int itemsPerPage;

  const AdminSearchFilter({
    this.searchQuery,
    this.filters = const {},
    this.sortBy,
    this.sortAscending = true,
    this.page = 1,
    this.itemsPerPage = 20,
  });

  AdminSearchFilter copyWith({
    String? searchQuery,
    Map<String, dynamic>? filters,
    String? sortBy,
    bool? sortAscending,
    int? page,
    int? itemsPerPage,
  }) {
    return AdminSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? this.page,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  Map<String, dynamic> toJson() => {
    'search_query': searchQuery,
    'filters': filters,
    'sort_by': sortBy,
    'sort_ascending': sortAscending,
    'page': page,
    'items_per_page': itemsPerPage,
  };
}

/// ページネーション情報
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    currentPage: json['current_page'],
    totalPages: json['total_pages'],
    totalItems: json['total_items'],
    itemsPerPage: json['items_per_page'],
    hasNext: json['has_next'],
    hasPrevious: json['has_previous'],
  );

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'total_pages': totalPages,
    'total_items': totalItems,
    'items_per_page': itemsPerPage,
    'has_next': hasNext,
    'has_previous': hasPrevious,
  };
}

/// APIレスポンス
class AdminApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final PaginationInfo? pagination;
  final Map<String, dynamic>? metadata;

  const AdminApiResponse({
    required this.success,
    this.data,
    this.message,
    this.pagination,
    this.metadata,
  });

  factory AdminApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return AdminApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      message: json['message'],
      pagination: json['pagination'] != null 
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
      metadata: json['metadata'],
    );
  }
}

/// システム設定項目
class SystemSetting {
  final String key;
  final String label;
  final String group;
  final AdminFieldType type;
  final dynamic value;
  final dynamic defaultValue;
  final String? description;
  final List<String>? options;
  final bool requiresRestart;
  final String? unit;

  const SystemSetting({
    required this.key,
    required this.label,
    required this.group,
    required this.type,
    required this.value,
    this.defaultValue,
    this.description,
    this.options,
    this.requiresRestart = false,
    this.unit,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'group': group,
    'type': type.name,
    'value': value,
    'default_value': defaultValue,
    'description': description,
    'options': options,
    'requires_restart': requiresRestart,
    'unit': unit,
  };

  factory SystemSetting.fromJson(Map<String, dynamic> json) => SystemSetting(
    key: json['key'],
    label: json['label'],
    group: json['group'],
    type: AdminFieldType.values.firstWhere((e) => e.name == json['type']),
    value: json['value'],
    defaultValue: json['default_value'],
    description: json['description'],
    options: json['options']?.cast<String>(),
    requiresRestart: json['requires_restart'] ?? false,
    unit: json['unit'],
  );

  SystemSetting copyWith({
    String? key,
    String? label,
    String? group,
    AdminFieldType? type,
    dynamic value,
    dynamic defaultValue,
    String? description,
    List<String>? options,
    bool? requiresRestart,
  }) {
    return SystemSetting(
      key: key ?? this.key,
      label: label ?? this.label,
      group: group ?? this.group,
      type: type ?? this.type,
      value: value ?? this.value,
      defaultValue: defaultValue ?? this.defaultValue,
      description: description ?? this.description,
      options: options ?? this.options,
      requiresRestart: requiresRestart ?? this.requiresRestart,
    );
  }
}