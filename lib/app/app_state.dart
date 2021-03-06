import 'package:equatable/equatable.dart';
import 'package:exattraffic/models/marker_model.dart';
import 'package:flutter/cupertino.dart';

abstract class AppState extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchMarkerInitial extends AppState {}

class FetchMarkerFailure extends AppState {
  final String message;

  FetchMarkerFailure({
    @required this.message,
  });

  @override
  List<Object> get props => [message];
}

class FetchMarkerSuccess extends AppState {
  final List<MarkerModel> markerList;

  FetchMarkerSuccess({
    @required this.markerList,
  });

  @override
  List<Object> get props => [markerList];
}
