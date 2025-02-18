# Decidim::Vocdoni

[![[CI] Lint](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/lint.yml/badge.svg)](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/lint.yml)
[![[CI] Tests](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/test.yml/badge.svg)](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/126b8ece66b8292802f3/maintainability)](https://codeclimate.com/github/decidim-vocdoni/decidim-module-vocdoni/maintainability)
[![codecov](https://codecov.io/gh/decidim-vocdoni/decidim-module-vocdoni/branch/main/graph/badge.svg?token=LRT4MJBNVY)](https://codecov.io/gh/decidim-vocdoni/decidim-module-vocdoni)

:warning: This module is a Beta stage, we recommend you to contact the authors before use it.
This is specially relevant as voting using the blockchain has an economic cost.

An elections component for Decidim's participatory spaces based on the [Vocdoni](https://vocdoni.app).

Vocdoni is a secure digital voting solution using decentralized technologies.
The voting protocol which powers the platform is designed to be universally verifiable,
secure, and resistant to attack and censorship through the use of blockchain technology,
together with decentralized technologies and cryptographic mechanisms, such as zero-knowledge proofs.

This will allow administrators to set-up elections in the Vocdoni blockchain (aka Vochain),
using the [Vocdoni SDK](https://vocdoni.io/).

## Usage

Vocdoni will be available as a Component for a Participatory Space.

For installation instructions, [skip the screenshots section](#installation).

## Screenshots

A nice wizard to set up the election in the admin:

![](docs/config_start.png)
![](docs/config_calendar.png)

Final checks and blockchain synchronization:

![](docs/setup_election.jpg)

Voting in a non-distracting booth:

![](docs/choosing_vote.png)
![](docs/sending_vote.png)
![](docs/vote_finished.png)

Publication of results:

![](docs/results.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-vocdoni", github: "decidim-vocdoni/decidim-module-vocdoni"
```

And then execute:

```
bundle
bin/rails decidim:upgrade
bin/rails db:migrate
```

> **EXPERTS ONLY**
>
> Under the hood, when running `bin/rails decidim:upgrade` the `decidim-vocdoni` gem will run the following (that can also be run manually if you consider):
> 
> ```bash
> bin/rails decidim_vocdoni:install:migrations
> bin/rails decidim_vocdoni:webpacker:install
> ```

Depending on your Decidim version, you can choose the corresponding version to ensure compatibility:

| Version | Compatible Decidim versions |
|---------|-----------------------------|
| 1.x     | 0.27.x                      |
| 2.x     | 0.28.x                      |
| 3.x     | 0.29.x                      |


## Cron based tasks

For some of the Elections status changes, you'll need to add a task to the schedule tasks
configuration of your hosting provider.

In a GNU/Linux server, can configure it with `crontab -e`, for instance if you've created
your Decidim application on /home/user/decidim_application and you want that the Elections
status are checked every 15 minutes, you can do it with this configuration:

```crontab
# Change Elections status on decidim-vocdoni
0/15 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bin/rails decidim_vocdoni:change_election_status > /dev/null
```

## Internal census

Administrators have the possibility to use an internal or dynamic census, allowing the census to be change during the election vote period. On this case it is necessary to update it in to the Vocdoni blockchain. 
A common scenario for this is when you want the internal Decidim userbase to be the census. Then, an authorization method is selected in order to be able to vote and people can dynamically authorize themselves in order to vote (because they might not have the proper authorization in the moment of voting).

This process can have a cost of a few tokens, so it is not done automatically. The admin is responsible to update the census in the Vocdoni blockchain in the admin's monitoring page. The process of updating the census effectively removes the current census and creates a new one for the ongoing election, so it is advisable to do it with care and properly inform the voters at which time they will be able to vote.

In summary, **the admin is responsible to update the census at all times, this is not an automatic process**. Also, remember that this **might have a monetary cost** in terms of tokens.

## Node.js required: Vocdoni API

> **TL;DR** Ensure you have a working Node.js installation in the Decidim Production server with the package `@vocdoni/sdk` installed.
> (Node.js is already a requirement in order to precompile the Rails assets but it is not strictly necessary for running Decidim in production).
> **If you want to use this plugin, you'll need to have Node.js installed in the production server**.

This module needs to communicate with the [Vocdoni API](https://vocdoni.io/api). For that, it used the [SDK provided](https://developer.vocdoni.io/sdk) by Vocdoni that is written in Javascript and available as an [NPM package](https://www.npmjs.com/package/@vocdoni/sdk).

This plugin uses this SDK using a wrapper around it by calling a [Node.js](https://nodejs.org/en/) instance under the hood.

So, ensure you have a working Node.js application accessible by the Decidim installation with the package `@vocdoni/sdk` installed. Note that using the default auto-generated `package.json` should work but it installs dependencies only needed to compile the Rails assets. If you want to optimize your production server, you can install only the dependencies needed by the SDK by running `npm install @vocdoni/sdk` in the Decidim installation path or using a custom package.json file like this:

```json
{
  "dependencies": {
    "@vocdoni/sdk": "^0.8.0"
  }
}
```

## Pricing

The usage of the Vocdoni platform has some economic costs, as its using a Blockchain.

For using it in a production environment with guaranties, you may contact with the maintaners of this plugin [PokeCode](https://pokecode.net) asking for a pricing. Costs will vary depending on your census size and the number of elections you want to perform.

As there could be other resellers and not only PokeCode, contact information can be configured by using the ENV variables VOCDONI_RESELLER_NAME and VOCDONI_RESELLER_EMAIL (see the [configuration](#configuration) for more information)

## Configuration

By default, the module is configured to read the configuration from ENV variables.

Currently, the following ENV variables are supported:

| ENV variable | Description | Default value |
| ------------ | ----------- |-------|
| VOCDONI_API_ENDPOINT_ENV | The environment of the Vocdoni API. Only two values are accepted: `dev`, `stg`, `prod`. Read more on [Vocdoni SDK Usage Environment](https://github.com/vocdoni/vocdoni-sdk#environment) | `stg` |
| VOCDONI_MINUTES_BEFORE_START | How many minutes should the setup be run before the election starts (when configured automatically) | `10` |
| VOCDONI_MANUAL_START_DELAY | How many seconds after the action of starting an election manually people will be allowed to vote. Note that this time is needed in order to configure the election in the blockchain. You might want to increase it if communication with the Vocdoni API is slow. | `30` |
| DECIDIM_VOCDONI_SDK_DEBUG | This is for development purposes. If set to `true`, any call to the Vocdoni API using the SDK ruby wrapper will be logged into the `node_debug.log` file (on the application main folder). | `false` |
| VOCDONI_RESELLER_NAME          | The name of the Vocdoni reseller, the organization that manages the tokens to work with the Vocdoni platform. | `PokeCode SL`     |
| VOCDONI_RESELLER_EMAIL         | The email of the Vocdoni reseller. | vocdoni@pokecode.net |

It is also possible to configure the module using the `decidim-vocdoni` initializer:

```ruby
Decidim::Vocdoni.configure do |config|
  config.api_endpoint_env = "stg"
  config.minimum_minutes_before_start = 20
  config.manual_start_time_delay = 30
end
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bin/rails s
```

Note that `bin/rails` is a convenient wrapper around the command `cd development_app; bundle exec rails`.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Webpacker notes

As latest versions of Decidim, this repository uses Webpacker for Rails. This means that compilation
of assets is required every time a Javascript or CSS file is modified. Usually, this happens
automatically, but in some cases (specially when actively changes that type of files) you want to
speed up the process.

To do that, start in a separate terminal than the one with `bin/rails s`, and BEFORE it, the following command:

```bash
bin/webpack-dev-server
```

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```bash
bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

#### Non-Ruby Code Styling

There are other linters for Javascript and CSS. These run using NPM packages. You can
run the following commands:

1. `npm run lint`: Runs the linter for Javascript files.
2. `npm run lint-fix`: Automatically fix issues for Javascript files (if possible).
3. `npm run stylelint`: Runs the linter for SCSS files.
4. `npm run stylelint-fix`: Automatically fix issues for SCSS files (if possible).

### Testing

To run the tests run the following in the gem development path:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

We also have some tests for the Javascript code. To run them, you can use the
following commands:

```bash
npm ci
npm run test
```

### Test code coverage

Code coverage report is generated automatically after running the test suite, in a folder
named `coverage` in the project root which contains the code coverage report. It's
available at the file ./coverage/index.html. If you're using GNU/Linux, you can open
it with `xdg-open ./coverage/index.html`.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-module-vocdoni

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).

As this module works with the Vocdoni SDK, see https://vocdoni.io/ for more information about their open source licenses.
