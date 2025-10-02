class Config {
  // set to production before release build:
  static final database = DatabaseInstance.staging;
}

enum DatabaseInstance {
  staging('staging'),
  production('(default)');

  final String name;
  const DatabaseInstance(this.name);
}
