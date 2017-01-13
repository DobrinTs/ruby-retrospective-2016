module ParserHelpers
  def parse_arguments(command_runner, argv)
    to_parse_args_index = 0
    argv.each do |argument|
      next if argument[0] == '-'
      @to_parse_args[to_parse_args_index].block.call(command_runner, argument)
      to_parse_args_index += 1
    end
  end

  def parse_options(command_runner, argv)
    @to_parse_options.each do |current|
      if argv.include?(current.short) || argv.include?(current.long)
        current.block.call(command_runner, true)
      end
    end
  end

  def parse_options_with_parameters(command_runner, argv)
    @to_parse_options_with_parameters.each do |option|
      argv.each do |argument|
        if option.short[1] == argument[1]
          option.block.call(command_runner, argument[2..-1])
        end
        if option.long[2..-1] == argument[2..-1].split('=')[0]
          option.block.call(command_runner, argument[2..-1].split('=')[1])
        end
      end
    end
  end
end

class CommandParser
  include ParserHelpers
  class Argument
    attr_accessor :name, :block

    def initialize(name, block)
      @name = name
      @block = block
    end
  end

  class Option
    attr_accessor :short, :long, :help, :block

    def initialize(short, long, help, block)
      @short = '-' + short
      @long = '--' + long
      @help = help
      @block = block
    end

    def to_s
      "\n    #{short}, #{long} #{help}"
    end
  end

  class OptionWithParameter < Option
    attr_accessor :placeholder

    def initialize(short, long, help, placeholder, block)
      super(short, long, help, block)
      @placeholder = placeholder
    end

    def to_s
      "\n    #{short}, #{long}=#{placeholder} #{help}"
    end
  end

  def initialize(command_name)
    @command_name = command_name
    @to_parse_args = []
    @to_parse_options = []
    @to_parse_options_with_parameters = []
  end

  def argument(name, &block)
    @to_parse_args << Argument.new(name, block)
  end

  def option(short, long, help, &block)
    @to_parse_options << Option.new(short, long, help, block)
  end

  def option_with_parameter(short, long, help, placeholder, &block)
    to_push = OptionWithParameter.new(short, long, help, placeholder, block)
    @to_parse_options_with_parameters << to_push
  end

  def parse(command_runner, argv)
    parse_arguments(command_runner, argv)
    parse_options(command_runner, argv)
    parse_options_with_parameters(command_runner, argv)
  end

  def help
    result = "Usage: #{@command_name} "
    @to_parse_args.each { |argument| result << '[' + argument.name + '] ' }
    result = result.chop
    @to_parse_options.each do |option|
      result << option.to_s
    end
    @to_parse_options_with_parameters.each do |option|
      result << option.to_s
    end
    result
  end
end
