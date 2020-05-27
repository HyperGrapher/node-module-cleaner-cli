import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  getUserInput();
}

// Check if the user input is a valid directory
void getUserInput() async {
  stdout.write('Enter the root path for searching node_module directories: ');
  var value = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));

  // Validate directory and continue
  if (await FileSystemEntity.isDirectory(value)) {
    findNodeModuleFolders(value);
  } else {
    stderr.writeln('error: $value is not a valid directory');
    exitCode = 2;
  }
}

void findNodeModuleFolders(String value) {
  var path = Directory(value);
  path
      .list(recursive: true, followLinks: false)
      .listen((FileSystemEntity entity) async {
    if (await FileSystemEntity.isDirectory(entity.path)) {
      List pathList = entity.path.split(getSlashForPlatform());
      // Don't traverse hidden folders such as .git
      if (!(pathList.last).toString().startsWith('.')) {
        if (pathList.last == 'node_modules') {
          try {
            await Directory(entity.path).delete(recursive: true);
            print(entity.path);
          } catch (err) {
            print(err);
          }
        }
      }
    }
  });
}

String getSlashForPlatform() {
  // assign directory slash according to host platform
  var dirSlash = '/';

  if (Platform.isWindows) {
    dirSlash = '\\';
  } else if (Platform.isMacOS || Platform.isLinux) dirSlash = '/';

  return dirSlash;
}
