class Configuration < ActiveRecord::Base

  validates_presence_of :name, :value

  def self.get_cached(name, default)
#    key = get_key(name)
    # First try the application cache
#    value = Rails.cache.read(key)
    # if (value != nil)
    #   return value;
    # end
      
    # If not yet cached, look up in database
    obj = find_by_name(name)

    # Not in DB either: insert new record with default value
    if (obj != nil)
      value = obj.value
    else
      value = default
      obj = Configuration.new(:name=>name, :value=>default)
      obj.save!
    end

#    Rails.cache.write(key, value)

    return value
  end

  ## Set value, both in the DB and the cache
  def self.set(name, value)
#    key = get_key(name)
    if value == nil
      value = "false"
    end
#    if (Rails.cache.read(key) == value)
#      return
#    end
    obj = find_by_name(name)
    if (obj == nil)
      obj = Configuration.new(:name=>name, :value=>value)
    else
      obj.value = value
    end
    obj.save!
#    Rails.cache.write(key, value)
  end

  def self.get_key(name) 
    "configuration_" + name
  end
  
end
