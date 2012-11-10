module Mapel
  class Engine
    attr_reader :command, :status, :output
    attr_accessor :commands

    def initialize
      @commands = []
    end

    def success?
      @status
    end
    
    # Adds a command to the chain
    def with_command(*cmd)
      @commands.concat cmd.compact
      self
    end
 
    # Removes the last command from chain.
    def undo(times = 1)
      @commands.pop(times)
      self
    end
  end
end