import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Info & Legal")),
      body: ListView(
        children: [
          ListTile(
            title: Text("About ChronoHolidder"),
            subtitle: Text("Version 1.0.0 (Release Candidate)"),
            leading: Icon(Icons.info_outline),
          ),
          Divider(),
          ListTile(
            title: Text("Privacy Policy"),
            leading: Icon(Icons.privacy_tip_outlined),
            onTap: () async {
              // In a real release, this would be a hosted https URL.
              // For now we assume it's hosted or file-based. 
              final url = Uri.parse("https://your-domain.com/chronoholidder/privacy.html");
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
          ),
          ListTile(
            title: Text("Terms of Service"),
            leading: Icon(Icons.description_outlined),
            onTap: () async {
              final url = Uri.parse("https://your-domain.com/chronoholidder/terms.html");
              if (await canLaunchUrl(url)) await launchUrl(url);
            },
          ),
          Divider(),
          ListTile(
            title: Text("Attributions"),
            subtitle: Text("Data from Wikidata & GBIF. Map tiles by OpenStreetMap."),
            leading: Icon(Icons.copyright),
          )
        ],
      ),
    );
  }
}
