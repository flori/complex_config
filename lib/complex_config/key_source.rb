# A key source class that provides encryption keys from various sources
#
# The KeySource class is responsible for managing and retrieving encryption
# keys from different possible sources such as files, environment variables, or
# direct values. It supports multiple configuration options and ensures that
# only one source is used at a time.
class ComplexConfig::KeySource
  # The initialize method sets up the key source with one of several possible settings.
  #
  # @param pathname [String, nil] The path to a key file
  # @param env_var [String, nil] The name of an environment variable containing the key
  # @param var [String, nil] A string value representing the key
  # @param master_key_pathname [String, nil] The path to a master key file
  #
  # @raise [ArgumentError] if more than one setting is provided
  def initialize(pathname: nil, env_var: nil, var: nil, master_key_pathname: nil)
    settings = [ pathname, env_var, var, master_key_pathname ].compact.size
    if settings > 1
      raise ArgumentError, 'only one setting at most possible'
    end
    pathname and pathname = pathname.to_s
    master_key_pathname and master_key_pathname = master_key_pathname.to_s
    @pathname, @env_var, @var, @master_key_pathname =
      pathname, env_var, var, master_key_pathname
  end

  # The master_key? method checks whether a master key pathname has been set.
  #
  # @return [TrueClass, FalseClass] true if a master key pathname is
  #   configured, false otherwise
  def master_key?
    !!@master_key_pathname
  end

  # The key method retrieves the encryption key from the configured source.
  #
  # This method attempts to obtain the encryption key by checking various
  # possible sources in order: a direct value, an environment variable,
  # a master key file, or a key file associated with a pathname.
  #
  # @return [String, nil] the encryption key as a string if found, or nil if no
  #   key source is configured or accessible
  def key
    if @var
      @var.ask_and_send(:chomp)
    elsif @env_var
      ENV[@env_var].ask_and_send(:chomp)
    elsif master_key?
      IO.binread(@master_key_pathname).chomp
    elsif @pathname
      IO.binread(@pathname + '.key').chomp
    end
  rescue Errno::ENOENT, Errno::ENOTDIR
  end

  # The key_bytes method converts the encryption key to bytes format.
  #
  # This method takes the encryption key value and packs it into a binary byte
  # representation using hexadecimal encoding.
  #
  # @return [String] the encryption key as a binary string of bytes
  def key_bytes
    [ key ].pack('H*')
  end
end
