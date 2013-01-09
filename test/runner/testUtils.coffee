#Used to stub out dependencies for requirejs modules
#original source:
#http://stackoverflow.com/questions/11439540/how-can-i-mock-dependencies-for-unit-testing-in-requirejs
define(['underscore'],(_)->
    utils =
        createContext:(stubs, baseContext)->
            baseContext?="_"
            map = {}
            _.each(stubs,  (value, key)->
                stubname = 'stub' + key
                map[key] = stubname
            )
            baseCfg = require.s.contexts[baseContext]
            baseCfg?.config?.deps=[]
            newCfg =
                context: Math.floor(Math.random() * 1000000)
                map:
                    "*": map
            context =  require.config(
                if baseCfg? then _.extend(baseCfg.config, newCfg) else newCfg
            )

            _.each(stubs, (value, key)->
                stubname = 'stub' + key;
                define(stubname, ()->
                    value
                )
            )
            context
)