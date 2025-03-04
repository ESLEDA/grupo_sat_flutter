import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pagesAdmin/admin_page.dart';
import 'features/auth/presentation/pagesEmpleado/empleado_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/marca_bloc.dart';
import 'features/auth/presentation/bloc/almacen_bloc.dart';
import 'features/auth/presentation/bloc/material_bloc.dart'; // Nueva importación
import 'features/auth/presentation/pages/registro_page.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/marca_repository.dart';
import 'features/auth/data/repositories/almacen_repository.dart';
import 'features/auth/data/repositories/material_repository.dart'; // Nueva importación
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Firebase.initializeApp();
  
  final authRepository = AuthRepository();
  final marcaRepository = MarcaRepository();
  final almacenRepository = AlmacenRepository();
  final materialRepository = MaterialRepository(); // Nuevo repositorio
  
  runApp(MyApp(
    authRepository: authRepository,
    marcaRepository: marcaRepository,
    almacenRepository: almacenRepository,
    materialRepository: materialRepository, // Añadir a los parámetros
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final MarcaRepository marcaRepository;
  final AlmacenRepository almacenRepository;
  final MaterialRepository materialRepository; // Nuevo campo
  
  const MyApp({
    super.key, 
    required this.authRepository,
    required this.marcaRepository,
    required this.almacenRepository,
    required this.materialRepository, // Añadir al constructor
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authRepository),
        ),
        BlocProvider(
          create: (context) => MarcaBloc(marcaRepository),
        ),
        BlocProvider(
          create: (context) => AlmacenBloc(almacenRepository),
        ),
        BlocProvider(
          create: (context) => MaterialBloc(materialRepository), // Nuevo BlocProvider
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