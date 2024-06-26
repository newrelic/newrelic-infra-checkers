<a href="https://opensource.newrelic.com/oss-category/#community-plus"><picture><source media="(prefers-color-scheme: dark)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/dark/Community_Plus.png"><source media="(prefers-color-scheme: light)" srcset="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Community_Plus.png"><img alt="New Relic Open Source community plus project banner." src="https://github.com/newrelic/opensource-website/raw/main/src/images/categories/Community_Plus.png"></picture></a>

# newrelic-infra-checkers

Default configuration files for the static analysis tools used in New Relic integrations and agent repositories.

Action to get those default config files.

## Usage

Usage and defaults:
```yaml
- name: Get default configuration files for NR static analysis tools
  uses: newrelic/newrelic-infra-checkers@v1
  with:
    semgrep-append: false # Optional, if set to true, local semgrep file policies will join the ones in this repository.
    golangci-lint-limited: true # Optional, if set to true, `golangci-lint-limited` config will be used instead of `golangci-lint`.
```
If local config file for the linters exist, the ones in this repository won't overwrite them.

## Support

New Relic hosts and moderates an online forum where customers can interact with New Relic employees as well as other customers to get help and share best practices. Like all official New Relic open source projects, there's a related [Community](https://discuss.newrelic.com) topic in the New Relic Explorers Hub. 

## Contribute

We encourage your contributions to improve this action! Keep in mind that when you submit your pull request, you'll need to sign the CLA via the click-through using CLA-Assistant. You only have to sign the CLA one time per project.
http
If you have any questions, or to execute our corporate CLA (which is required if your contribution is on behalf of a company), drop us an email at opensource@newrelic.com.

**A note about vulnerabilities**

As noted in our [security policy](../../security/policy), New Relic is committed to the privacy and security of our customers and their data. We believe that providing coordinated disclosure by security researchers and engaging with the security community are important means to achieve our security goals.

If you believe you have found a security vulnerability in this project or any of New Relic's products or websites, we welcome and greatly appreciate you reporting it to New Relic through [HackerOne](https://hackerone.com/newrelic).

If you would like to contribute to this project, review [these guidelines](./CONTRIBUTING.md).

To all contributors, we thank you!  Without your contribution, this project would not be what it is today.  We also host a community project page dedicated to [Project Name](<LINK TO https://opensource.newrelic.com/projects/... PAGE>).

## License
newrelic-infra-checkers is licensed under the [Apache 2.0](http://apache.org/licenses/LICENSE-2.0.txt) License.
