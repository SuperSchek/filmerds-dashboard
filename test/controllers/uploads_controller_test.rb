require 'test_helper'

class UploadsControllerTest < ActionDispatch::IntegrationTest
  test "creates a new upload" do
    params = { filename: "image.jpg", size: 1.megabyte }

    assert_difference("Upload.count") do
      post uploads_url, params: params
    end
  end

  test "invalid params doesn't create an upload" do
    params = { filename: "image.jpg", size: 10.megabyte }

    assert_no_difference("Upload.count") do
      post uploads_url, params: params
    end
  end

  test "invalid params returns 403" do
    params = { filename: "image.jpg", size: 10.megabyte }

    post uploads_url, params: params

    assert_equal 403, response.status
  end
end
