require 'time'

ruby_version = Gem::Version.new(RUBY_VERSION.dup).release

if (spec = Gem.loaded_specs['time']) && spec.version >= Gem::Version.new('0.2.2')
  # nothing to do
elsif ruby_version < Gem::Version.new('2.2')
  # ReDoS-patch for pre-2014 variant of #rfc2822
  class << Time
    def rfc2822(date)
      if /\A\s*
          (?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s*,\s*)?
          (\d{1,2})\s+
          (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+
          (\d{2,})\s+
          (\d{2})\s*
          :\s*(\d{2})
          (?:\s*:\s*(\d\d))?\s+
          ([+-]\d{4}|
           UT|GMT|EST|EDT|CST|CDT|MST|MDT|PST|PDT|[A-IK-Z])/ix =~ date
        # Since RFC 2822 permit comments, the regexp has no right anchor.
        day = $1.to_i
        mon = MonthValue[$2.upcase]
        year = $3.to_i
        hour = $4.to_i
        min = $5.to_i
        sec = $6 ? $6.to_i : 0
        zone = $7

        # following year completion is compliant with RFC 2822.
        year = if year < 50
                 2000 + year
               elsif year < 1000
                 1900 + year
               else
                 year
               end

        year, mon, day, hour, min, sec =
          apply_offset(year, mon, day, hour, min, sec, zone_offset(zone))
        t = self.utc(year, mon, day, hour, min, sec)
        t.localtime if !zone_utc?(zone)
        t
      else
        raise ArgumentError.new("not RFC 2822 compliant date: #{date.inspect}")
      end
    end
    alias rfc822 rfc2822
  end
elsif ruby_version < Gem::Version.new('2.7.8') ||
  (ruby_version >= Gem::Version.new('3') && ruby_version < Gem::Version.new('3.0.6')) ||
  (ruby_version >= Gem::Version.new('3.1') && ruby_version < Gem::Version.new('3.1.4')) ||
  (ruby_version >= Gem::Version.new('3.2') && ruby_version < Gem::Version.new('3.2.2'))

  # ReDoS-patch for post-2014 variant of #rfc2822
  class << Time
    def rfc2822(date)
      if /\A\s*
          (?:(?:Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s*,\s*)?
          (\d{1,2})\s+
          (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+
          (\d{2,})\s+
          (\d{2})\s*
          :\s*(\d{2})
          (?:\s*:\s*(\d\d))?\s+
          ([+-]\d{4}|
           UT|GMT|EST|EDT|CST|CDT|MST|MDT|PST|PDT|[A-IK-Z])/ix =~ date
        # Since RFC 2822 permit comments, the regexp has no right anchor.
        day = $1.to_i
        mon = MonthValue[$2.upcase]
        year = $3.to_i
        short_year_p = $3.length <= 3
        hour = $4.to_i
        min = $5.to_i
        sec = $6 ? $6.to_i : 0
        zone = $7

        if short_year_p
          # following year completion is compliant with RFC 2822.
          year = if year < 50
                   2000 + year
                 else
                   1900 + year
                 end
        end

        off = zone_offset(zone)
        year, mon, day, hour, min, sec =
          apply_offset(year, mon, day, hour, min, sec, off)
        t = self.utc(year, mon, day, hour, min, sec)
        force_zone!(t, zone, off)
        t
      else
        raise ArgumentError.new("not RFC 2822 compliant date: #{date.inspect}")
      end
    end
    alias rfc822 rfc2822
  end
end
