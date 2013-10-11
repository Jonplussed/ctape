require 'minitest/spec'
require 'minitest/autorun'
require 'fileutils'

describe 'tape-write' do

  it 'should match our expected output' do
    system 'touch ./device.wav && rm ./device.wav'
    system 'ruby ../tape-write.rb < ./expected'
    FileUtils.compare_file('./expected.wav', './device.wav').must_equal true
  end

end
