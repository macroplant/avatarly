require 'rfc822'
require 'pathname'
require 'unicode_utils'

class Avatarly
  BACKGROUND_COLORS = [
    '#ff4040', '#7f2020', '#cc5c33', '#734939', '#bf9c8f', '#995200',
    '#4c2900', '#f2a200', '#ffd580', '#332b1a', '#4c3d00', '#ffee00',
    '#b0b386', '#64664d', '#6c8020', '#c3d96c', '#143300', '#19bf00',
    '#53a669', '#bfffd9', '#40ffbf', '#1a332e', '#00b3a7', '#165955',
    '#00b8e6', '#69818c', '#005ce6', '#6086bf', '#000e66', '#202440',
    '#393973', '#4700b3', '#2b0d33', '#aa86b3', '#ee00ff', '#bf60b9',
    '#4d3949', '#ff00aa', '#7f0044', '#f20061', '#330007', '#d96c7b'
  ].freeze

  class << self
    def generate_avatar(text, opts = {})
      text = if opts[:lang]
               UnicodeUtils.upcase(initials(text.to_s.gsub(/[^[[:word:]] ]/, '').strip, opts), opts[:lang])
             else
               initials(text.to_s.gsub(/[^\w ]/, '').strip, opts).upcase
             end
      generate_image(text, parse_options(opts)).to_blob
    end

    def root
      File.expand_path '..', __dir__
    end

    def lib
      File.join root, 'lib'
    end

    private

    def fonts
      File.join root, 'assets/fonts'
    end

    def generate_image(text, opts)
      command = MiniMagick::Tool::Convert.new
      command.size "#{opts[:size]}x#{opts[:size]}"
      if text.length.positive?
        command.font opts[:font]
        command.fill opts[:font_color]
        command.gravity 'center'
        command.pointsize opts[:font_size]
        command.annotate  "+0+#{opts[:vertical_offset]}", text
      end
      command << "xc:#{opts[:background_color]}"
      command << "#{opts[:format]}:-"
      MiniMagick::Image.read(command.call)
    end

    def initials(text, opts)
      if opts[:separator]
        initials_for_separator(text, opts[:separator])
      elsif text.is_email?
        initials_for_separator(text.split('@').first, '.')
      elsif text.include?(' ')
        initials_for_separator(text, ' ')
      else
        initials_for_separator(text, '.')
      end
    end

    def initials_for_separator(text, separator)
      if text.include?(separator)
        text.split(separator).compact.map { |part| part[0] }.join
      else
        text[0] || ''
      end
    end

    def default_options
      { background_color: BACKGROUND_COLORS.sample,
        font_color: '#FFFFFF',
        size: 32,
        vertical_offset: 0,
        font: "#{fonts}/Roboto.ttf",
        format: 'png' }
    end

    def parse_options(opts)
      opts = default_options.merge(opts)
      opts[:size] = opts[:size].to_i
      opts[:font] = default_options[:font] unless Pathname(opts[:font]).exist?
      opts[:font_size] ||= opts[:size] / 2
      opts[:font_size] = opts[:font_size].to_i
      opts[:vertical_offset] = opts[:vertical_offset].to_i
      opts
    end
  end
end
