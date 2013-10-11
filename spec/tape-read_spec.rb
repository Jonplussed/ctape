require 'minitest/spec'
require 'minitest/autorun'
require 'digest/md5'

describe 'tape-read' do

  before do
    system 'ruby ../tape-write.rb < ./expected'
  end

  EXPECTED_OUTPUT = File.read './expected'

  it 'originally matches the output but drops the last character' do
    data = IO.popen('ruby ../tape-read.rb', 'r').read
    data.must_equal EXPECTED_OUTPUT[0..-2]
  end

end
