# nixos-modules
This repository contains my personal configurations of packages I do use on several 
NixOs hosts.
**Do not use** this repository for you personal NixOs setup. Feel welcome to browse around, get impressions and copy things over.

## Reasoning

NixOs beginner tutorials often encourage using flakes and modularizing the declarative setup of packages, all within a single git repository. But NixOs configurations do include several sensitive data I don't want to leak publicly. I.e. usernames, host names (leaking my home infrastructure), shell alias'es (leaking infrastructure from my daily job), etc. ... I really enjoy the possibility of looking up configurations from other users to improve (or worsen) my personal setup. And I do like sharing my configurations with other users to do the same. Thats why this repository came to life.

## Links

* [NixOs/nixos-hardware](https://github.com/NixOS/nixos-hardware/tree/master):
    * where I got the idea for this repo
    * useful configurations for the hardware that NixOs is running on
* [NixOs introduction](https://nixos-and-flakes.thiscute.world/introduction/): this was my first steps getting in touch with NixOs
* best practices for managing the config:
  * [starter configs](https://github.com/Misterio77/nix-starter-configs)
  * [kickstarter config](https://github.com/ryan4yin/nix-config/tree/i3-kickstarter)
    * [nixos-and-flakes authors config](https://github.com/ryan4yin/nix-config)
* [direnv blog post](https://determinate.systems/posts/nix-direnv/): how to configure specific development environments
* [declarative gnome configuration](https://determinate.systems/posts/declarative-gnome-configuration-with-nixos/)
* [impermanence](https://github.com/nix-community/impermanence) resets the OS persistence to its declared state (execept exceptions)
  * [why this is a good idea](https://grahamc.com/blog/erase-your-darlings/)
* automated nixos setups
  * [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
    * [basic example](https://github.com/nix-community/nixos-anywhere-examples/blob/main/flake.nix)
    * [secrets](https://nix-community.github.io/nixos-anywhere/howtos/secrets.html)
  * [disko](https://github.com/nix-community/disko) used by nixos anywhere
    * [luks-btrfs example](https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix) 
* nixos server example:
  * [nixos as a server](https://guekka.github.io/nixos-server-1/)
  * [tailscale setup](https://guekka.github.io/nixos-server-2/)

## usage

### Setup using flakes

Add to flake.nix:
```nix
{
  description = "NixOS configuration with flakes";
  inputs.common.url = "github:gaerfield/nixos-modules/main";

  outputs = { self, nixpkgs, common }: {
    # replace <your-hostname> with your actual hostname
    nixosConfigurations.<your-hostname> = nixpkgs.lib.nixosSystem {
      modules = [
        common.system.bluetooth
        common.hm.base.shell
        common.hm.vlc
      ];
    };
  };
}
```

### update

```
nix flake update common
```

## Structure

I use [home-manager](https://github.com/nix-community/home-manager) and enable most binaries and configurations there keeping NixOs itself at bare minimum. Modules are seperated by directory:

* system: modules targeted for NixOs
* hm-base: minimal default configuration that is enabled on every host
* hm: home-manager modules that are only selectively enabled

## Developing

Testing locally before committing and pushing by setting url to a local path:

```nix
{
    inputs.common.url = "git+file://<absolut-path-to-directory>";
}
```

