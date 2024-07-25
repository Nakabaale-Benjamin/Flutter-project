import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hall_model.dart';

class EditHallScreen extends StatefulWidget {
  @override
  _EditHallScreenState createState() => _EditHallScreenState();
}

class _EditHallScreenState extends State<EditHallScreen> {
  Halls? _selectedHall;
  final TextEditingController _bedspaceController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Hall Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('hall').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final halls = snapshot.data!.docs.map((doc) => Halls.fromFirestore(doc)).toList();

                return DropdownButton<Halls>(
                  hint: Text('Select Hall'),
                  value: _selectedHall,
                  onChanged: (Halls? newValue) {
                    setState(() {
                      _selectedHall = newValue;
                      if (_selectedHall != null) {
                        _bedspaceController.text = _selectedHall!.bedspace.toString();
                        _roomsController.text = _selectedHall!.rooms.toString();
                      }
                    });
                  },
                  items: halls.map((Halls hall) {
                    return DropdownMenuItem<Halls>(
                      value: hall,
                      child: Text(hall.id),
                    );
                  }).toList(),
                );
              },
            ),
            TextField(
              controller: _bedspaceController,
              decoration: InputDecoration(labelText: 'Bedspace'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _roomsController,
              decoration: InputDecoration(labelText: 'Rooms'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _updateHall,
              child: Text('Update Hall'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateHall() {
    if (_selectedHall == null) return;

    final int bedspace = int.parse(_bedspaceController.text);
    final int rooms = int.parse(_roomsController.text);

    FirebaseFirestore.instance.collection('hall').doc(_selectedHall!.id).update({
      'bedspace': bedspace,
      'rooms': rooms,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hall details updated')));
  }
}
