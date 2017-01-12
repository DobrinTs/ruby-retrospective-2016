module ParserHelpers
  def parse_arguments(command_runner, argv)
    to_parse_args_index = 0
    argv.each do |argument|
      next if argument[0] == '-'
      @to_parse_args[to_parse_args_index][0].call(command_runner, argument)
      to_parse_args_index += 1
    end
  end

  def parse_options(command_runner, argv)
    @to_parse_options.each do |current|
      if argv.include?("-#{current[1]}") || argv.include?("--#{current[2]}")
        current[0].call(command_runner, true)
      end
    end
  end

  def parse_options_with_parameters(command_runner, argv)
    @to_parse_opt_with_param.each do |option|
      argv.each do |argument|
        essentials = argument[2..-1]
        option[1] == argument[1] && option[0].call(command_runner, essentials)
        opt_name, opt_param = essentials.split('=')
        option[2] == opt_name && option[0].call(command_runner, opt_param)
      end
    end
  end
end

class CommandParser
  include ParserHelpers
  def initialize(command_name)
    @command_name = command_name
    @to_parse_args = []
    @to_parse_options = []
    @to_parse_opt_with_param = []
  end

  def argument(name, &block)
    @to_parse_args << [block, name]

  end

  def option(short_name, long_name, text, &block)
    @to_parse_options << [block, short_name, long_name, text]
  end

  def option_with_parameter(short_name, long_name, text, plholder, &block)
    @to_parse_opt_with_param << [block, short_name, long_name, text, plholder]
  end

  def parse(command_runner, argv)
    parse_arguments(command_runner, argv)
    parse_options(command_runner, argv)
    parse_options_with_parameters(command_runner, argv)
  end

  def help
    result = "Usage: #{@command_name} "
    @to_parse_args.each { |argument| result << '[' + argument[1] + '] ' }
    result = result.chop
    @to_parse_options.each do |option|
      result << "\n    -#{option[1]}, --#{option[2]} #{option[3]}"
    end
    @to_parse_opt_with_param.each do |option|
      result << "\n    -#{option[1]}, --#{option[2]}=#{option[4]} #{option[3]}"
    end
    result
  end
end
