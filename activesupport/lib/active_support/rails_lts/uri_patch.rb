module URI

  # URI version 0.9 seems not be vulnerable for ReDoS, see the rfc2396 implementation in the fixed gem versions
  # https://github.com/ruby/uri/blob/967281cf10a81c63c43fe965f223a1092419bb04/lib/uri/rfc2396_parser.rb
  #
  # Ruby 1.8.7 is not able to use URI version > 0.9, therefore no patches need to be applied.
  unless RUBY_VERSION < '1.9'

    if const_defined?(:RFC3986_Parser, false)
      rails_lts_supported_uri_versions = [
        '0.12.1',   # 5c4f7d04bf81f31f2767a75c52d87b27910b4ad8 CVE-2023-28755 Patch
        '0.12.0',   # 72f22716f86fe6bccf52c167cbb30e1a6e70aaca
        '0.11.1',   # f0a10975c33656a976b51b16a6475c5dbe368535 CVE-2023-28755 Patch
        '0.11.0',   # 1619f713e60ddffd238276e5f03f4f916074476b
        '0.10.2',   # 0ff6c0360ae29643a433f385fd49587589b8cd02 CVE-2023-28755 Patch
        '0.10.1',   # 94e9ac5d5588718556bd1be1665d7ad60633b275
        '0.10.0.2', # 359e6bc3443b26e0c416d52bea34605c6975dad7
        '0.10.0.1', # 83ff0f037018eaba5e434bb68ca96d906ad1b9f7 CVE-2023-28755 Patch
        '0.10.0',   # 0bcfaa5e2c3e1476fb2eea045836a304026f6c51
      ]

      class RFC3986_Parser
        uri_version = URI::VERSION

        # Eval is necessary for the Ruby 1.8 parser, which does not support named Regex groups
        patterns = {}
        eval(%q(
          patterns[:RAILS_LTS_RFC3986_URI_VULNERABLE_1] = /\A(?<URI>(?<scheme>[A-Za-z][+\-.0-9A-Za-z]*):(?<hier-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*)@)?(?<host>(?<IP-literal>\[(?:(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:)?\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h+\.[!$&-.0-;=A-Z_a-z~]+))\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])+))?(?::(?<port>\d*))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*))*)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])+)(?:\/\g<segment>)*)?)|(?<path-rootless>\g<segment-nz>(?:\/\g<segment>)*)|(?<path-empty>))(?:\?(?<query>[^#]*))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*))?)\z/
          patterns[:RAILS_LTS_RFC3986_URI_VULNERABLE_2] = /\A(?<URI>(?<scheme>[A-Za-z][+\-.0-9A-Za-z]*):(?<hier-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*)@)?(?<host>(?<IP-literal>\[(?:(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:)?\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h+\.[!$&-.0-;=A-Z_a-z~]+))\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])*))(?::(?<port>\d*))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*))*)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])+)(?:\/\g<segment>)*)?)|(?<path-rootless>\g<segment-nz>(?:\/\g<segment>)*)|(?<path-empty>))(?:\?(?<query>[^#]*))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*))?)\z/
          patterns[:RAILS_LTS_RFC3986_URI_PATCH_1] = /\A(?<URI>(?<scheme>[A-Za-z][+\-.0-9A-Za-z]*+):(?<hier-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*+)@)?(?<host>(?<IP-literal>\[(?:(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:)?\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h++\.[!$&-.0-;=A-Z_a-z~]++))\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])++))?(?::(?<port>\d*+))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*+))*+)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])++)(?:\/\g<segment>)*+)?)|(?<path-rootless>\g<segment-nz>(?:\/\g<segment>)*+)|(?<path-empty>))(?:\?(?<query>[^#]*+))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*+))?)\z/
          patterns[:RAILS_LTS_RFC3986_URI_PATCH_2] = /\A(?<URI>(?<scheme>[A-Za-z][+\-.0-9A-Za-z]*+):(?<hier-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*+)@)?(?<host>(?<IP-literal>\[(?:(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:)?\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h++\.[!$&-.0-;=A-Z_a-z~]++))\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])*+))(?::(?<port>\d*+))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*+))*+)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])++)(?:\/\g<segment>)*+)?)|(?<path-rootless>\g<segment-nz>(?:\/\g<segment>)*+)|(?<path-empty>))(?:\?(?<query>[^#]*+))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*+))?)\z/
          patterns[:RAILS_LTS_RFC3986_relative_ref_VULNERABLE_1] = /\A(?<relative-ref>(?<relative-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*)@)?(?<host>(?<IP-literal>\[(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:){,1}\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h+\.[!$&-.0-;=A-Z_a-z~]+)\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])+))?(?::(?<port>\d*))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*))*)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])+)(?:\/\g<segment>)*)?)|(?<path-noscheme>(?<segment-nz-nc>(?:%\h\h|[!$&-.0-9;=@-Z_a-z~])+)(?:\/\g<segment>)*)|(?<path-empty>))(?:\?(?<query>[^#]*))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*))?)\z/
          patterns[:RAILS_LTS_RFC3986_relative_ref_VULNERABLE_2] = /\A(?<relative-ref>(?<relative-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*)@)?(?<host>(?<IP-literal>\[(?:(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:){,1}\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h+\.[!$&-.0-;=A-Z_a-z~]+))\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])+))?(?::(?<port>\d*))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*))*)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])+)(?:\/\g<segment>)*)?)|(?<path-noscheme>(?<segment-nz-nc>(?:%\h\h|[!$&-.0-9;=@-Z_a-z~])+)(?:\/\g<segment>)*)|(?<path-empty>))(?:\?(?<query>[^#]*))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*))?)\z/
          patterns[:RAILS_LTS_RFC3986_relative_ref_PATCH] = /\A(?<relative-ref>(?<relative-part>\/\/(?<authority>(?:(?<userinfo>(?:%\h\h|[!$&-.0-;=A-Z_a-z~])*+)@)?(?<host>(?<IP-literal>\[(?:(?<IPv6address>(?:\h{1,4}:){6}(?<ls32>\h{1,4}:\h{1,4}|(?<IPv4address>(?<dec-octet>[1-9]\d|1\d{2}|2[0-4]\d|25[0-5]|\d)\.\g<dec-octet>\.\g<dec-octet>\.\g<dec-octet>))|::(?:\h{1,4}:){5}\g<ls32>|\h{1,4}?::(?:\h{1,4}:){4}\g<ls32>|(?:(?:\h{1,4}:){,1}\h{1,4})?::(?:\h{1,4}:){3}\g<ls32>|(?:(?:\h{1,4}:){,2}\h{1,4})?::(?:\h{1,4}:){2}\g<ls32>|(?:(?:\h{1,4}:){,3}\h{1,4})?::\h{1,4}:\g<ls32>|(?:(?:\h{1,4}:){,4}\h{1,4})?::\g<ls32>|(?:(?:\h{1,4}:){,5}\h{1,4})?::\h{1,4}|(?:(?:\h{1,4}:){,6}\h{1,4})?::)|(?<IPvFuture>v\h++\.[!$&-.0-;=A-Z_a-z~]++))\])|\g<IPv4address>|(?<reg-name>(?:%\h\h|[!$&-.0-9;=A-Z_a-z~])++))?(?::(?<port>\d*+))?)(?<path-abempty>(?:\/(?<segment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])*+))*+)|(?<path-absolute>\/(?:(?<segment-nz>(?:%\h\h|[!$&-.0-;=@-Z_a-z~])++)(?:\/\g<segment>)*+)?)|(?<path-noscheme>(?<segment-nz-nc>(?:%\h\h|[!$&-.0-9;=@-Z_a-z~])++)(?:\/\g<segment>)*+)|(?<path-empty>))(?:\?(?<query>[^#]*+))?(?:\#(?<fragment>(?:%\h\h|[!$&-.0-;=@-Z_a-z~\/?])*+))?)\z/
        ))

        if const_defined?(:RFC3986_URI, false)
          if RFC3986_URI == patterns[:RAILS_LTS_RFC3986_URI_VULNERABLE_1]
            remove_const :RFC3986_URI
            RFC3986_URI = patterns[:RAILS_LTS_RFC3986_URI_PATCH_1]
          elsif RFC3986_URI == patterns[:RAILS_LTS_RFC3986_URI_VULNERABLE_2]
            remove_const :RFC3986_URI
            RFC3986_URI = patterns[:RAILS_LTS_RFC3986_URI_PATCH_2]
          elsif [patterns[:RAILS_LTS_RFC3986_URI_PATCH_1], patterns[:RAILS_LTS_RFC3986_URI_PATCH_2]].include?(RFC3986_URI)
            # Patched with 0.10.0.1/0.10.0.2, 0.10.2, 0.11.1 or 0.12.1
          elsif rails_lts_supported_uri_versions.include?(uri_version)
            warn("Rails LTS: Could not patch stdlib uri RFC3986_URI version #{uri_version}, you might be vulnerable for CVE-2023-28755")
          end
        end

        if const_defined?(:RFC3986_relative_ref, false)
          if [patterns[:RAILS_LTS_RFC3986_relative_ref_VULNERABLE_1], patterns[:RAILS_LTS_RFC3986_relative_ref_VULNERABLE_2]].include?(RFC3986_relative_ref)
            remove_const :RFC3986_relative_ref
            RFC3986_relative_ref = patterns[:RAILS_LTS_RFC3986_relative_ref_PATCH]
          elsif patterns[:RAILS_LTS_RFC3986_relative_ref_PATCH] == RFC3986_relative_ref
            # Patched with 0.10.0.1/0.10.0.2, 0.10.2, 0.11.1 or 0.12.1
          elsif rails_lts_supported_uri_versions.include?(uri_version)
            warn("Rails LTS: Could not patch stdlib uri RFC3986_relative_ref version #{uri_version}, you might be vulnerable for CVE-2023-28755")
          end
        end
      end
    end
  end
end
