S3 = function(csrfToken) {
  var handlers = [];
  var obj = this;

  var isSuccess = function(xhr) {
    return (xhr.status >= 200 && xhr.status < 300) || xhr.status === 304;
  };

  var formData = function(file, fields) {
    var data = new FormData();

    if (fields) {
      Object.keys(fields).forEach(function(key) {
        data.append(key, fields[key]);
      });
    }

    data.append('file', file);

    return data;
  };

  var emit = function(eventName) {
    for (var list = handlers[eventName], i = 0; list && list[i];) {
        list[i++].apply(obj, list.slice.call(arguments, 1));
    };

    return obj;
  };

  var presignFailure = function(xhr) {
    emit('presign:failure');
    emit('upload:failure');
  };

  // Event Emitter functions
  this.on = function(eventName, handler) {
    (handlers[eventName] = handlers[eventName] || []).push(handler);

    return obj;
  };

  this.upload = function(presignUrl, file) {
    emit('presign:start');
    var presignXhr = new XMLHttpRequest();

    presignXhr.addEventListener('load', function() {
      var presignReqData = JSON.parse(presignXhr.responseText);
      var accessUrl = presignReqData.accessUrl;
      emit('presign:complete');

      if (isSuccess(presignXhr)) {
        emit('presign:success');
        var uploadXhr = new XMLHttpRequest();
        uploadXhr.accessUrl = accessUrl;

        uploadXhr.addEventListener('load', function() {
          if (isSuccess(uploadXhr)) {
            emit('upload:success', accessUrl);
          } else {
            emit('upload:failure', uploadXhr);
          };
        });

        uploadXhr.upload.addEventListener('progress', function(progressEvent) {
          emit('upload:progress', progressEvent);
        });

        uploadXhr.open('POST', presignReqData.url);
        uploadXhr.send(formData(file, presignReqData.fields));

        emit('upload:start');
      } else {
        presignFailure();
      };
    });

    presignXhr.addEventListener('error', presignFailure);
    presignXhr.addEventListener('abort', presignFailure);

    presignXhr.open('POST', presignUrl, true);
    presignXhr.setRequestHeader('X-CSRF-Token', csrfToken);
    presignXhr.send();
  };
};
