-module(rebar3_erldb_plugin_prv).

-export([init/1, do/1, format_error/1]).

-define(PROVIDER, compile).
-define(DEPS, [{default, compile}]).

%% ===================================================================
%% Public API
%% ===================================================================
-spec init(rebar_state:t()) -> {ok, rebar_state:t()}.
init(State) ->
    Provider = providers:create([
                                 {name, ?PROVIDER},            % The 'user friendly' name of the task
                                 {module, ?MODULE},            % The module implementation of the task
                                 {namespace, erldb},
                                 {bare, false},                % The task can be run by the user, always false
                                 {deps, ?DEPS},                % The list of dependencies
                                 {example, "rebar3 erldb compile"}, % How to use the plugin
                                 {opts, []},                   % list of options understood by the plugin
                                 {short_desc, "Compile erldb models"},
                                 {desc, "Compile erldb models"}
                                ]),
    {ok, rebar_state:add_provider(State, Provider)}.


-spec do(rebar_state:t()) -> {ok, rebar_state:t()} | {error, string()}.
do(State) ->
    rebar_api:info("Compiling erldb models...", []),
    Apps = case rebar_state:current_app(State) of
               undefined ->
                   rebar_state:project_apps(State);
               AppInfo ->
                   [AppInfo]
           end,

    [begin
         rebar_api:info("Compiling models...", []),
         Opts = rebar_app_info:opts(AppInfo),
         ErldbOpts = rebar_opts:get(Opts, erldb_opts, []),

         OutDir = rebar_app_info:ebin_dir(AppInfo),

         SourceDir = proplists:get_value(source_dir, ErldbOpts, "src/models"),
         SourceDir1 = filename:join(rebar_app_info:dir(AppInfo), SourceDir),
         FoundFiles = rebar_utils:find_files(SourceDir1, ".*\\.erl\$"),

         CompileFun = fun(Source, _Opts1) ->
                              HrlOutDir = proplists:get_value(hrl_out_dir, ErldbOpts, "include"),
                              IncludeDir = filename:join(rebar_app_info:dir(AppInfo), HrlOutDir),
                              filelib:ensure_dir(filename:join(IncludeDir, "dummy.hrl")),
                              rebar_api:info("Compiling ~p", [Source]),
                              erldb_compiler:compile(Source, [{outdir, OutDir},
                                                              {includedir, IncludeDir}]),
                              ok
                      end,

         rebar_base_compiler:run(Opts, [], FoundFiles, CompileFun)
     end || AppInfo <- Apps],

    {ok, State}.

-spec format_error(any()) ->  iolist().
format_error(Reason) ->
    io_lib:format("~p", [Reason]).
