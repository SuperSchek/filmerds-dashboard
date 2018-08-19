require 'locomotive/coal'
require 'json'
require 'net/http'
require 'uri'

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

    render json: {
        "response": podcast
    }
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