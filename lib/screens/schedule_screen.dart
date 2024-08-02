import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<List<String>> schedule =
  List.generate(10, (_) => List.generate(5, (_) => ''));
  List<Map<String, String>> assignments = [];
  List<Map<String, String>> exams = [];
  List<Map<String, String>> completedAssignments = [];
  List<Map<String, String>> completedExams = [];

  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ders Programı',
            style:
            TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Haftalık Ders Programı',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            if (isEditing)
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = false;
                                  });
                                },
                                child: Text('Kaydet',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: Size(60, 36),
                                ),
                              )
                            else
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                child: Text('Düzenle',
                                    style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  minimumSize: Size(60, 36),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Table(
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.blue, width: 2),
                      ),
                      children: [
                        TableRow(
                          children: [
                            _buildTableCell('Saat', isHeader: true),
                            _buildTableCell('Pazartesi', isHeader: true),
                            _buildTableCell('Salı', isHeader: true),
                            _buildTableCell('Çarşamba', isHeader: true),
                            _buildTableCell('Perşembe', isHeader: true),
                            _buildTableCell('Cuma', isHeader: true),
                          ],
                        ),
                        for (int i = 0; i < 10; i++)
                          TableRow(
                            children: [
                              _buildTableCell('${8 + i}.00 - ${9 + i}.00'),
                              for (int j = 0; j < 5; j++)
                                _buildTableCell(schedule[i][j],
                                    isEditable: isEditing, onChanged: (value) {
                                      setState(() {
                                        schedule[i][j] = value;
                                      });
                                    }),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildSection('Eklenen Ödevler & Sınavlar', assignments, exams),
                SizedBox(height: 16),
                _buildSection('Tamamlanan Ödevler & Sınavlar',
                    completedAssignments, completedExams,
                    completed: true),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.assignment, color: Colors.blue),
                            title: Text('Ödev Ekle',
                                style: TextStyle(color: Colors.blue)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddAssignmentPage(
                                      onAddAssignment: _addAssignment),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.event, color: Colors.blue),
                            title: Text('Sınav Ekle',
                                style: TextStyle(color: Colors.blue)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddExamPage(onAddExam: _addExam),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text('+',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text,
      {bool isEditable = false,
        ValueChanged<String>? onChanged,
        bool isHeader = false}) {
    if (isHeader) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (isEditable) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: text.isEmpty ? ' ' : text,
          style: TextStyle(fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Ders Adı',
            hintStyle: TextStyle(color: Colors.grey), // Placeholder rengi
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(8),
          ),
          onChanged: onChanged,
          cursorColor: Colors.blue, // Yazı imleci mavi
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, String>> assignments,
      List<Map<String, String>> exams,
      {bool completed = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: completed ? Colors.green : Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        if (assignments.isEmpty && exams.isEmpty)
          Text(
            'Henüz ${completed ? 'tamamlanan' : 'eklenen'} Ödev veya Sınavınız bulunmamaktadır.',
            style: TextStyle(color: Colors.grey),
          ),
        for (var assignment in assignments)
          _buildItemCard(assignment, completed, true),
        for (var exam in exams) _buildItemCard(exam, completed, false),
      ],
    );
  }

  Widget _buildItemCard(
      Map<String, String> item, bool completed, bool isAssignment) {
    return Dismissible(
      key: ValueKey(item),
      background: Container(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              Spacer(),
            ],
          ),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Spacer(),
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          if (completed) {
            if (direction == DismissDirection.startToEnd) {
              // Soldan sağa kaydırıldığında silinen tamamlanan ödevler veya sınavlar
              if (isAssignment) {
                completedAssignments.remove(item);
              } else {
                completedExams.remove(item);
              }
            } else if (direction == DismissDirection.endToStart) {
              // Sağdan sola kaydırıldığında silinen tamamlanan ödevler veya sınavlar
              if (isAssignment) {
                completedAssignments.remove(item);
              } else {
                completedExams.remove(item);
              }
            }
          } else {
            if (direction == DismissDirection.startToEnd) {
              if (isAssignment) {
                assignments.remove(item);
                completedAssignments.add(item);
              } else {
                exams.remove(item);
                completedExams.add(item);
              }
            } else if (direction == DismissDirection.endToStart) {
              if (isAssignment) {
                assignments.remove(item);
              } else {
                exams.remove(item);
              }
            }
          }
        });
      },
      child: Card(
        color: completed ? Colors.green[50] : Colors.blue[50],
        child: ListTile(
          leading: Icon(isAssignment ? Icons.assignment : Icons.event,
              color: completed ? Colors.green : Colors.blue),
          title: Text(item['title'] ?? ''),
          subtitle: Text(item['description'] ?? ''),
          trailing: Text(item['date'] ?? ''),
        ),
      ),
    );
  }

  void _addAssignment(Map<String, String> assignment) {
    setState(() {
      assignments.add(assignment);
    });
  }

  void _addExam(Map<String, String> exam) {
    setState(() {
      exams.add(exam);
    });
  }
}

class AddAssignmentPage extends StatelessWidget {
  final Function(Map<String, String>) onAddAssignment;

  AddAssignmentPage({required this.onAddAssignment});

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _dateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Ödev Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_titleController, 'Başlık'),
            _buildTextField(_descriptionController, 'Açıklama'),
            _buildDateField(context, _dateController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onAddAssignment({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'date': _dateController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Tarih',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: Colors.blue,
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary: Colors.blue, // Eski accentColor yerine
                  ),
                  buttonTheme:
                  ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }
}

class AddExamPage extends StatelessWidget {
  final Function(Map<String, String>) onAddExam;

  AddExamPage({required this.onAddExam});

  @override
  Widget build(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _dateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Sınav Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_titleController, 'Başlık'),
            _buildTextField(_descriptionController, 'Açıklama'),
            _buildDateField(context, _dateController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onAddExam({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'date': _dateController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateField(
      BuildContext context, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Tarih',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (context, child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: Colors.blue,
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary: Colors.blue, // Eski accentColor yerine
                  ),
                  buttonTheme:
                  ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  dialogBackgroundColor: Colors.white,
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }
}
