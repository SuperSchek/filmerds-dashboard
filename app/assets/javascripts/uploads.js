$(document).on('change', 'input[type="file"]', function(delegatedEvent) {
  var event = delegatedEvent.originalEvent;
  var csrfToken = $('[name="authenticity_token"]').val();
  var presignBaseUrl = $('form').attr('action');

  [].forEach.call(event.target.files, function(file) {
    var filename   = encodeURIComponent(file.name);
    var size   = encodeURIComponent(file.size);
    var uploader   = new S3(csrfToken);
    var presignUrl = presignBaseUrl +
                      '?filename=' + filename +
                      '&size=' + size +
                      '&t=' + Date.now();

    uploader.on('upload:success', function(accessUrl) {
      $('form').append('<p><a target="_blank" href="'+accessUrl+'">'+file.name+'</a></p>');
    });

    uploader.on('upload:progress', function(event) {
      var progress = event.loaded / event.total * 100;
      $('form').append('<div>Progress: '+progress+'</div>')
    });

    uploader.upload(presignUrl, file);
  });
});
