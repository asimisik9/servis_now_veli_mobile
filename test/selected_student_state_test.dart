import 'package:flutter_test/flutter_test.dart';
import 'package:servis_now_veli_mobile/core/state/selected_student_state.dart';
import 'package:servis_now_veli_mobile/features/home/data/models/home_status_model.dart';
import 'package:servis_now_veli_mobile/features/home/data/services/student_service.dart';

class _FakeStudentService extends StudentService {
  _FakeStudentService(this._students);

  final List<Student> _students;

  @override
  Future<List<Student>> fetchStudents() async => _students;
}

void main() {
  test('loadStudents selects first student and supports switching', () async {
    final students = [
      Student(id: 's1', fullName: 'Ali', studentNumber: '1'),
      Student(id: 's2', fullName: 'Ayse', studentNumber: '2'),
    ];

    final state = SelectedStudentState(
      studentService: _FakeStudentService(students),
    );

    await state.loadStudents();
    expect(state.selectedStudent?.id, 's1');

    state.selectStudentById('s2');
    expect(state.selectedStudent?.id, 's2');
  });

  test('updateStudent updates selected student data', () async {
    final students = [
      Student(id: 's1', fullName: 'Ali', studentNumber: '1', address: 'Eski'),
    ];

    final state = SelectedStudentState(
      studentService: _FakeStudentService(students),
    );

    await state.loadStudents();
    state.updateStudent(
      Student(id: 's1', fullName: 'Ali', studentNumber: '1', address: 'Yeni'),
    );

    expect(state.selectedStudent?.address, 'Yeni');
  });
}
