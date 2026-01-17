{
  services.avahi.enable = false;
  networking.nameservers = ["1.1.1.1#cloudflare-dns.com" "2606:4700:4700::1111#cloudflare-dns.com"];
  services.resolved = {
    enable = true;
    # https://www.guyrutenberg.com/2023/03/14/split-dns-using-systemd-resolved/
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      DOMAINS = ["~."];
      FallbackDNS = [
        "1.0.0.1#cloudflare-dns.com"
        "2606:4700:4700::1001#cloudflare-dns.com"
        "9.9.9.9#dns.quad9.net"
        "2620:fe::fe#dns.quad9.net"
        "8.8.8.8#dns.google"
        "2001:4860:4860::8888#dns.google"
      ];
      DNSOverTLS = "opportunistic"; # allow fallback for corporate machines
      LLMNR = false;
      MulticastDNS = true;
    };
  };
  # turn off DNSSEC for WIFIonICE, as it is otherwise impossible to open "https://login.wifionice.de"
  # to agree with the terms of usage
  # maybe this could be done more restrictive ... had  no time to investigate deeper yet
  # environment.etc."/systemd/resolved.conf.d/WIFIonICE.conf".text = ''
  #   [Match]
  #   Name=WIFIonICE
  # 
  #   [Resolve]
  #   DNSOverTLS=off
  #   DNSSEC=off
  #   DNS=172.18.0.2 # lets just hope, this is always correct
  #   Domains=~wifionice.de
  # '';
}