import 'package:flutter/material.dart';

class EntityFilter {
  String filter;

  EntityFilter({required this.filter});

  factory EntityFilter.fromJson(Map<String, dynamic> json) {
    return EntityFilter(
      filter: json['filter'],
    );
  }

}