#!/usr/bin/env coffee
# Copyright 2013 Klarna AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

fs = require 'fs'
argparse = require 'argparse'
_ = require 'lodash'
katt = require '../'
pkg = require '../package'

parseArgs = (args) ->
  ArgumentParser = argparse.ArgumentParser

  parser = new ArgumentParser
    description: pkg.description
    version: pkg.version
    addHelp: true

  parser.addArgument ['-p', '--params'],
    help: 'Params as JSON string'
    nargs: '1'

  parser.addArgument ['scenarios'],
    help: 'Scenarios as files'
    nargs: '+'

  parser.parseArgs args


main = exports.main = (args = process.args) ->
  args = parseArgs args
  {params, scenarios} = args
  params = JSON.parse params  if params?
  hadErrors = 0
  next = () ->
    process.exit hadErrors  unless scenarios.length
    paramsCopy = undefined
    paramsCopy = _.cloneDeep params  if params?
    scenario = scenarios.shift()
    process.stdout.write "- #{scenario} - "
    katt.run {scenario, params: paramsCopy}, (err, result) ->
      if err?
        hadErrors = 1
        console.log 'ERROR'
        return console.error err
      console.log result.status.toUpperCase()
      if result.status is 'fail'
        hadErrors = 1
        console.error JSON.stringify result, null, 2
      next()
  next()


main()  if require.main is module
