import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:bukiya_game/core/models/adventurer_new.dart' show AdventurerInstance;
import 'package:bukiya_game/features/adventurer/providers/adventurer_provider.dart';

class AdventurerSelectionDialog extends StatefulWidget {
  final Function(int) onAdventurerSelected;

  const AdventurerSelectionDialog({
    Key? key,
    required this.onAdventurerSelected,
  }) : super(key: key);

  @override
  State<AdventurerSelectionDialog> createState() => _AdventurerSelectionDialogState();
}

class _AdventurerSelectionDialogState extends State<AdventurerSelectionDialog> {
  String? selectedAdventurerId;

  @override
  void initState() {
    super.initState();
    // Load adventurers if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdventurerProvider>().loadAdventurerData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.person_search, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Select Adventurer'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Consumer<AdventurerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error loading adventurers',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.loadAdventurerData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.visitingAdventurers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Adventurers Available',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You need to have adventurers to participate in dragon raids.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.visitingAdventurers.length,
              itemBuilder: (context, index) {
                final adventurer = provider.visitingAdventurers[index];
                final isSelected = selectedAdventurerId == adventurer.id;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected 
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getJobColor(adventurer.adventurerMaster?.profession),
                      child: Text(
                        adventurer.name.isNotEmpty 
                            ? adventurer.name[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      adventurer.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Level ${adventurer.level} ${adventurer.adventurerMaster?.profession ?? "Adventurer"}'),
                        Text(
                          'Trust: ${adventurer.trustLevel}% • ${_getStatusText(adventurer)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedAdventurerId = adventurer.id;
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedAdventurerId != null
              ? () {
                  // For now, we'll use a dummy ID. In a real implementation,
                  // this would be the adventurer instance ID from the backend
                  widget.onAdventurerSelected(1);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Send to Battle'),
        ),
      ],
    );
  }

  Color _getJobColor(String? profession) {
    switch (profession?.toLowerCase()) {
      case 'warrior':
        return Colors.red;
      case 'mage':
        return Colors.blue;
      case 'archer':
        return Colors.green;
      case 'thief':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(adventurer) {
    return adventurer.status;
  }
}