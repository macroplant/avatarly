module AvatarExpectations
  def resource_file(name)
    File.expand_path("../../fixtures/#{name}", __FILE__)
  end

  def compare(actual_image_path, expected_image_path, alg)
    tmp_file = Tempfile.new(SecureRandom.hex(8).to_s)
    compare = MiniMagick::Tool::Compare.new(whiny: false)
    compare.metric(alg)
    compare << actual_image_path
    compare << expected_image_path
    compare << tmp_file.path
    data = nil
    compare.call do |_stdout, stderr, _status|
      data = stderr
    end
    tmp_file.unlink
    data
  end

  def assert_image_equality(actual_image_blob, expected_image_name, distance = 0)
    actual_image_path = resource_file('temp_generated_image.png')
    expected_image_path = resource_file("#{expected_image_name}.png")

    File.open(actual_image_path, 'wb') do |f|
      f.write actual_image_blob
    end

    actual_image = MiniMagick::Image.open(actual_image_path)
    expected_image = MiniMagick::Image.open(expected_image_path)

    compare_result = compare(actual_image, expected_image, 'AE').to_i
    result = (compare_result <= distance)

    puts "Distance between two images: #{compare_result}. Required at least #{distance}." unless result

    expect(result).to be true

    File.delete(actual_image_path)
  end

  def assert_image_format(image, format)
    temp_file = Tempfile.new('avatarly')
    File.open(temp_file, 'wb') do |f|
      f.write image
    end

    expect(FastImage.type(temp_file)).to eql(format)
  end
end
