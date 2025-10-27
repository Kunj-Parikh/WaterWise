import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pollutant Info'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildPollutantSection(
              'PFOA ion (Perfluorooctanoic Acid)',
              'PFOA is a synthetic chemical that belongs to the PFAS family (Per- and polyfluoroalkyl substances). It is concerning because:\n\n'
              '- Extremely persistent in the environment ("forever chemicals")\n'
              '- Bioaccumulates in wildlife and humans\n'
              '- Linked to various health issues including cancer and liver damage\n'
              '- Common in non-stick cookware, water-resistant clothing, and firefighting foam\n'
              '- Can contaminate drinking water sources and persist for decades',
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildPollutantSection(
              'Lead',
              'Lead is a naturally occurring toxic metal that can be extremely harmful:\n\n'
              '- Causes severe developmental issues in children\n'
              '- Damages the nervous system and brain function\n'
              '- Can enter water through corroded plumbing and old paint\n'
              '- No safe level of exposure, especially for children\n'
              '- Accumulates in the body over time',
              Colors.red,
            ),
            const SizedBox(height: 20),
            _buildPollutantSection(
              'Nitrate',
              'Nitrate is a compound that occurs naturally and from human activities:\n\n'
              '- Primarily from agricultural fertilizers and animal waste\n'
              '- Can cause "blue baby syndrome" in infants\n'
              '- Contributes to algal blooms in water bodies\n'
              '- Indicates possible bacterial contamination\n'
              '- Common in areas with intensive agriculture',
              Colors.orange,
            ),
            const SizedBox(height: 20),
            _buildPollutantSection(
              'Arsenic',
              'Arsenic is a naturally occurring element that can be highly toxic:\n\n'
              '- Can cause various types of cancer\n'
              '- Enters water through natural deposits and industrial processes\n'
              '- Long-term exposure affects multiple organ systems\n'
              '- Can contaminate both surface and groundwater\n'
              '- Particularly concerning in areas with mining activity',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollutantSection(String title, String content, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  

}