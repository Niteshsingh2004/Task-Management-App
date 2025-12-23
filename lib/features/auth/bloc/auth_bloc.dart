import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
      final user = _auth.currentUser;
      if (user != null) {
        emit(Authenticated(user.uid));
      } else {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential user = await _auth.signInWithEmailAndPassword(
            email: event.email, password: event.password);
        emit(Authenticated(user.user!.uid));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? "Login failed"));
      }
    });

    on<SignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential user = await _auth.createUserWithEmailAndPassword(
            email: event.email, password: event.password);
        emit(Authenticated(user.user!.uid));
      } on FirebaseAuthException catch (e) {
        emit(AuthError(e.message ?? "Signup failed"));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _auth.signOut();
      emit(Unauthenticated());
    });
  }
}