module XboxHelper
  def xbox_boolean(value, size='2x')
    fa_icon "#{value ? 'check-' : ''}square-o #{size}", class: (value ? 'green' : 'gray')
  end

  def online_multiplayer(min, max)
    if (min.nil? || min < 1) && (max.nil? || max < 1)
      'None'
    else
      str = ''
      str << "#{min}" if (!min.nil? || min >= 1)
      str << ' to ' if (!min.nil? || min >= 1) && (!max.nil? || max >= 1)
      str << "#{max}" if (!max.nil? || max >= 1)
    end
  end
end
