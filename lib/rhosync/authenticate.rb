module Rhosync
    
  class Authenticate
    def self.call(env)
      [200, {'Content-Type' => 'text/plain'}, ['hello from rack']]
    end
    
    # def call(env)
    #       [200, {'Content-Type' => 'text/plain'}, ['hello from sinatra instance!']]
    #     end
  end
end