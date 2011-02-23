## Current Status

Not working

## How CAS works

#### Login Ticket

#### Service Ticket

#### Ticket Granting Ticket

#### Proxy Granting Ticket

#### Proxy Ticket (subclass of Service Ticket)

## Tests

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

[CAS Spec](http://www.jasig.org/cas/protocol)
