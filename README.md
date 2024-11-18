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

## Setup using nix flakes

Add to flake.nix:
```nix
{
  description = "NixOS configuration with flakes";
  inputs.common.url = "github:gaerfield/nixos-modules/main";

  outputs = { self, nixpkgs, common }: {
    # replace <your-hostname> with your actual hostname
    nixosConfigurations.<your-hostname> = nixpkgs.lib.nixosSystem {
      modules = [
        common.modules.basic-test
      ];
    };
  };
}
```

## Developing

... yet to document