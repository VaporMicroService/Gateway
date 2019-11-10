<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.1-brightgreen.svg" alt="Swift 5.1">
    </a>
</p>

## Summary

Simple API gateway created with Vapor written in Swift.

## Table of Contents
* [Summary](#summary)
* [Features](#features)
* [Getting Started](#getting-started)
* [Contributing](#contributing)
* [Community](#community)

## Features

Proxy looks for microservice name as first url string component. 
For example given path: `/user/abc/123` would be recognized as `user` service. 

Configuration is loaded via enviromental variables where:

variable name is `HOST_{service}` in this case `user` which would be `HOST_user`
as value it should be JSON containing data such as:

1. Host

2. flag if client should be authorised

```
{
    "host":"http://localhost:8081/v1",
    "loginRequired":false
}
```

### Client uthorisation 

You need to specify URL for service responsible to validate token and provide owner/user id. 
You do it by adding env variable `AUTH` which points to fully declared addres for instance `http://localhost:8081/v1/users/id`

## Getting Started

Getting Started guide, tutorials, and API reference take a look into unit tests.

## Contributing

All improvements are very welcome! Here's how to get started.

1. Clone this repository.

  `$ git clone https://github.com/.../...`

2. Build and run tests.

  `$ swift test`

## Community