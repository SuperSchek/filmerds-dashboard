require 'locomotive/coal'
require 'json'
require 'net/http'
require 'uri'

require 'sendgrid-ruby'

class LocomotiveController < ActionController::Base

  def submit_podcast
    request_payload = JSON.parse request.body.read
    client = Locomotive::Coal::Client.new(ENV['LOCO_ENGINGE_URI'], { email: ENV['LOCO_ENGINE_MAIL'], api_key: ENV['LOCO_API_KEY'] })
    site_client = client.scope_by(ENV['LOCO_SITE_HANDLE'])

    s3_url_raw = request_payload['s3_url']
    s3_url_stripped = s3_url_raw[/[^?]+/]

    podcast = site_client.contents.podcasts.create(
        naam: request_payload['title'],
        categorie: request_payload['category'],
        omschrijving: request_payload['description'],
        # if ( request_payload['publication_date'].empty? )
        #     publication_date: DateTime.now,
        # else
        #     publication_date: DateTime.now,
        # end
        publication_date: request_payload['publication_date'],
        youtube_url: request_payload['podcast_yt_url'],
        s3_url: s3_url_stripped,
        s3_filesize: get_filesize_s3(s3_url_stripped),
        # podcast_length: get_audio_length(s3_url_stripped),
    )

    send_mail( request_payload['title'], request_payload['category'], request_payload['description'], request_payload['podcast_yt_url'], s3_url_stripped)

    render json: {
        "response": podcast
    }
  end

  def send_mail( name, category, description, yt_url, s3_url )
    from = Email.new(email: ENV['LOCO_ENGINE_MAIL'])
    subject = category + ' | ' + name + ' is geüpload naar filmerds.nl'
    to = Email.new(email: ENV['ADMIN_EMAIL'])
    content = Content.new(type: "text/html", value: "<html><body><h3>Er is een nieuwe podcast geüpload!</h3><h4>#{ category } | #{ name }</h4><p>#{ description }</p><ul><li>YouTube: #{ yt_url }</li><li>S3 URL: #{ s3_url }</li></ul></body></html>")
    mail = SendGrid::Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)

    puts response.status_code
    puts response.body
    puts response.headers
  end

    # Sends a head request to the S3 URL and returns filesize in bytes
    def get_filesize_s3(url)
        # Clean up the url to prevent S3 from returning application/json responses
        url = url.gsub "&amp;", "%26"
    
        # Build the request object
        uri = URI.parse(url)
        http =  Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Head.new(url)
    
        # Make the request
        resp = http.start{|http| http.request(req)}
    
        # Return the content-length value in the response
        return resp["content-length"]
    end

    # def get_audio_length(filepath)
    #     filepath = filepath.gsub "&amp;", "%26"
    #     filepath = filepath.gsub "&", "%26"

    #     pipe = "ffmpeg -i #{filepath} 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//"
    #     command = `#{pipe}`

    #     duration = command.slice(0..(command.index('.')))

    #     return duration[0..-2]
    # end

end