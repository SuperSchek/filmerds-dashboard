class Upload < ApplicationRecord
  validates :size, inclusion: { in: 0..150.megabytes }

  def key
    "#{id}/#{filename}"
  end

  def url
    bucket.object(key).presigned_url(:get, expires_in: 604_800)
  end

  def bucket
    @bucket ||= Aws::S3::Resource.new.bucket(ENV["AWS_S3_BUCKET"])
  end
end
