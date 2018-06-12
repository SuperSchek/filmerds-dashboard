# Handle file uploads to S3
class UploadsController < ApplicationController

  def new
    @upload = Upload.new
  end

  # Step 1: POST to app to get the presignature URL
  def create
    @upload = Upload.create!(upload_params)
    render json: signature # Step 2: Return the presigned URL after doing some validations
  rescue
    head :forbidden
  end

  private

  def upload_params
    params.permit(:size, :filename)
  end

  def signature
    signature = @upload.bucket.presigned_post(signature_options)

    {
      url: signature.url,
      fields: signature.fields,
      accessUrl: @upload.url
    }
  end

  def signature_options
    {
      key: @upload.key,
      acl: "public-read",
      content_length_range: 0..50.megabytes # Enforce a filesize limit
    }
  end
end