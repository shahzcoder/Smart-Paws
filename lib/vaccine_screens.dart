import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import 'vaccine_model.dart';
import 'vaccine_service.dart';

// ==================== SCREEN 1: THE LIST ====================
class VaccineListScreen extends StatelessWidget {
  const VaccineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VaccineService service = VaccineService();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text("Vaccination Records"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5B4DFF), 
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Record", style: TextStyle(color: Colors.white)),
        onPressed: () {
          // Add Mode: Open form without data
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VaccineFormScreen()),
          );
        },
      ),
      body: StreamBuilder<List<VaccineRecord>>(
        stream: service.getVaccines(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No vaccination records found."));
          }

          final records = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  // --- CRITICAL FIX: Make the card clickable ---
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VaccineFormScreen(record: record),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE0F7FA),
                    child: const Icon(Icons.medical_services, color: Color(0xFF00BFA5)),
                  ),
                  title: Text(record.vaccineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pet: ${record.petName}"),
                      Text("Next Due: ${DateFormat('MMM dd, yyyy').format(record.nextDueDate)}", 
                           style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  // --- NOTICE: Only Delete Icon here (No Pencil) ---
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () => service.deleteRecord(record.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== SCREEN 2: THE FORM ====================
class VaccineFormScreen extends StatefulWidget {
  final VaccineRecord? record; 

  const VaccineFormScreen({super.key, this.record});

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petNameCtrl = TextEditingController();
  final _vaccineNameCtrl = TextEditingController();
  final _vetCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  
  DateTime _dateAdministered = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    // --- FILL DATA LOGIC ---
    if (widget.record != null) {
      _petNameCtrl.text = widget.record!.petName;
      _vaccineNameCtrl.text = widget.record!.vaccineName;
      _vetCtrl.text = widget.record!.veterinarian;
      _notesCtrl.text = widget.record!.notes;
      _dateAdministered = widget.record!.dateAdministered;
      _nextDueDate = widget.record!.nextDueDate;
    }
  }

Future<void> _selectDate(BuildContext context, bool isNextDue) async {
    // 1. Boundary Logic: "Next Due Date" calendar cannot go before the "Vaccination Date"
    final DateTime firstAllowedDate = isNextDue ? _dateAdministered : DateTime(2000);
    
    // Safety check: Ensure the initial calendar view isn't violating the boundary
    final DateTime initial = isNextDue ? _nextDueDate : _dateAdministered;
    final DateTime safeInitialDate = initial.isBefore(firstAllowedDate) ? firstAllowedDate : initial;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstAllowedDate, // This physically blocks past dates on the calendar
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isNextDue) {
          _nextDueDate = picked;
        } else {
          _dateAdministered = picked;
          
          // 2. Smart UX Feature: If user changes Vaccination Date, 
          // automatically push the Due Date to 1 year ahead by default
          if (_nextDueDate.isBefore(_dateAdministered)) {
             _nextDueDate = _dateAdministered.add(const Duration(days: 365));
          }
        }
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      final newRecord = VaccineRecord(
        id: widget.record?.id ?? '', 
        userId: uid,
        petName: _petNameCtrl.text,
        vaccineName: _vaccineNameCtrl.text,
        dateAdministered: _dateAdministered,
        nextDueDate: _nextDueDate,
        veterinarian: _vetCtrl.text,
        notes: _notesCtrl.text,
      );

      final service = VaccineService();
      
      if (widget.record == null) {
        service.addRecord(newRecord);
      } else {
        service.updateRecord(widget.record!.id, newRecord);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B4DFF)),
          onPressed: () => Navigator.pop(context),
        ),
        // Title changes based on mode
        title: Text(
          widget.record != null ? "Edit Record" : "Add Record", 
          style: const TextStyle(color: Colors.black)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Pet Name", _petNameCtrl),
              const SizedBox(height: 16),
              _buildTextField("Vaccine Name", _vaccineNameCtrl),
              const SizedBox(height: 16),
              _buildDatePicker("Vaccination Date", _dateAdministered, false),
              const SizedBox(height: 16),
              _buildDatePicker("Next Due Date", _nextDueDate, true),
              const SizedBox(height: 16),
              _buildTextField("Veterinarian", _vetCtrl),
              const SizedBox(height: 16),
              _buildTextField("Notes", _notesCtrl, maxLines: 3),
              const SizedBox(height: 30),
              SizedBox(
                width: 150,
                height: 45,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4DFF), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Done", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (val) => val!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, bool isNextDue) {
    return GestureDetector(
      onTap: () => _selectDate(context, isNextDue),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(color: Colors.black87, fontSize: 16)),
              ],
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}