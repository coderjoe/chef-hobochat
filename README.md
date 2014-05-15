# hobochat cookbook

[![Build Status](https://travis-ci.org/coderjoe/chef-hobochat.svg?branch=master)](https://travis-ci.org/coderjoe/chef-hobochat)

A cookbook designed to build and install hobochat from the official git repository.

## Supported Platforms

This cookbook has only tested under:
 - Ubuntu 12.04
 - Debian 7.4

It may work on other Unix like operating systems, but your mileage may differ.

## Attributes

| Key                             | Type    | Default                           | Description                                               |
|---------------------------------|---------|-----------------------------------|-----------------------------------------------------------|
| ['hobochat']['user']             | String  | "hobochat"                         | The user under which KiwiIRC will be installed and run    |
| ['hobochat']['group']            | String  | "hobochat"                         | The group under which KiwiIRC will be installed and run   |
| ['hobochat']['directory']        | String  | "/home/hobochat"                   | The install directory                                     |
| ['hobochat']['git']['uri']       | String  | github.com/prawnsalad/KiwiIRC.git | The URI to git repository to clone                        |
| ['hobochat']['git']['revision']  | String  | v0.8.3                            | The revision to install                                   |

## Usage

If you'd like to install hobochat you can use the default recipe.

Include `hobochat` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[hobochat::default]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change
5. Run the tests, ensuring they all pass in both ruby 1.9.3 and 2.0.0
6. Submit a Pull Request

## License and Authors

Author:: Joseph Bauser (coderjoe@coderjoe.net)
