import 'package:flutter/material.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/utils/image_helper.dart';

class PlantListItem extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  
  const PlantListItem({
    Key? key,
    required this.plant,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: ImageHelper.buildImage(plant.imagePath),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (plant.species.isNotEmpty)
                          Text(
                            plant.species,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: plant.categories.map((category) {
                            return Chip(
                              label: Text(
                                Plant.categoryToString(category),
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (plant.needsWatering())
                        Tooltip(
                          message: 'Needs watering',
                          child: Icon(
                            Icons.water_drop,
                            color: Colors.blue[400],
                          ),
                        ),
                      if (plant.needsFertilizing())
                        Tooltip(
                          message: 'Needs fertilizing',
                          child: Icon(
                            Icons.eco,
                            color: Colors.green[400],
                          ),
                        ),
                      if (plant.needsRepotting())
                        Tooltip(
                          message: 'Needs repotting',
                          child: Icon(
                            Icons.swap_horiz,
                            color: Colors.orange[400],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
