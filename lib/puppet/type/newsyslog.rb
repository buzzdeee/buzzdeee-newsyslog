# frozen_string_literal: true

Puppet::Type.newtype(:newsyslog) do
  @doc = 'Manage the contents of /etc/newsyslog.conf'

  ensurable

  newparam(:name) do
    desc 'The log file to rotate'

    isnamevar
  end

  newproperty(:owner) do
    desc 'Optional owner (user) of log file'
  end

  newproperty(:group) do
    desc 'Optional group of log file'
  end

  newproperty(:mode) do
    desc 'File mode (permissions) of log file'
  end

  newproperty(:keep) do
    desc 'Number of archive log files to keep'
  end

  newproperty(:size) do
    desc 'Size of log file'
  end

  newproperty(:when) do
    desc 'Frequency of rotation'
  end

  newproperty(:flags) do
    desc 'Optional newsyslog rotation flags. See newsyslog docs for meaning'
  end

  newproperty(:monitor) do
    desc 'Optional username or email address that should receive '\
          'notification messages if this is a monitored log file. '\
          'Only valid, and required, in combination with the M flag.'
  end

  newproperty(:pidfile) do
    desc 'Optional Path to file with process ID, mutually exclusive '\
         'with command.'
  end

  newproperty(:sigtype) do
    desc 'Optional signal type for process. Numeric or symbolic. '\
         'Mutually exclusive with command.'
  end

  newproperty(:command) do
    desc 'Optional command to restart a service. Mutually exclusive '\
         'with with pidfile and sigtype.'
  end
end
