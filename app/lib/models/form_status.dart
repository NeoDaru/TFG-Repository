class FormStatus {
  const FormStatus({this.isLoading = false, this.error, this.success});

  final bool isLoading;
  final String? error;
  final String? success;
}