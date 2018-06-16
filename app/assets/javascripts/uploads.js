$(document).on( 'ready', () => {
  $( () => {
    $('#datetimepicker').datetimepicker({
        locale: 'nl'
    });
  });
});

$(document).on('change', '#podcast_audio', (delegatedEvent) => {
  var event          = delegatedEvent.originalEvent;
  var csrfToken      = $('[name="authenticity_token"]').val();
  var presignBaseUrl = $('form').attr('action');

  [].forEach.call(event.target.files, (file) => {
    var filename   = encodeURIComponent(file.name);
    var size       = encodeURIComponent(file.size);
    var uploader   = new S3(csrfToken);
    var presignUrl = presignBaseUrl +
                      '?filename=' + filename +
                      '&size=' + size +
                      '&acl=public-read' +
                      '&t=' + Date.now();

    uploader.on('upload:success', (accessUrl) => {
      $('form').append('<p><a target="_blank" href="'+accessUrl+'">'+file.name+'</a></p>');
      $('#s3Upload').fadeOut();
      $('.status').text('Submitting data to Filmerds website!');

      let podcast = new Object();
      podcast.title = $('#podcast_title').val();
      podcast.category = $('#podcast_category').val();
      podcast.description = $('#podcast_description').val();
      podcast.podcast_yt_url = $('#podcast_yt_url').val();
      podcast.s3_url = accessUrl;

      const publication_datetime = $('.datetimepicker_input').val();
      if ( publication_datetime === '' ) {
        podcast.publication_date = moment().format();
      } else {
        podcast.publication_date = moment( publication_datetime, "DD-MM-YYYY HH:mm" ).format();
      }

      $.ajax({
        async: false,
        crossDomain: true,
        method: 'POST',
        headers: {
          "Content-Type": "application/json"
        },
        url: "/submit_podcast",
        data: JSON.stringify(podcast),
        success: (result) => {
          $(".status").text("Klaar! Podcast staat op de website!");
          console.log(result)
        }
      });
    });

    uploader.on('upload:progress', (event) => {
      let progress = event.loaded / event.total * 100;
      $('#s3Uplaod').css('width', Math.round(progress) + "%");
    });

    $('form').on('submit', (e) => {
      e.preventDefault();
      uploader.upload(presignUrl, file);
      $('.loader').fadeIn();
    });
  });
});