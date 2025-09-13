require "openssl"
require "base64"

# A class that provides encryption and decryption services using AES-128-GCM
#
# This class handles the encryption and decryption of configuration data using
# OpenSSL's AES-128-GCM cipher mode. It manages the encryption key validation,
# initialization vector generation, and authentication tag handling required
# for secure encrypted communication.
#
# @see ComplexConfig::EncryptionError
# @see ComplexConfig::EncryptionKeyInvalid
# @see ComplexConfig::DecryptionFailed
class ComplexConfig::Encryption
  # Initializes a new encryption instance with the specified secret key
  #
  # This method sets up the encryption object by validating the secret key
  # length and preparing the OpenSSL cipher for AES-128-GCM encryption
  # operations
  #
  # @param secret [String] the encryption key to use, must be exactly 16 bytes
  #   long
  # @raise [ComplexConfig::EncryptionKeyInvalid] if the secret key is not
  #   exactly 16 bytes in length
  def initialize(secret)
    @secret = secret
    @secret.size != 16 and raise ComplexConfig::EncryptionKeyInvalid,
      "encryption key #{@secret.inspect} must be 16 bytes"
    @cipher = OpenSSL::Cipher.new('aes-128-gcm')
  end

  # The encrypt method encodes text using AES-128-GCM encryption
  #
  # This method takes a text input and encrypts it using the OpenSSL cipher
  # configured with AES-128-GCM mode. It generates a random initialization
  # vector and authentication tag, then combines the encrypted data, IV, and
  # auth tag into a base64-encoded string separated by '--'
  #
  # @param text [Object] the object to encrypt, which will be marshaled before
  # encryption
  #
  # @return [String] the base64-encoded encrypted string including the
  #   encrypted data, initialization vector, and authentication tag separated
  #   by '--'
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

  # The decrypt method decodes encrypted text using AES-128-GCM decryption
  #
  # @param text [String] the base64-encoded encrypted string containing the
  #   encrypted data, initialization vector, and authentication tag separated
  #   by '--'
  #
  # @return [Object] the decrypted and marshaled object
  # @raise [ComplexConfig::DecryptionFailed] if the authentication tag is
  #   invalid or decryption fails with the provided key
  def decrypt(text)
    encrypted, iv, auth_tag = text.split('--').map { |v| base64_decode(v) }

    auth_tag.nil? || auth_tag.bytes.length != 16 and
      raise ComplexConfig::DecryptionFailed, "auth_tag was invalid"

    @cipher.decrypt
    @cipher.key = @secret
    @cipher.iv  = iv
    @cipher.auth_tag = auth_tag
    @cipher.auth_data = ""

    decrypted_data = @cipher.update(encrypted)
    decrypted_data << @cipher.final

    Marshal.load(decrypted_data)
  rescue OpenSSL::Cipher::CipherError
    raise ComplexConfig::DecryptionFailed, "decryption failed with this key"
  end

  private

  # The base64_encode method encodes binary data into a Base64 string format
  #
  # This method takes binary data as input and converts it into a
  # Base64-encoded string representation using the strict encoding mode, which
  # ensures that the output contains only valid Base64 characters and raises an
  # error for invalid input
  #
  # @param x [Object] the binary data to encode, typically a String or binary buffer
  # @return [String] the Base64-encoded representation of the input data
  def base64_encode(x)
    ::Base64.strict_encode64(x)
  end

  # The base64_decode method decodes a Base64-encoded string back into its
  # original binary data format.
  #
  # @param x [String] the Base64-encoded string to decode, which will have
  #   leading/trailing whitespace stripped
  # @return [String] the decoded binary data as a string
  # @see base64_encode for the corresponding encoding method
  def base64_decode(x)
    ::Base64.strict_decode64(x.strip)
  end
end
