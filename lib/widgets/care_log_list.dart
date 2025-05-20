import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:plantmate/models/care_log.dart';
import 'package:plantmate/providers/care_logs_provider.dart';

class CareLogList extends ConsumerWidget {
  final AsyncValue<List<CareLog>> careLogsAsync;
  
  const CareLogList({
    Key? key,
    required this.careLogsAsync,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return careLogsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
            child: Text('No care logs recorded yet'),
          );
        }
        
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildCareLogItem(context, log, ref);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
  
  Widget _buildCareLogItem(BuildContext context, CareLog log, WidgetRef ref) {
    IconData icon;
    Color color;
    
    switch (log.careType) {
      case CareType.watering:
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case CareType.fertilizing:
        icon = Icons.eco;
        color = Colors.green;
        break;
      case CareType.repotting:
        icon = Icons.swap_horiz;
        color = Colors.orange;
        break;
      case CareType.pruning:
        icon = Icons.content_cut;
        color = Colors.purple;
        break;
      case CareType.observation:
        icon = Icons.visibility;
        color = Colors.teal;
        break;
    }
    
    return Dismissible(
      key: Key(log.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(careLogsProvider.notifier).deleteCareLog(log.id);
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Care Log'),
            content: const Text('Are you sure you want to delete this care log?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(log.careType.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat.yMMMd().add_jm().format(log.date)),
            if (log.notes.isNotEmpty)
              Text(
                log.notes,
                style: const TextStyle(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showCareLogDetails(context, log);
        },
      ),
    );
  }
  
  void _showCareLogDetails(BuildContext context, CareLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log.careType.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat.yMMMd().add_jm().format(log.date)}'),
            const SizedBox(height: 8),
            if (log.notes.isNotEmpty) ...[
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(log.notes),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
