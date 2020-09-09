require 'dotenv'

begin
  Dotenv.load
rescue StandardError
  p 'Could not load environment variables.'
  exit(false)
end
