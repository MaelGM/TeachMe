enum AdvertisementState { active, hidden }

extension AdvertisementStateExtension on AdvertisementState {
  static AdvertisementState fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return AdvertisementState.active;
      case 'hidden':
        return AdvertisementState.hidden;
      default:
        throw ArgumentError('Invalid AdvertisementState: $value');
    }
  }

  String get name {
    switch (this) {
      case AdvertisementState.active:
        return 'active';
      case AdvertisementState.hidden:
        return 'hidden';
    }
  }
}
