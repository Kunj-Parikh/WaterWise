import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Contaminant Information'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroCard(),
              const SizedBox(height: 24),
              _buildPollutantSection(
                'PFOA (Perfluorooctanoic Acid)',
                'PFOA is a synthetic chemical that belongs to the PFAS family (Per- and polyfluoroalkyl substances).',
                'PFOA is concerning because:',
                [
                  'Extremely persistent in the environment ("forever chemicals")',
                  'Bioaccumulates in wildlife and humans',
                  'Linked to various health issues including cancer and liver damage',
                  'Common in non-stick cookware, water-resistant clothing, and firefighting foam',
                  'Can contaminate drinking water sources and persist for decades',
                ],
                'EPA Limit: 4 parts per trillion (ppt)',
                Colors.blue,
                Icons.science,
              ),
              const SizedBox(height: 20),
              _buildPollutantSection(
                'PFOS (Perfluorooctane Sulfonate)',
                'PFOS is another PFAS chemical similar to PFOA, used in various industrial and consumer products.',
                'PFOS is concerning because:',
                [
                  'Extremely persistent "forever chemical"',
                  'Accumulates in human blood and organs',
                  'Associated with thyroid disease and immune system effects',
                  'Found in firefighting foam and stain-resistant products',
                  'Contaminates groundwater near military bases and airports',
                ],
                'EPA Limit: 4 parts per trillion (ppt)',
                Colors.purple,
                Icons.warning_amber,
              ),
              const SizedBox(height: 20),
              _buildPollutantSection(
                'Lead',
                'Lead is a naturally occurring toxic metal that has no safe level in drinking water.',
                'Lead is harmful because:',
                [
                  'Causes severe developmental issues in children',
                  'Damages the nervous system and brain function',
                  'Can enter water through corroded plumbing and old paint',
                  'No safe level of exposure, especially for children',
                  'Accumulates in the body over time',
                ],
                'EPA Action Level: 15 parts per billion (ppb)',
                Colors.red,
                Icons.dangerous,
              ),
              const SizedBox(height: 20),
              _buildPollutantSection(
                'Nitrate',
                'Nitrate is a compound that occurs naturally and from human activities, primarily agriculture.',
                'Nitrate is concerning because:',
                [
                  'Primarily from agricultural fertilizers and animal waste',
                  'Can cause "blue baby syndrome" in infants',
                  'Contributes to algal blooms in water bodies',
                  'Indicates possible bacterial contamination',
                  'Common in areas with intensive agriculture',
                ],
                'EPA Limit: 10 parts per million (ppm)',
                Colors.orange,
                Icons.agriculture,
              ),
              const SizedBox(height: 20),
              _buildPollutantSection(
                'Arsenic',
                'Arsenic is a naturally occurring element that can be highly toxic in drinking water.',
                'Arsenic is dangerous because:',
                [
                  'Can cause various types of cancer',
                  'Enters water through natural deposits and industrial processes',
                  'Long-term exposure affects multiple organ systems',
                  'Can contaminate both surface and groundwater',
                  'Particularly concerning in areas with mining activity',
                ],
                'EPA Limit: 10 parts per billion (ppb)',
                Colors.green,
                Icons.landscape,
              ),
              const SizedBox(height: 24),
              _buildResourcesCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Understanding Water Contaminants',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Water quality is essential for public health. Learn about the common contaminants found in drinking water, their health effects, and EPA safety limits.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantSection(
    String title,
    String intro,
    String concernsTitle,
    List<String> concerns,
    String epaLimit,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              intro,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              concernsTitle,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...concerns.map((concern) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 8, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          concern,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      epaLimit,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bookmarks, color: Colors.teal, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Additional Resources',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildResourceItem(
              'EPA Water Quality Database',
              'Access official water quality data and standards',
              Icons.public,
            ),
            _buildResourceItem(
              'Local Water Utility Reports',
              'Check your local water utility for consumer confidence reports',
              Icons.location_city,
            ),
            _buildResourceItem(
              'Water Testing Services',
              'Consider testing your water if you have concerns',
              Icons.science_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
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