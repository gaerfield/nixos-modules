{
  services.avahi.enable = false;
  networking.nameservers = ["1.1.1.1#cloudflare-dns.com" "2606:4700:4700::1111#cloudflare-dns.com"];
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = ["~."];
    fallbackDns = [
      "1.0.0.1#cloudflare-dns.com"
      "2606:4700:4700::1001#cloudflare-dns.com"
      "9.9.9.9#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "8.8.8.8#dns.google"
      "2001:4860:4860::8888#dns.google"
    ];
    # https://www.guyrutenberg.com/2023/03/14/split-dns-using-systemd-resolved/
    dnsovertls = "opportunistic"; # allow fallback for corporate machines
    llmnr = "false";
    extraConfig = ''
      MulticastDNS=true
    '';
  };
}
