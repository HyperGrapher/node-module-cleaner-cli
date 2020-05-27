import 'dart:async';
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
    var listOfDirs = await findNodeModuleFolders(value);
    var len = listOfDirs.length;
    print('Number of found node_modules: $len');

    if (len > 0) {
      print('Deleting');
    } else {
      print('No folder is deleted!!');
    }
  } else {
    stderr.writeln('error: Given path is not a valid directory');
    stderr.writeln('Given path: $value');
    exitCode = 2;
  }
}

Future<List<String>> findNodeModuleFolders(String value) async {
  var path = Directory(value);
  var folderList = <String>[];

  // Completer holds a list as a future to be completed.
  var completer = Completer<List<String>>();

  var searchStreamSubscription = path
      .list(recursive: true, followLinks: false)
      .listen((FileSystemEntity entity) async {
    if (await FileSystemEntity.isDirectory(entity.path)) {
      List pathList = entity.path.split(getSlashForPlatform());
      // Don't traverse hidden folders such as .git
      if (!(pathList.last).toString().startsWith('.')) {
        if (pathList.last == 'node_modules') {
          folderList.add(entity.path);
        }
      }
    }
  });

  // when folder searching is finished
  // pass the folderList and complete the future
  searchStreamSubscription.onDone(() {
    completer.complete(folderList);
  });

  // initially returns incomplete future.
  // So you can await it and
  // get the data when it is complete.
  return completer.future;
}

// Return directory slash according to host platform
String getSlashForPlatform() {
  var dirSlash = '/'; // MacOS and Linux

  if (Platform.isWindows) {
    dirSlash = '\\'; // Escaped backslash for windows.
  }

  return dirSlash;
}
