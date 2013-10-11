#!/usr/bin/ruby -w
# ctape: write data onto a Compact Cassette
# (c) windytan / Oona Räisänen
# ISC license

require 'yaml'

class TapeWriter

  DEFAULTS = { 'bitlen' =>  16,
               'device' =>  '--default-device',
               'volume' =>  0.98,
             }

  def initialize(conf)
    conf = DEFAULTS.merge(conf)
    @bit_length = conf['bitlen']
    @device = conf['device']
    @volume = conf['volume']
  end

  def work
    calibrate_polarity
    write_lead_in
    sync_sequence
    write_input
  ensure
    terminate
  end

  def terminate
    sox.close
  end

private

  def sox_command
    <<-SOX.strip.gsub(/\s+/, ' ')
      sox
        --no-show-progress
        --type .raw
        --rate 44100
        --channels 1
        --bits 16
        --encoding signed-integer
        -
        #{@device}
    SOX
  end

  def sox
    return @sox if instance_variable_defined? :@sox
    @sox = IO.popen(sox_command,'w')
  end

  def putbyte(value)
    putbit 1
    0.upto(7) { |i| putbit((value>>(7-i)) & 1) }
    putbit 0
  end

  def putbit(value)
    if value == 1
      @bit_length.times     { sox.write [-0x7FFF * @volume].pack("s") }
      @bit_length.times     { sox.write [ 0x7FFF * @volume].pack("s") }
    else
      (@bit_length/2).times { sox.write [-0x7FFF * @volume * 0.5].pack("s") }
      (@bit_length/2).times { sox.write [ 0x7FFF * @volume * 0.5].pack("s") }
    end
  end

  def calibrate_polarity
    200.times do
      @bit_length.times     { sox.write [-0x7FFF * @volume].pack("s") }
      (3*@bit_length).times { sox.write [ 0x7FFF * @volume].pack("s") }
    end
  end

  def write_lead_in
    20.times { putbyte 0xFF }
  end

  def sync_sequence
    for i in [0x08, 0x07, 0x05, 0x04] do putbyte(i) end
  end

  def write_input
    until STDIN.eof?
      putbyte STDIN.read(1).unpack('C')[0]
    end
  end

end

conf = YAML::load(File.open('config.yml'))
TapeWriter.new(conf).work
