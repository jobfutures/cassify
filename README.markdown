## Current Status

Not working

## How CAS works

#### Login Ticket

#### Service Ticket

#### Ticket Granting Ticket

#### Proxy Granting Ticket

#### Proxy Ticket (subclass of Service Ticket)

## Tests

### How-to: Setup environment to test
* create database for test
* setup database.yml file in config/datatbase.yml
* rake cassify:migrate CAS_ENV=test

passing specs for:

* log in ticket
* service ticket
* ticket granting ticket

faling specs for:

* proxy ticket
* proxy granting ticket

## TODO

* rake task for generating views in your project
* fix up the views (remove in-line js etc)
* make it work with a separate database if specified
* single signout
* client methods for authentication

## Spec

[[CAS Spec | http://www.jasig.org/cas/protocol]]
[[CAS 1.0 Archetecture | http://www.jasig.org/cas/cas1-architecture]]
[[CAS 1.0 Archetecture | http://www.jasig.org/cas/cas2-architecture]]