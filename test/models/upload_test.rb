require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  setup do
    @upload = uploads(:image)
  end

  test "#key" do
    assert_equal "#{@upload.id}/#{@upload.filename}", @upload.key
  end

  test "#url" do
    assert_match /https:\/\/.+/, @upload.url
  end

  test "#bucket" do
    assert_kind_of Aws::S3::Bucket, @upload.bucket
  end
end
