import 'package:flutter/material.dart';

class ResourceDef {
  final String path;
  final String title;
  final IconData icon;
  final List<String> columns;
  const ResourceDef({
    required this.path,
    required this.title,
    required this.icon,
    required this.columns,
  });
}

const List<ResourceDef> resourceDefs = [
  ResourceDef(
    path: '/households',
    title: 'Households',
    icon: Icons.home_work_outlined,
    columns: ['household_number', 'purok', 'head_of_family'],
  ),
  ResourceDef(
    path: '/residents',
    title: 'Residents',
    icon: Icons.people_alt_outlined,
    columns: ['household_id', 'first_name', 'last_name', 'gender', 'birth_date', 'age', 'contact_number'],
  ),
  ResourceDef(
    path: '/immunizations',
    title: 'Immunizations',
    icon: Icons.vaccines_outlined,
    columns: ['resident_id', 'vaccine_name', 'dose_number', 'administered_by'],
  ),
  ResourceDef(
    path: '/medical-histories',
    title: 'Medical History',
    icon: Icons.medical_information_outlined,
    columns: ['resident_id', 'diagnosis', 'treatment', 'remarks'],
  ),
  ResourceDef(
    path: '/reports',
    title: 'Reports',
    icon: Icons.summarize_rounded,
    columns: ['report_title', 'description', 'generated_by'],
  ),
];
