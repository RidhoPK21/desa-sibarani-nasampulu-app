// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:desa_sibarani_app/features/public/beranda/screens/beranda_screen.dart';
import 'package:desa_sibarani_app/features/public/apbdes/presentation/screens/apbdes_list_screen.dart';
import 'package:desa_sibarani_app/features/public/apbdes/presentation/screens/apbdes_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/beranda',
  routes: [
    GoRoute(
      path: '/beranda',
      builder: (context, state) => const BerandaScreen(),
    ),
    GoRoute(
      path: '/apbdes',
      builder: (context, state) => const ApbdesListScreen(),
    ),
    GoRoute(
      path: '/apbdes/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ApbdesDetailScreen(id: id);
      },
    ),
  ],
);