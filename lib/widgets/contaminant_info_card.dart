import 'package:flutter/material.dart';

class ContaminantInfoCard extends StatelessWidget {
  final String contaminantName;
  final String description;
  final List<String> healthEffects;
  final String epaLimit;
  final Color color;
  final IconData icon;

  const ContaminantInfoCard({
    required this.contaminantName,
    required this.description,
    required this.healthEffects,
    required this.epaLimit,
    required this.color,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          contaminantName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Effects:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...healthEffects.map((effect) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.circle, size: 6, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              effect,
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: color, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          epaLimit,
                          style: TextStyle(
                            fontSize: 13,
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
        ],
      ),
    );
  }

  static ContaminantInfoCard forPFOA() {
    return ContaminantInfoCard(
      contaminantName: 'PFOA (Perfluorooctanoic Acid)',
      description: 'Synthetic "forever chemical" that persists in the environment',
      healthEffects: [
        'Linked to kidney and testicular cancer',
        'Affects liver function and cholesterol levels',
        'Impacts immune system development',
        'Bioaccumulates in the human body',
      ],
      epaLimit: 'EPA Limit: 4 parts per trillion (ppt)',
      color: Colors.blue,
      icon: Icons.science,
    );
  }

  static ContaminantInfoCard forPFOS() {
    return ContaminantInfoCard(
      contaminantName: 'PFOS (Perfluorooctane Sulfonate)',
      description: 'Another PFAS chemical found in firefighting foam and consumer products',
      healthEffects: [
        'Associated with thyroid disease',
        'Affects immune system function',
        'Potential reproductive effects',
        'Persists indefinitely in environment',
      ],
      epaLimit: 'EPA Limit: 4 parts per trillion (ppt)',
      color: Colors.purple,
      icon: Icons.warning_amber,
    );
  }

  static ContaminantInfoCard forLead() {
    return ContaminantInfoCard(
      contaminantName: 'Lead',
      description: 'Toxic metal with no safe level of exposure',
      healthEffects: [
        'Severe developmental issues in children',
        'Damages nervous system and brain',
        'Impairs cognitive function and learning',
        'Accumulates in bones and organs',
      ],
      epaLimit: 'EPA Action Level: 15 parts per billion (ppb)',
      color: Colors.red,
      icon: Icons.dangerous,
    );
  }

  static ContaminantInfoCard forNitrate() {
    return ContaminantInfoCard(
      contaminantName: 'Nitrate',
      description: 'Common contaminant from agricultural runoff',
      healthEffects: [
        'Causes "blue baby syndrome" in infants',
        'May increase cancer risk',
        'Indicates possible bacterial contamination',
        'Contributes to harmful algal blooms',
      ],
      epaLimit: 'EPA Maximum Contaminant Level: 10 ppm',
      color: Colors.orange,
      icon: Icons.agriculture,
    );
  }

  static ContaminantInfoCard forArsenic() {
    return ContaminantInfoCard(
      contaminantName: 'Arsenic',
      description: 'Naturally occurring element that can be highly toxic',
      healthEffects: [
        'Increases risk of multiple cancers',
        'Affects cardiovascular system',
        'Causes skin lesions and disorders',
        'Impacts neurological development',
      ],
      epaLimit: 'EPA Maximum Contaminant Level: 10 ppb',
      color: Colors.green,
      icon: Icons.landscape,
    );
  }
}
