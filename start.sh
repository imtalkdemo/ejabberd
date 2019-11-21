export EJABBERD_CONFIG_PATH=ejabberd.yml
erl -sname ejabberd -pa ebin -pa deps/*/ebin
