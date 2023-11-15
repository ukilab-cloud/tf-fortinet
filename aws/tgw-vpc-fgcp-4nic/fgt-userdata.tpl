Content-Type: multipart/mixed; boundary="==AWS=="
MIME-Version: 1.0

--==AWS==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0

config system global
set hostname ${fgt_id}
end
config system interface
edit port1                            
set alias PUBLIC
set mode static
set ip ${fgt_public_ip}
set allowaccess ping https ssh
set mtu-override enable
set mtu 9001
next
edit port2                            
set alias PRIVATE
set mode static
set ip ${fgt_private_ip}
set allowaccess ping https ssh
set mtu-override enable
set mtu 9001
next
edit port3
set alias HASYNC
set mode static
set ip ${fgt_hasync_ip}
set allowaccess ping 
set mtu-override enable
set mtu 9001
next
edit port4
set alias MGMT
set mode static
set ip ${fgt_mgmt_ip}
set allowaccess ping https ssh
set mtu-override enable
set mtu 9001
next
end
config firewall address
edit SpokeA
set subnet ${spoke1_cidr}
next
edit SpokeB
set subnet ${spoke2_cidr}
next
edit "RFC1918 10.0.0.0/8"
    set allow-routing enable
    set subnet 10.0.0.0 255.0.0.0
next
edit "RFC1918 172.16.0.0/12"
    set allow-routing enable
    set subnet 172.16.0.0 255.240.0.0
next
edit "RFC1918 192.168.0.0/16"
    set allow-routing enable
    set subnet 192.168.0.0 255.255.0.0
next
end
config firewall addrgrp
edit Spokes
set member SpokeA SpokeB
next
edit "RFC1918 Addresses"
    set member "RFC1918 10.0.0.0/8" "RFC1918 172.16.0.0/12" "RFC1918 192.168.0.0/16"
    set allow-routing enable
next
end
config router static
edit 1
set device port1
set gateway ${public_gw}
next
edit 2
set device port2
set dstaddr "RFC1918 Addresses"
set gateway ${private_gw}
end
config firewall policy
edit 1
set name East-West
set srcintf port2
set dstintf port2
set srcaddr Spokes
set dstaddr Spokes
set action accept
set schedule always
set service ALL
set logtraffic all
next
edit 2
set name Egress
set srcintf port2
set dstintf port1
set srcaddr Spokes
set dstaddr all
set action accept
set schedule always
set service ALL
set logtraffic all
set nat enable
end
config system ha
set group-name fortinet
set group-id 1
set password ${password}
set mode a-p
set hbdev port3 50
set session-pickup enable
set ha-mgmt-status enable
config ha-mgmt-interface
edit 1
set interface port4
set gateway ${mgmt_gw}
next
end
set override disable
set priority ${fgt_priority}
set unicast-hb enable
set unicast-hb-peerip ${fgt-remote-hasync}
end
config system vdom-exception
edit 1
set object system.interface
next
edit 2
set object router.static
next
edit 3
set object firewall.vip
next
end

%{ if type == "byol" }
--==AWS==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${file(license_file)}

%{ endif }
--==AWS==--
