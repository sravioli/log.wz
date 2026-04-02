# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [1.0.1](https://github.com/sravioli/log.wz/compare/06f8f0cf9139f420813dbc8b283864e8dc247f0c..1.0.1) - 2026-04-02
#### Features
- streamline configuration files - ([06f8f0c](https://github.com/sravioli/log.wz/commit/06f8f0cf9139f420813dbc8b283864e8dc247f0c)) - sravioli
#### Style
- format with stylua - ([89f0986](https://github.com/sravioli/log.wz/commit/89f0986fec6c3caaa00110279974ab6232acb45e)) - sravioli

- - -

## [1.0.0](https://github.com/sravioli/log.wz/compare/1af7e22d3b3bcfe4afcd3c8faad6a595335f3325..1.0.0) - 2026-03-31
#### Bug Fixes
- (**cocogitto**) set correct repository name - ([1af7e22](https://github.com/sravioli/log.wz/commit/1af7e22d3b3bcfe4afcd3c8faad6a595335f3325)) - sravioli
#### Documentation
- correct wezterm function name - ([44c4319](https://github.com/sravioli/log.wz/commit/44c4319e83a20518d90b48ec1bfae51dcd09f535)) - sravioli

- - -

## [0.1.0](https://github.com/sravioli/wezterm/compare/94ee2bfdf9ee3152d226786bd3bac603c48c0028..0.1.0) - 2026-03-20
#### Features
- (**sink.file**) pick default path, forbid config_dir - ([24c54af](https://github.com/sravioli/wezterm/commit/24c54affac0e46c42cff2c738ae25159882d5b97)) - sravioli
- (**sinks**) unify sinks api - ([35c2a51](https://github.com/sravioli/wezterm/commit/35c2a5182cab9b4850b99a80869bd1dffddf1b91)) - sravioli
- (**sinks**) add max_entries option to memory sink - ([3133da8](https://github.com/sravioli/wezterm/commit/3133da83500a97335c138197130128928f55d65b)) - sravioli
- add timestap, file and json sinks - ([059bf5d](https://github.com/sravioli/wezterm/commit/059bf5d6ee96005f1857c8efcc26955297acd34d)) - sravioli
- implement logger - ([8845342](https://github.com/sravioli/wezterm/commit/8845342ef39a3506c2ec0829c4af715f14cd8ca9)) - sravioli
#### Bug Fixes
- (**api**) correctly init logger - ([5beb0ae](https://github.com/sravioli/wezterm/commit/5beb0aed0d5b39daaa03803e0bd581b6fa28b9ac)) - sravioli
- (**api**) consolidate api and init files - ([564fe70](https://github.com/sravioli/wezterm/commit/564fe703fbb2f11be42d352e26779f6428e34d68)) - sravioli
- (**bootstrap**) add correct path entry - ([96d0ffc](https://github.com/sravioli/wezterm/commit/96d0ffc062a5246780879b97b4d1e91d08f30a3e)) - sravioli
- (**bootstrap**) add subdir to package.path - ([e6980bb](https://github.com/sravioli/wezterm/commit/e6980bbbc0080215a61e80a5474e10c802ac113d)) - sravioli
- (**cog**) rm useless packages section - ([18f2e96](https://github.com/sravioli/wezterm/commit/18f2e9675e08b881497e6ac01eab5c0c738d230a)) - sravioli
- (**logging**) improve sink handling and argument formatting - ([9fcf848](https://github.com/sravioli/wezterm/commit/9fcf8487358752480b7d4f910eebcec4568b1f0e)) - sravioli
- (**sink.file**) prevent reload loop - ([e4daa49](https://github.com/sravioli/wezterm/commit/e4daa49fa220430ef362094a5768482d4c43b0c8)) - sravioli
- (**sinks**) add safeguards - ([8627a8a](https://github.com/sravioli/wezterm/commit/8627a8a2fa51f57ad52bbb55e80759dbc17da0a7)) - sravioli
- luacheck warnings - ([2c6eea0](https://github.com/sravioli/wezterm/commit/2c6eea0d449c528c00ebe0d64cfae0c52336e73b)) - sravioli
#### Documentation
- (**readme**) update logger behviour - ([4d3f036](https://github.com/sravioli/wezterm/commit/4d3f036edd4a396bf54b766c52512a486872d4f5)) - sravioli
- (**readme**) fix license hyperlinks - ([ba5ed09](https://github.com/sravioli/wezterm/commit/ba5ed0924c4ea488d4c29232b08538571a9c9395)) - sravioli
- (**readme**) add badges - ([5ea2b1b](https://github.com/sravioli/wezterm/commit/5ea2b1bb17b4d64be972c05a17bfe33024ab4e59)) - sravioli
- (**readme**) add license section - ([a6215f9](https://github.com/sravioli/wezterm/commit/a6215f93a3e330501dc732d1c68c0771da39c066)) - sravioli
- update readme - ([67d2083](https://github.com/sravioli/wezterm/commit/67d20839f8db24107b9ace494b5a92ccad4bc910)) - sravioli
- move documentation in source files - ([e3eb1a1](https://github.com/sravioli/wezterm/commit/e3eb1a16616128803d70c6ecb6bc63b3267fe012)) - sravioli
#### Tests
- fix failing tests - ([e07b9b4](https://github.com/sravioli/wezterm/commit/e07b9b419799f1ecf444c97d1c238b49ef364226)) - sravioli
- add more test cases - ([aff45ea](https://github.com/sravioli/wezterm/commit/aff45eae05f5d69144bf751c0e713002c6389c97)) - sravioli
- add busted tests - ([14cf963](https://github.com/sravioli/wezterm/commit/14cf9632182026294581987c1a1a7cffc3eeeb8e)) - sravioli
#### Continuous Integration
- (**tests**) submit coverage to coveralls - ([05bf011](https://github.com/sravioli/wezterm/commit/05bf0114d24361f8f19dc96adb81075d53bcd2d7)) - sravioli
- (**tests**) cancel action on new pr commit - ([8627880](https://github.com/sravioli/wezterm/commit/862788078990a5018a746fed8e0556537e7d0f1e)) - sravioli
- add linting action - ([3b38b52](https://github.com/sravioli/wezterm/commit/3b38b52ffc12bd109ca84223db3d827d9c78215f)) - sravioli
- add test action - ([6275d18](https://github.com/sravioli/wezterm/commit/6275d18854488d5f311dfb9079dc69689e58186e)) - sravioli
- fix action name - ([b575315](https://github.com/sravioli/wezterm/commit/b5753152fff3ef0c67335946c2aedc3a88f16c64)) - sravioli
#### Refactoring
- ![BREAKING](https://img.shields.io/badge/BREAKING-red) (**levels**) update normalize to return nil for unknown - ([2d51920](https://github.com/sravioli/wezterm/commit/2d51920c9759fe06628e29e0cc68481c6e4bce2a)) - sravioli
- (**log**) improve threshold normalization and setup - ([4921036](https://github.com/sravioli/wezterm/commit/492103618139721bfd77c9570f0114513f5b5c69)) - sravioli
- simplify ensure_dir and clarify comments - ([9fbce0f](https://github.com/sravioli/wezterm/commit/9fbce0f96a7c098472cad9501c3eac2cafc6bc1c)) - sravioli

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).