import '../config/flavor_config.dart';

// List of flavors that should have access to the feature
const List<String> allowedFlavors = ['women_puzzle'];

bool isFeatureEnabled() {
  return allowedFlavors.contains(FlavorConfig.instance!.flavor.name);
}
