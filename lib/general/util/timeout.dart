Future timeout(Future future, {int seconds = 10}) {
  return Future.any([future, Future.delayed(Duration(seconds: seconds))]);
}
