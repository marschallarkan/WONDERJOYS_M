import 'package:wonderjoys/exceptions/local_files_handling/local_file_handling_exception.dart';

import 'local_file_handling_exception.dart';

class LocalImagePickingException extends LocalFileHandlingException {
  LocalImagePickingException(
      {String message = "Istanza dell'eccezione ImagePicker"})
      : super(message);
}

class LocalImagePickingInvalidImageException
    extends LocalImagePickingException {
  LocalImagePickingInvalidImageException(
      {String message = "L'immagine scelta non è valida"})
      : super(message: message);
}

class LocalImagePickingFileSizeOutOfBoundsException
    extends LocalImagePickingException {
  LocalImagePickingFileSizeOutOfBoundsException(
      {String message = "Dimensioni dell'immagine non comprese nell'intervallo specificato"})
      : super(message: message);
}

class LocalImagePickingInvalidImageSourceException
    extends LocalImagePickingException {
  LocalImagePickingInvalidImageSourceException(
      {String message = "La fonte dell'immagine non è valida"})
      : super(message: message);
}

class LocalImagePickingUnknownReasonFailureException
    extends LocalImagePickingException {
  LocalImagePickingUnknownReasonFailureException(
      {String message = "Fallito per motivo sconosciuto"})
      : super(message: message);
}
