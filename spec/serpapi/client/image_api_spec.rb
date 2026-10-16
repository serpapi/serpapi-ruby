require 'spec_helper'
require 'stringio'
require 'tempfile'

describe 'Image API' do
  let(:response) do
    double(
      status: 200,
      body: '{"message":"Image uploaded successfully.","image_id":"test-image-id"}'
    )
  end
  let(:socket) { double }
  let(:client) { SerpApi::Client.new(api_key: api_key) }

  before do
    allow(HTTP).to receive(:timeout).and_return(double(persistent: socket))
    allow(response).to receive(:flush)
  end

  it 'uploads an image from a file path' do
    Tempfile.create(['image', '.png']) do |image|
      expect(socket).to receive(:post) do |endpoint, options|
        uploaded_image = options[:form][:image]

        expect(endpoint).to eq('/image')
        expect(uploaded_image.filename).to end_with('.png')
        response
      end

      result = client.upload_image(image.path)

      expect(result[:message]).to eq('Image uploaded successfully.')
      expect(result[:image_id]).to eq('test-image-id')
    end
  end

  it 'rewinds and uploads an image from an IO object' do
    image = StringIO.new('image data')
    image.read(5)

    expect(socket).to receive(:post) do |endpoint, options|
      expect(endpoint).to eq('/image')
      expect(image.pos).to eq(0)
      response
    end

    result = client.upload_image(image)

    expect(result[:image_id]).to eq('test-image-id')
  end

  it 'raises an error when image is rejected' do
    error_response = double(
      status: 400,
      body: '{"error":"Invalid image format. Supported format: jpg, jpeg, png, webp"}'
    )
    allow(socket).to receive(:post).with('/image', anything).and_return(error_response)

    expect {
      client.upload_image(StringIO.new('invalid image data'))
    }.to raise_error(
      SerpApi::SerpApiError,
      /Invalid image format\. Supported format: jpg, jpeg, png, webp/
    )
  end
end
