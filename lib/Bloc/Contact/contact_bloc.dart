import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/Api/apiProvider.dart';

abstract class ContactDentalEvent {}

class ContactDental extends ContactDentalEvent {}

class HomeDental extends ContactDentalEvent {}

class ContactDentalBloc extends Bloc<ContactDentalEvent, dynamic> {
  ContactDentalBloc() : super(dynamic) {
    on<ContactDental>((event, emit) async {
      await ApiProvider().getContactAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });
    on<HomeDental>((event, emit) async {
      await ApiProvider().getHomeAPI().then((value) {
        emit(value);
      }).catchError((error) {
        emit(error);
      });
    });

  }
}
