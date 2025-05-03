enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(double width) {
  if (width >= 1024) return DeviceType.desktop;
  if (width >= 600) return DeviceType.tablet;
  return DeviceType.mobile;
}
