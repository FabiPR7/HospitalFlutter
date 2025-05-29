import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class RoomOptionsDialog extends StatelessWidget {
  final Room room;
  final Function() onRoomDeleted;

  const RoomOptionsDialog({
    Key? key,
    required this.room,
    required this.onRoomDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeHospital.getWhite(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeHospital.getButtonBlue().withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.meeting_room, color: ThemeHospital.getButtonBlue(), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      room.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHospital.getButtonBlue(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.business_outlined, 'Departamento', room.department),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.layers_outlined, 'Piso', room.floor.toString()),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.bed_outlined, 'Total de Camillas', room.stretches.toString()),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event_seat_outlined,
              'Disponibles',
              room.available.toString(),
              isAvailable: room.available > 0,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await RoomFirebase().deleteRoom(room.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        onRoomDeleted();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Habitación eliminada exitosamente'),
                            backgroundColor: ThemeHospital.getButtonBlue(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Error al eliminar la habitación'),
                            backgroundColor: ThemeHospital.getErrorRed(),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHospital.getErrorRed(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Eliminar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ThemeHospital.getWhite(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isAvailable = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHospital.getButtonBlue().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isAvailable ? ThemeHospital.getButtonBlue() : ThemeHospital.getErrorRed(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? ThemeHospital.getButtonBlue() : ThemeHospital.getErrorRed(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 