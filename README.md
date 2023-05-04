[![Community Project header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Community_Project.png)](https://opensource.newrelic.com/oss-category/#community-project)

# newrelic-infra-checkers

Common configuration files for tools used in New Relic integrations and agent repositories.

Configuration files are placed in hardcoded paths that meets the tools expectations.

If those file already exists in the repo they are not overwritten.


## Supported tools

- semgrep: common configuration for [semgrep](https://semgrep.dev/).
- golangci-lint: common configuration for [golangci-lint](https://golangci-lint.run/).
  -  golangci-lint limited: contains a limited amount of linters, meant to be added to projects already developed that are not compliant with those removed linters.
- release toolkit dictionary: dictionary used by the [link-dependencies](https://github.com/newrelic/release-toolkit/tree/main/link-dependencies) action.

## Usage

Example of usage:
```yaml
jobs:
  static-analysis:
    name: Run tools
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: newrelic/newrelic-infra-checkers@v1
      # Tools running after will use the configuration obtained from 'newrelic-infra-checkers' action.
      - uses: returntocorp/semgrep-action@v1
      - uses: golangci/golangci-lint-action@v2
```

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
