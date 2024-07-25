import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hall_model.dart';
import '../widget/text_field.dart'; // Import your custom TextFieldInput widget
import '../widget/button.dart';
class HallsScreen extends StatefulWidget {
  @override
  _HallsScreenState createState() => _HallsScreenState();
}

class _HallsScreenState extends State<HallsScreen> {
  Hall? _selectedHall;
  final TextEditingController _bedspaceController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Hall Details'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('halls').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final halls = snapshot.data!.docs.map((doc) => Hall.fromFirestore(doc)).toList();

                    if (_selectedHall != null && !halls.contains(_selectedHall)) {
                      _selectedHall = halls.firstWhere((hall) => hall.id == _selectedHall!.id, orElse: () => halls.first);
                    }

                    return DropdownButton<Hall>(
                      hint: Text('Select Hall'),
                      value: _selectedHall,
                      onChanged: (Hall? newValue) {
                        setState(() {
                          _selectedHall = newValue;
                          if (_selectedHall != null) {
                            _bedspaceController.text = _selectedHall!.bedspace.toString();
                            _roomsController.text = _selectedHall!.rooms.toString();
                          }
                        });
                      },
                      items: halls.map((Hall hall) {
                        return DropdownMenuItem<Hall>(
                          value: hall,
                          child: Text(hall.id),
                        );
                      }).toList(),
                    );
                  },
                ),
                TextFieldInput(
                  textEditingController: _bedspaceController,
                  hintText: 'Bedspace',
                  textInputType: TextInputType.number,
                  icon: Icons.bed,
                ),
                TextFieldInput(
                  textEditingController: _roomsController,
                  hintText: 'Rooms',
                  textInputType: TextInputType.number,
                  icon: Icons.meeting_room,
                ),
                MyButtons(
                  onTap: _updateHall,
                  text: "Update Hall"),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateHall() {
    if (_selectedHall == null) return;

    final int bedspace = int.parse(_bedspaceController.text);
    final int rooms = int.parse(_roomsController.text);

    FirebaseFirestore.instance.collection('halls').doc(_selectedHall!.id).update({
      'bedspace': bedspace,
      'rooms': rooms,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hall details updated')));
  }
}
