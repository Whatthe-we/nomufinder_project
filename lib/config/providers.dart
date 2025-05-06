import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_nomufinder/config/router.dart';

final routerProvider = Provider<GoRouter>((ref) => router);