import 'package:flutter/material.dart';//
import 'package:flutter_bloc/flutter_bloc.dart';//
import 'package:firebase_core/firebase_core.dart';//
import 'features/auth/presentation/pages/login_page.dart';//
import 'features/auth/presentation/pagesAdmin/admin_page.dart';//
import 'features/auth/presentation/pagesEmpleado/empleado_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/registro_page.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Firebase.initializeApp();
  
  final authRepository = AuthRepository();
  
  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  
  const MyApp({
    super.key, 
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mi App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/registro': (context) => const RegistroPage(),
          '/empleado': (context) => const EmpleadoPage(),
          '/admin': (context) => const AdminPage(),
        },
      ),
    );
  }
}