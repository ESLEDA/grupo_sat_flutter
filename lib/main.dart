import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pagesAdmin/admin_page.dart';
import 'features/auth/presentation/pagesEmpleado/empleado_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/marca_bloc.dart';
import 'features/auth/presentation/bloc/almacen_bloc.dart';
import 'features/auth/presentation/bloc/material_bloc.dart';
import 'features/auth/presentation/pages/registro_page.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/data/repositories/marca_repository.dart';
import 'features/auth/data/repositories/almacen_repository.dart';
import 'features/auth/data/repositories/material_repository.dart';
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
  final materialRepository = MaterialRepository();
  
  runApp(MyApp(
    authRepository: authRepository,
    marcaRepository: marcaRepository,
    almacenRepository: almacenRepository,
    materialRepository: materialRepository,
  ));
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  final MarcaRepository marcaRepository;
  final AlmacenRepository almacenRepository;
  final MaterialRepository materialRepository;
  
  const MyApp({
    super.key, 
    required this.authRepository,
    required this.marcaRepository,
    required this.almacenRepository,
    required this.materialRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  void initState() {
    super.initState();
    // Registrar el observer para detectar cambios en el ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Limpiar el observer cuando se destruye el widget
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cerrar sesión cuando la app se pausa o se detiene
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _cerrarSesion();
    }
  }

  // Método para cerrar sesión
  void _cerrarSesion() async {
    if (_auth.currentUser != null) {
      try {
        await _auth.signOut();
        debugPrint('Sesión cerrada automáticamente');
      } catch (e) {
        debugPrint('Error al cerrar sesión: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(widget.authRepository),
        ),
        BlocProvider(
          create: (context) => MarcaBloc(widget.marcaRepository),
        ),
        BlocProvider(
          create: (context) => AlmacenBloc(widget.almacenRepository),
        ),
        BlocProvider(
          create: (context) => MaterialBloc(widget.materialRepository),
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