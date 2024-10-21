class ComplexConfig::KeySource
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

  def master_key?
    !!@master_key_pathname
  end

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

  def key_bytes
    [ key ].pack('H*')
  end
end
