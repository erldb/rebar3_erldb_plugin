rebar3_erldb_plugin
=====

A rebar plugin

Build
-----

    $ rebar3 compile

Use
---

Add the plugin to your rebar config:

    {plugins, [
        {rebar3_erldb_plugin, {git, "https://host/user/rebar3_erldb_plugin.git", {tag, "0.1.0"}}}
    ]}.

Then just call your plugin directly in an existing application:


    $ rebar3 rebar3_erldb_plugin
    ===> Fetching rebar3_erldb_plugin
    ===> Compiling rebar3_erldb_plugin
    <Plugin Output>
