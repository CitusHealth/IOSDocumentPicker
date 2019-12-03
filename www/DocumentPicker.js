var DocuPicker = {};

DocuPicker.callFunction = function(
  successCallback,
  errorCallback,
  action,
  param
) {
  cordova.exec(successCallback, errorCallback, "DocumentPicker", action, param);
};

module.exports = DocuPicker;
