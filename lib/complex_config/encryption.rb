require "openssl"
require "base64"

class ComplexConfig::Encryption
  class EncryptionError < StandardError; end

  class DecryptionFailed < EncryptionError; end

  def initialize(secret)
    @secret = secret
    @cipher = OpenSSL::Cipher.new('aes-128-gcm')
  end

  def encrypt(text)

    @cipher.encrypt
    @cipher.key = @secret
    iv = @cipher.random_iv
    @cipher.auth_data = ""

    encrypted = @cipher.update(Marshal.dump(text))
    encrypted << @cipher.final

    [
      encrypted,
      iv,
      @cipher.auth_tag
    ].map { |v| base64_encode(v) }.join('--')
  end

  def decrypt(text)
    encrypted, iv, auth_tag = text.split('--').map { |v| base64_decode(v) }

    auth_tag.nil? || auth_tag.bytes.length != 16 and
      raise DecryptionFailed, "auth_tag #{auth_tag.inspect} invalid"

    @cipher.decrypt
    @cipher.key = @secret
    @cipher.iv  = iv
    @cipher.auth_tag = auth_tag
    @cipher.auth_data = ""

    decrypted_data = @cipher.update(encrypted)
    decrypted_data << @cipher.final

    Marshal.load(decrypted_data)
  end

  private

  def base64_encode(x)
    ::Base64.strict_encode64(x)
  end

  def base64_decode(x)
    ::Base64.strict_decode64(x.strip)
  end
end
