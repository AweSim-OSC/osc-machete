class OSC::Machete::Status
  include Comparable
  
  attr_reader :char
  
  # adaptive computing:
  # http://docs.adaptivecomputing.com/torque/4-1-3/Content/topics/commands/qstat.htm
  # C Job is completed after having run.
  # H Job is held.
  # Q Job is queued, eligible to run or routed.
  # R Job is running.
  #
  # FIXME: is unavailable an appropriate "null object" version of this?
  # Funny that the key for the "null" object is "Unavailable", not "not submitted"
  # Maybe we change this?
  # Caching an "Unavailable" status would be a bad idea
  VALUES = [["U", "unavailable"], [nil, "not_submitted"], ["C", "completed"], ["F", "failed"], 
            ["H", "held"], ["Q", "queued"], ["R", "running"]]
  VALUES_HASH = Hash[VALUES]
  PRECENDENCE = VALUES.map(&:first)
  
  # create self.completed, self.running, etc.
  class << self
    VALUES_HASH.each do |char, name|
      define_method(name) do
        OSC::Machete::Status.new(char)
      end
    end
  end
  
  # create completed?, running?, etc.
  VALUES_HASH.each do |char, name|
    define_method("#{name}?") do
      self == OSC::Machete::Status.new(char)
    end
  end

  # Only Status value that is invalid is "not avaliable"
  # this should not be cached!
  def valid?
    ! unavailable?
  end

  def active?
    running? || queued? || held?
  end
  
  def initialize(char)
    @char = char.to_s
    @char = nil if @char.empty?
    raise "Invalid status value" unless VALUES_HASH.has_key?(@char)
  end
  
  def to_s
    @char.to_s
  end
  
  def inspect
    # FIXME: ActiveSupport  replace with .humanize and simpler datastructure
     VALUES_HASH[@char].split("_").map(&:capitalize).join(" ")
  end
  
  def +(other)
    [self, other].max
  end
  
  def <=>(other)
    precendence <=> other.precendence
  end
  
  def eql?(other)
    other.to_s == to_s
  end
  
  def ==(other)
    self.eql?(other)
  end
  
  def hash
    @char.hash
  end
  
  def precendence
    # Hashes enumerate their values in the order that the corresponding keys were inserted
    PRECENDENCE.index(@char)
  end
end