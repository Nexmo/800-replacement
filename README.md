# Replace toll-free 800 numbers with multiple local numbers

This app used the Nexmo Voice APIs to demonstrate the power of using multiple local numbers instead of a toll-free generic number.

## Prerequisites

You will need:

* A [free Nexmo account](https://dashboard.nexmo.com/sign-up)
* The [Nexmo CLI](https://github.com/Nexmo/nexmo-cli) installed
* A way to run a local server on a public port, for example [Ngrok](https://ngrok.com/).
* [Ruby 2.1+](https://www.ruby-lang.org/) and [Bundler](http://bundler.io/)


## Installation

```sh
# clone this repository
git clone git@github.com:Nexmo/ruby-800-replacement.git
# change to folder
cd ruby-800-replacement
# install dependencies
bundle install
# create a .env
cp .env.example .env
```

## Setup

### Buy Numbers & Create Application

To run this application we need to buy 2 numbers, set up an application, and tie the numbers to this application.

```sh
# create an application
> nexmo app:create "800 Replacement" http://your.domain/answer http://your.domain/event --type voice --keyfile app.key
# check the application ID
> nexmo app:list
12345678-1234-1234-1234-1234567890 | 800 Replacement
# purchase 2 numbers in different regions
# For example, Chicago
> nexmo number:buy 1312* -c US  --confirm
Number purchased: 13125550000
# And San Francisco
> nexmo number:buy 1415* -c US  --confirm
Number purchased: 14155550000
# link the numbers to the application ID
> nexmo link:app 13125550000 12345678-1234-1234-1234-1234567890
> nexmo link:app 14155550000 12345678-1234-1234-1234-1234567890
```

### Run Server

The next step is to set up all of our variables in a `.env` file. You can start off by copying the example file.

```sh
mv .env.example .env
```

Fill in the values in `.env` as appropriate, where `INBOUND_NUMBER_1` and `INBOUND_NUMBER_2` are the numbers you just purchased). Finally, `DOMAIN` is the public domain or hostname your server is available on (including scheme).

With this in place you can start the server.

```sh
ruby app.rb
```

The application should be available on <http://localhost:4567>. For this to work full though, make sure to expose your server on a public domain (e.g. `your.domain` in the example above) using a tool like [Ngrok](https://ngrok.com/).

## Using the App

With your server running, call either of the 2 numbers you purchased. Nexmo will then make a call to `http://your.domain/answer` which plays back a message for the local transit system for the city you just called a local number for. It then allows you to play back the messages for the other cities after a prompt.

## License

This project is licensed under the [MIT license](LICENSE).
