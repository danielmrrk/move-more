final emailPattern = RegExp(
    r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$");
final usernamePattern = RegExp(r"^[a-zA-Z0-9._]{3,16}$");
final usernameInvalidCharPattern = RegExp(r"[^a-zA-Z0-9._]");
