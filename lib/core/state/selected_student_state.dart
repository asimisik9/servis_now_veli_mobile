import 'package:flutter/material.dart';

import '../../features/home/data/models/home_status_model.dart';
import '../../features/home/data/services/student_service.dart';
import '../network/api_exceptions.dart';

class SelectedStudentState extends ChangeNotifier {
  SelectedStudentState({StudentService? studentService})
      : _studentService = studentService ?? StudentService();

  final StudentService _studentService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Student> _students = const [];
  List<Student> get students => _students;

  Student? _selectedStudent;
  Student? get selectedStudent => _selectedStudent;

  bool get hasMultipleStudents => _students.length > 1;

  Future<void> loadStudents({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }
    if (!forceRefresh && _students.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedStudents = await _studentService.fetchStudents();
      _students = fetchedStudents;

      if (_students.isEmpty) {
        _selectedStudent = null;
      } else if (_selectedStudent == null) {
        _selectedStudent = _students.first;
      } else {
        final selectedId = _selectedStudent!.id;
        _selectedStudent =
            _students.where((s) => s.id == selectedId).firstOrNull;
        _selectedStudent ??= _students.first;
      }
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Öğrenci bilgileri alınamadı.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectStudentById(String studentId) {
    if (studentId.isEmpty) {
      return;
    }

    final nextStudent = _students.where((s) => s.id == studentId).firstOrNull;
    if (nextStudent == null || nextStudent.id == _selectedStudent?.id) {
      return;
    }

    _selectedStudent = nextStudent;
    notifyListeners();
  }

  void updateStudent(Student updatedStudent) {
    var changed = false;
    final updatedList = <Student>[];

    for (final student in _students) {
      if (student.id == updatedStudent.id) {
        updatedList.add(updatedStudent);
        changed = true;
      } else {
        updatedList.add(student);
      }
    }

    if (!changed) {
      return;
    }

    _students = updatedList;
    if (_selectedStudent?.id == updatedStudent.id) {
      _selectedStudent = updatedStudent;
    }
    notifyListeners();
  }
}

extension _FirstOrNullStudent on Iterable<Student> {
  Student? get firstOrNull => isEmpty ? null : first;
}
