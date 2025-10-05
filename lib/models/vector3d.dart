import 'dart:math';

/// 3D pozisyon vektörü
class Vector3D {
  final double x, y, z;
  
  const Vector3D(this.x, this.y, this.z);
  
  Vector3D operator +(Vector3D other) {
    return Vector3D(x + other.x, y + other.y, z + other.z);
  }
  
  Vector3D operator -(Vector3D other) {
    return Vector3D(x - other.x, y - other.y, z - other.z);
  }
  
  Vector3D operator *(double scalar) {
    return Vector3D(x * scalar, y * scalar, z * scalar);
  }
  
  double get magnitude {
    return sqrt(x * x + y * y + z * z);
  }
  
  Vector3D get normalized {
    final mag = magnitude;
    return mag > 0 ? Vector3D(x / mag, y / mag, z / mag) : const Vector3D(0, 0, 0);
  }
  
  double dot(Vector3D other) {
    return x * other.x + y * other.y + z * other.z;
  }
  
  Vector3D cross(Vector3D other) {
    return Vector3D(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }
  
  @override
  String toString() {
    return 'Vector3D($x, $y, $z)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vector3D && other.x == x && other.y == y && other.z == z;
  }
  
  @override
  int get hashCode => Object.hash(x, y, z);
}
