# frozen_string_literal: false

require 'puppet/provider/parsedfile'

newsyslog = '/etc/newsyslog.conf'

Puppet::Type.type(:newsyslog).provide :parsed,
                                      parent: Puppet::Provider::ParsedFile,
                                      default_target: newsyslog,
                                      filetype: :flat do
  # confine :exists => newsyslog

  desc 'The newsyslog provider that uses the ParsedFile class'

  text_line :comment, match: /^#/
  text_line :blank, match: /^\s*$/

  newsyslog_flags = case Facter.value(:operatingsystem)
                    when 'FreeBSD' then 'BCDGJNRUXZ'
                    when 'OpenBSD' then 'BFMZ'
                    end

  record_line :parsed,
              # TODO: usergroup parsing
              fields: %w[name usergroup mode keep size when flags remainder],
              match: %r{^\s*(/\S+)\s+(\w*:\w*|)\s+(\d\d\d)\s+(\d+)\s+(\d+|\*)\s+(\S+)\s*([#{newsyslog_flags}]*)\s*(.*)}, # rubocop:disable Metrics/LineLength
              optional: %w[usergroup flags remainder],
              post_parse: proc { |hash|
                if hash[:usergroup] == :absent
                  # no user/group
                  hash[:owner] = :absent
                  hash[:group] = :absent
                else
                  # split user/group into properties
                  ugarr = hash[:usergroup].split(':')
                  hash[:owner] = ugarr[0]
                  hash[:group] = ugarr[1]

                  # XXX: oddly, if one gets the string 'absent' it evaluates
                  #      to :absent somehow - throwing an actual 'absent'
                  #      parameter off. Don't know of a way around this.

                  hash[:owner] = :absent if hash[:owner].nil?
                  hash[:group] = :absent if hash[:group].nil?
                  hash[:owner] = :absent if hash[:owner] == ''
                  hash[:group] = :absent if hash[:group] == ''
                end
                # remove the actual usergroup property, is a pseudo string
                hash.delete(:usergroup)
              },

              pre_gen: proc { |hash|
                if (hash.key?(:owner) \
                    && !hash[:owner].nil? \
                    && hash[:owner] != :absent) \
                    || (hash.key?(:group) \
                    && !hash[:group].nil? \
                    && hash[:group] != :absent)
                  # either user or group exists, generate a field for it
                  hash[:owner] = '' if hash[:owner] == :absent
                  hash[:group] = '' if hash[:group] == :absent
                  hash[:usergroup] = "#{hash[:owner]}:#{hash[:group]}"
                end
                if hash[:remainder] == :absent || hash[:remainder].nil?
                  hash[:remainder] = ''
                end

                if hash.key? :monitor
                  if hash.key?(:flags) && hash[:flags].match(/M/)
                    hash[:remainder] = hash[:monitor].to_s
                  else
                    raise Puppet::ParseError,
                          'Monitor mail receiver must be '\
                          'specified in combination with M flag '\
                          'in flags field.'
                  end
                end

                if hash.key?(:command) \
                   && (hash.key?(:pidfile) || hash.key?(:sigtype))
                  raise Puppet::ParseError,
                        'Given command parameter and pidfile or '\
                        'sigtype. Parameter command is mutually '\
                        'exclusive to the others.'
                end

                if (hash.key?(:pidfile) \
                     && !hash.key?(:sigtype)) \
                     || (hash.key?(:sigtype) \
                     && !hash.key?(:pidfile))
                  raise Puppet::ParseError,
                        'Parameters pidfile and sigtype must be '\
                        'specified together.'
                end

                if hash.key? :command
                  hash[:remainder] << " \"#{hash[:command]}\""
                end

                if hash.key? :pidfile
                  hash[:remainder] << " #{hash[:pidfile]} #{hash[:sigtype]}"
                end
              }
end
