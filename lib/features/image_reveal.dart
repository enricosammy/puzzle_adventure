import '../config/flavor_config.dart';
import 'package:flutter/foundation.dart'; // Add this at the top of your file


const List<String> allowedFlavors = ['women_puzzle'];

bool isFeatureEnabled() {
  return allowedFlavors.contains(FlavorConfig.instance!.flavor.name);
}

// Test function to confirm access
void testFeatureAccess() {
  if (isFeatureEnabled()) {
    debugPrint('✅ Image Reveal Feature is enabled for ${FlavorConfig.instance!.flavor.name}');
  } else {
    debugPrint('🚫 Image Reveal Feature is NOT available for ${FlavorConfig.instance!.flavor.name}');
  }
}
