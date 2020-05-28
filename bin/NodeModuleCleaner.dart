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
    print('');
    print('Number of found node_modules: $len');
    print('');

    if (len > 0) {
      deleteFolders(listOfDirs);
    } else {
      print('No folder to delete!!');
      print('');
      stdout.write('Press ENTER to exit: ');
      var ex = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));
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
          // If the duplicate value is 0 then it's the node_modules root
          // if value is bigger than 0
          // then it must be a directory inside node_modules folder.
          // We only need the root folder so add it to the list for deletion.
          if (countDuplicates(pathList) == 0) {
            folderList.add(entity.path);
          }
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

// TODO only look for duplicates of 'node_modules' .
int countDuplicates(List<String> duplicates) {
  return duplicates.length - duplicates.toSet().toList().length;
}

void deleteFolders(List<String> deleteList) async {
  for (var item in deleteList) {
    print(item);
  }

  print('');
  print('');
  stdout.write('Enter Y to delete listed folders: ');
  var value = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));

  if (value.trim().toLowerCase() == 'y') {
    for (var item in deleteList) {
      try {
        await Directory(item).delete(recursive: true);
        print('Deleted: $item');
      } catch (err) {
        print(err);
      }
    }
  }

  print('');
  stdout.write('Press ENTER to exit: ');
  var ex = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));
}

// Return directory slash according to host platform
String getSlashForPlatform() {
  var dirSlash = '/'; // MacOS and Linux

  if (Platform.isWindows) {
    dirSlash = '\\'; // Escaped backslash for windows.
  }

  return dirSlash;
}
