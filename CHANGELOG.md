# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [2.0.0](https://github.com/sravioli/log.wz/compare/7e1422b734938cd0a64ae0aeb1d83324723ea1f2..2.0.0) - 2026-11-22
#### Bug Fixes
- (**api**) follow the configured threshold in loggers without their own - ([2992f1e](https://github.com/sravioli/log.wz/commit/2992f1e2c4c2a58b19465e999b1bc276bdabd11f)) - sravioli
#### Documentation
- (**contributing**) document the signed-commit requirement - ([b547621](https://github.com/sravioli/log.wz/commit/b547621bc8a9dd3d83e33f78dded42bde4722f28)) - sravioli
- (**contributing**) unify guides and templates - ([7e1422b](https://github.com/sravioli/log.wz/commit/7e1422b734938cd0a64ae0aeb1d83324723ea1f2)) - sravioli
- (**readme**) point to warp.log - ([c505f09](https://github.com/sravioli/log.wz/commit/c505f093b7cf5b5ff0c149e6e7affef11023830f)) - sravioli
- (**readme**) unify badge style and add release badge - ([dfbbf06](https://github.com/sravioli/log.wz/commit/dfbbf0683b6112ec0f4b9a208e1edcae10594de9)) - sravioli
- (**readme**) align checks section - ([94c14bf](https://github.com/sravioli/log.wz/commit/94c14bf7002f054c5e1d0088b415b3cb5f4f6591)) - sravioli
- add minit.lua for reproducing bugs - ([31d4c9b](https://github.com/sravioli/log.wz/commit/31d4c9b7c3267644ee09e38fa66730bfd1376dfc)) - sravioli
- document working-tree local checkout setup - ([a7beb19](https://github.com/sravioli/log.wz/commit/a7beb19793a9992d5bad0522b1fb8d65184e3d16)) - sravioli
#### Continuous Integration
- pass the release tag to the shell through env - ([134d215](https://github.com/sravioli/log.wz/commit/134d2155608bb5d865ec3d134274717bad18b76c)) - sravioli
- release from the pushed tag - ([28867f7](https://github.com/sravioli/log.wz/commit/28867f78c080d0ee3bebb4855c89e2d92373de84)) - sravioli
- count only the plugin's own files in coverage - ([4f77a6a](https://github.com/sravioli/log.wz/commit/4f77a6a36bce5b6df9ffaa725ef2ed5e3b21a3cf)) - sravioli
- bump cocogitto/cocogitto-action from 3.11 to 4 in the actions group across 1 directory (#5) - ([0b517c5](https://github.com/sravioli/log.wz/commit/0b517c56e07e149de8b52979e9eb23b8aa140386)) - [@sravioli](https://github.com/sravioli)
- adapt workflows to cocogitto-action v4 - ([cdc584d](https://github.com/sravioli/log.wz/commit/cdc584d8fd01f32dfdbd0cb2ca509d4470a58729)) - sravioli
- build the API reference from a majority of three LuaLS runs - ([121aed4](https://github.com/sravioli/log.wz/commit/121aed44c32a93a75472e03793479ea21d239b41)) - sravioli
- bump cocogitto/cocogitto-action - ([1a9d09a](https://github.com/sravioli/log.wz/commit/1a9d09ae7cef0c524774cdb4b1552b90c02f9330)) - dependabot[bot]
- update the actions to the versions Dependabot proposed - ([f3e9ced](https://github.com/sravioli/log.wz/commit/f3e9ced99f12ece103a70b172834f3fe0b375484)) - sravioli
- pin StyLua to 2.6.0 - ([8f27566](https://github.com/sravioli/log.wz/commit/8f27566993eb075c479a3c781b6303aabaa25d8b)) - sravioli
- fix the flaky API check and the EditorConfig rate limit - ([501efc2](https://github.com/sravioli/log.wz/commit/501efc2a80cef2aaaf9fbeab63ab79c68a7fec05)) - sravioli
#### Refactoring
- (**file**) build the file sink on warp's filesystem helpers - ([e0f0740](https://github.com/sravioli/log.wz/commit/e0f0740364aa6345b7f1e5f18d49a79e985c2954)) - sravioli
- ![BREAKING](https://img.shields.io/badge/BREAKING-red) (**sinks**) drop fallback stubs, ring-buffer memory sink - ([5427833](https://github.com/sravioli/log.wz/commit/5427833981925c43ec24213a4c22257818ae3661)) - sravioli
- ![BREAKING](https://img.shields.io/badge/BREAKING-red) return warp.log from warp.wz - ([2b93ef4](https://github.com/sravioli/log.wz/commit/2b93ef44fcabb5d381107cc9553158cf199a41fa)) - sravioli

- - -

## [1.0.3](https://github.com/sravioli/log.wz/compare/189ba959f0c81c9e7f285be68717b22d3301ea33..1.0.3) - 2026-11-15
#### Bug Fixes
- (**file**) create log dir lazily without a shell - ([ed3e065](https://github.com/sravioli/log.wz/commit/ed3e065b44eb5c7a64de902a506b79b849c3e3e4)) - sravioli
#### Performance Improvements
- (**bootstrap**) keep plugin list across reloads - ([d43dac0](https://github.com/sravioli/log.wz/commit/d43dac05746706ae8410456d406fdf4ec52b8cc4)) - sravioli
- (**bootstrap**) share plugin discovery snapshot - ([189ba95](https://github.com/sravioli/log.wz/commit/189ba959f0c81c9e7f285be68717b22d3301ea33)) - sravioli
#### Documentation
- (**readme**) update plugin READMEs - ([fe1a9d8](https://github.com/sravioli/log.wz/commit/fe1a9d85dfbc7375f150af4181d16f40629f350d)) - sravioli
- clarify log timestamp precision - ([5542151](https://github.com/sravioli/log.wz/commit/55421514f31c757aa1aaa5cd8f7a919c0b5e0ab8)) - sravioli
#### Tests
- (**file**) cover lazy log directory creation - ([3532669](https://github.com/sravioli/log.wz/commit/353266918714b3f9928dd9663c066071cd4888e8)) - sravioli

- - -

## [1.0.2](https://github.com/sravioli/log.wz/compare/06f8f0cf9139f420813dbc8b283864e8dc247f0c..1.0.2) - 2026-05-14
#### Features
- streamline configuration files - ([06f8f0c](https://github.com/sravioli/log.wz/commit/06f8f0cf9139f420813dbc8b283864e8dc247f0c)) - sravioli
#### Documentation
- (**github**) add pull request templates - ([663e246](https://github.com/sravioli/log.wz/commit/663e2466d7345d05e1a6a10d14457144f83daf78)) - sravioli
- (**github**) polish issue templates - ([820cbc4](https://github.com/sravioli/log.wz/commit/820cbc4758eef74c3c5848241408eeb18175cd52)) - sravioli
- (**lua**) polish comment wording - ([dec09d4](https://github.com/sravioli/log.wz/commit/dec09d4ce4c03f5cb34179869f7f15f4d4ceb431)) - sravioli
- (**lua**) polish comment wording - ([09c7785](https://github.com/sravioli/log.wz/commit/09c7785c45b22233aac3ef0f0ac2001f6eeff1be)) - sravioli
- (**readme**) clarify formatter default - ([de30e3b](https://github.com/sravioli/log.wz/commit/de30e3bfc595ad741688f0db74917caef4169f13)) - sravioli
- (**readme**) improve readme consistency - ([0facd99](https://github.com/sravioli/log.wz/commit/0facd996e3480c86715a7800ab60a9ccbe39d486)) - sravioli
- (**readme**) add awesome-wezterm badge - ([a5e2fce](https://github.com/sravioli/log.wz/commit/a5e2fceef2adc09e13bf65d7414ff5574e12edeb)) - sravioli
- (**readme**) improve readme clarity - ([4733523](https://github.com/sravioli/log.wz/commit/473352336a2cf703471d8fbc6045d339dbd5422a)) - sravioli
#### Style
- format with stylua - ([89f0986](https://github.com/sravioli/log.wz/commit/89f0986fec6c3caaa00110279974ab6232acb45e)) - sravioli

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